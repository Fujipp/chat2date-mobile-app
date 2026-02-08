import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:chat2date/config/backend_base.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class GameSocketService {
  final String roomId;
  final String? accessToken;

  GameSocketService({required this.roomId, this.accessToken});

  final _gameController = StreamController<Map<String, dynamic>>.broadcast();
  final _scoreController = StreamController<Map<String, dynamic>>.broadcast();

  StompClient? _client;
  bool _connecting = false;
  bool _disposed = false;
  int _reconnectAttempts = 0;

  Stream<Map<String, dynamic>> get gameStream => _gameController.stream;
  Stream<Map<String, dynamic>> get scoreStream => _scoreController.stream;

  void connect() {
    if (_client != null || _connecting) return;
    _connecting = true;

    final wsUrl = '${ApiBase.websocketBase}${ApiBase.websocketPath}';
    final headers = <String, String>{
      if (accessToken?.isNotEmpty == true)
        'Authorization': 'Bearer $accessToken',
    };

    _client = StompClient(
      config: StompConfig(
        url: wsUrl,
        onConnect: _onConnect,
        beforeConnect: () async {
          await Future.delayed(const Duration(milliseconds: 50));
        },
        onWebSocketError: (err) {
          _connecting = false;
          _scheduleReconnect();
        },
        onStompError: (frame) {
          _connecting = false;
          _scheduleReconnect();
        },
        onDisconnect: (_) {
          _connecting = false;
          _client = null;
          if (!_disposed) _scheduleReconnect();
        },
        stompConnectHeaders: headers,
        webSocketConnectHeaders: headers,
      ),
    );

    _client?.activate();
  }

  void _onConnect(StompFrame frame) {
    _connecting = false;
    _reconnectAttempts = 0;

    print("🎮 Game Socket Connected! Room: $roomId");

    _client?.subscribe(
      destination: '/topic/games/$roomId',
      callback: (frame) {
        final body = frame.body;
        if (body == null) return;
        try {
          final json = jsonDecode(body) as Map<String, dynamic>;
          print("📩 Game Event: $json");

          _gameController.add(json);

          final type = json['type'];
          if (type == 'SCORE_UPDATE') {
            _scoreController.add(json);
          }
        } catch (e) {
          print("⚠️ Error parsing game event: $e");
        }
      },
    );
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _reconnectAttempts = (_reconnectAttempts + 1).clamp(0, 10);
    final int seconds = min(
      30,
      1 << (_reconnectAttempts - 1 >= 0 ? _reconnectAttempts - 1 : 0),
    );
    final delay = Duration(seconds: max(1, seconds));
    Future.delayed(delay, () {
      if (_disposed) return;
      try {
        _client?.deactivate();
      } catch (_) {}
      _client = null;
      _connecting = false;
      connect();
    });
  }

  void dispose() {
    _disposed = true;
    try {
      _client?.deactivate();
    } catch (_) {}
    _client = null;
    try {
      _gameController.close();
    } catch (_) {}
    try {
      _scoreController.close();
    } catch (_) {}
    print("🔌 Game Socket Disposed");
  }
}
