import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:chat2date/config/backend_base.dart';
import 'package:chat2date/models/chat_access_status.dart';
import 'package:chat2date/models/chat_message.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class ChatSocketService {
  final String roomId;
  final String userId;
  final String? accessToken;

  ChatSocketService({
    required this.roomId,
    required this.userId,
    this.accessToken,
  });

  final _messageController = StreamController<ChatMessage>.broadcast();
  final _accessController = StreamController<ChatAccessStatus>.broadcast();
  final _readController = StreamController<Map<String, dynamic>>.broadcast();
  final _relationshipController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _reviewController = StreamController<Map<String, dynamic>>.broadcast();
  StompClient? _client;
  bool _connecting = false;
  bool _disposed = false;
  int _reconnectAttempts = 0;

  Stream<ChatMessage> get messageStream => _messageController.stream;
  Stream<ChatAccessStatus> get accessStream => _accessController.stream;
  Stream<Map<String, dynamic>> get readStream => _readController.stream;
  Stream<Map<String, dynamic>> get relationshipStream =>
      _relationshipController.stream;
  Stream<Map<String, dynamic>> get reviewStream => _reviewController.stream;

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

    _client?.subscribe(
      destination: '/topic/chat/$roomId',
      callback: (frame) {
        final body = frame.body;
        if (body == null) return;
        try {
          final json = jsonDecode(body) as Map<String, dynamic>;
          final message = ChatMessage.fromApi(
            json: json,
            currentUserId: userId,
          );
          _messageController.add(message);
        } catch (_) {}
      },
    );

    _client?.subscribe(
      destination: '/topic/chat/$roomId/access',
      callback: (frame) {
        final body = frame.body;
        if (body == null) return;
        try {
          final json = jsonDecode(body) as Map<String, dynamic>;
          final status = ChatAccessStatus.fromJson(json);
          _accessController.add(status);
        } catch (_) {}
      },
    );

    // Subscribe to read status for real-time "เห็นแล้ว" updates
    _client?.subscribe(
      destination: '/topic/chat/$roomId/read',
      callback: (frame) {
        final body = frame.body;
        if (body == null) return;
        try {
          final json = jsonDecode(body) as Map<String, dynamic>;
          _readController.add(json);
        } catch (_) {}
      },
    );

    _client?.subscribe(
      destination:
          '/topic/relationship/$roomId', // ตรงกับที่เขียนใน Spring Boot
      callback: (frame) {
        final body = frame.body;
        if (body == null) return;
        try {
          final json = jsonDecode(body) as Map<String, dynamic>;
          _relationshipController.add(json); // ส่งข้อมูลเข้า Stream
        } catch (e) {
          print("Error decoding relationship stats: $e");
        }
      },
    );
    _client?.subscribe(
      destination: '/topic/chat/$roomId/review',
      callback: (frame) {
        final body = frame.body;
        if (body == null) return;
        try {
          final json = jsonDecode(body) as Map<String, dynamic>;
          _reviewController.add(json);
        } catch (e) {
          print("Error decoding review event: $e");
        }
      },
    );
    _client?.subscribe(
      destination: '/topic/chat/user/$userId',
      callback: (frame) {
        final body = frame.body;
        if (body == null) return;
        try {
          final json = jsonDecode(body) as Map<String, dynamic>;
          _reviewController.add(json);
        } catch (e) {
          print("Error decoding user review event: $e");
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
      _messageController.close();
    } catch (_) {}
    try {
      _accessController.close();
    } catch (_) {}
    try {
      _readController.close();
    } catch (_) {}
    try {
      _relationshipController.close();
    } catch (_) {
      _reviewController.close();
    }
  }
}
