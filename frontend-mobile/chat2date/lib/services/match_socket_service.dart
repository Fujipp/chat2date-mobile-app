import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:chat2date/core/config/backend_base.dart';
import 'package:chat2date/models/dto/match_event_dto.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class MatchSocketService {
  final String userId;
  final String? accessToken;

  MatchSocketService({
    required this.userId,
    this.accessToken,
  });

  final _controller = StreamController<MatchEventDto>.broadcast();
  StompClient? _client;
  bool _connecting = false;
  bool _disposed = false;
  int _reconnectAttempts = 0;

  Stream<MatchEventDto> get stream => _controller.stream;

  void connect() {
    if (_client != null || _connecting) return;
    _connecting = true;

    final wsUrl = '${ApiBase.websocketBase}${ApiBase.websocketPath}';
    print('[MatchSocket] connecting to $wsUrl');
    final headers = <String, String>{
      if (accessToken?.isNotEmpty == true) 'Authorization': 'Bearer $accessToken',
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
          print('[MatchSocket] websocket error: $err');
          _scheduleReconnect();
        },
        onStompError: (frame) {
          _connecting = false;
          print('[MatchSocket] stomp error: ${frame.body}');
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
    print('[MatchSocket] connected, subscribing to /topic/matches/$userId');
    _client?.subscribe(
      destination: '/topic/matches/$userId',
      callback: (frame) {
        final body = frame.body;
        print('[MatchSocket] received frame: ${body?.substring(0, body.length > 200 ? 200 : body.length)}');
        if (body == null) return;
        try {
          final json = jsonDecode(body) as Map<String, dynamic>;
          final event = MatchEventDto.fromJson(json);
          _controller.add(event);
        } catch (e, st) {
          print('[MatchSocket] failed to handle frame: $e');
          print(st);
        }
      },
    );
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _reconnectAttempts = (_reconnectAttempts + 1).clamp(0, 10);
    // exponential backoff capped at 30s
    final int seconds = min(30, 1 << (_reconnectAttempts - 1 >= 0 ? _reconnectAttempts - 1 : 0));
    final delay = Duration(seconds: max(1, seconds));
    print('[MatchSocket] scheduling reconnect in ${delay.inSeconds}s (attempt=$_reconnectAttempts)');
    Future.delayed(delay, () {
      if (_disposed) return;
      // clear any previous client and try reconnect
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
      _controller.close();
    } catch (_) {}
  }
}

final matchSocketStreamProvider =
    StreamProvider.family.autoDispose<MatchEventDto, String>((ref, userId) {
  final userState = ref.watch(userStoreProvider);
  final accessToken = userState['accessToken'] as String?;
  final service = MatchSocketService(userId: userId, accessToken: accessToken);

  service.connect();
  ref.onDispose(service.dispose);

  return service.stream;
});
