import 'dart:async';
import 'dart:convert';

import 'package:chat2date/config/backend_base.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class UserSocketService {
  final String userId;
  final String? accessToken;

  UserSocketService({required this.userId, this.accessToken});

  final _controller = StreamController<Map<String, dynamic>>.broadcast();
  StompClient? _client;
  bool _connecting = false;
  bool _disposed = false;

  Stream<Map<String, dynamic>> get stream => _controller.stream;

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
        onWebSocketError: (_) {
          _connecting = false;
          _scheduleReconnect();
        },
        onStompError: (_) {
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

    _client?.subscribe(
      destination: '/topic/chat/user/$userId',
      callback: (frame) {
        final body = frame.body;
        if (body == null) return;
        try {
          final json = jsonDecode(body) as Map<String, dynamic>;
          _controller.add(json);
        } catch (e) {
          print('[UserSocket] ❌ parse error: $e');
        }
      },
    );
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    Future.delayed(const Duration(seconds: 5), () {
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
      _controller.close();
    } catch (_) {}
  }
}
