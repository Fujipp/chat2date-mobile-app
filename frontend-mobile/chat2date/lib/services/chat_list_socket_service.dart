import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';

import 'package:chat2date/core/config/backend_base.dart';
import 'package:chat2date/core/utils/backend_datetime_parser.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

/// Event สำหรับการอัพเดท unread count ของห้องแชท
class ChatListUpdateEvent {
  final String roomId;
  final int unreadCount;
  final String? lastMessage;
  final DateTime? lastMessageTime;

  ChatListUpdateEvent({
    required this.roomId,
    required this.unreadCount,
    this.lastMessage,
    this.lastMessageTime,
  });

  factory ChatListUpdateEvent.fromJson(Map<String, dynamic> json) {
    return ChatListUpdateEvent(
      roomId: json['roomId'] as String,
      unreadCount: json['unreadCount'] as int? ?? 0,
      lastMessage: json['lastMessage'] as String?,
      lastMessageTime: parseBackendDateTime(
        json['lastMessageTime']?.toString(),
      ),
    );
  }
}

/// WebSocket service สำหรับ listen การเปลี่ยนแปลงใน chat list
/// รับ notification เมื่อมีข้อความใหม่, unread count เปลี่ยน
class ChatListSocketService {
  final String userId;
  final String? accessToken;

  ChatListSocketService({required this.userId, this.accessToken});

  final _updateController = StreamController<ChatListUpdateEvent>.broadcast();
  StompClient? _client;
  bool _connecting = false;
  bool _disposed = false;

  Stream<ChatListUpdateEvent> get updateStream => _updateController.stream;

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

    // Subscribe to user's chat list updates
    _client?.subscribe(
      destination: '/topic/chat/user/$userId',
      callback: (frame) {
        final body = frame.body;
        if (body == null) return;
        try {
          final json = jsonDecode(body) as Map<String, dynamic>;

          // Only process ChatListUpdateEvent messages (have unreadCount field)
          // Ignore other message types like SendMessageResponse
          if (!json.containsKey('unreadCount')) {
            return;
          }

          final event = ChatListUpdateEvent.fromJson(json);
          _updateController.add(event);
        } catch (e) {
          debugPrint('[ChatListSocket] Error parsing update: $e');
        }
      },
    );
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    Future.delayed(const Duration(seconds: 3), () {
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
      _updateController.close();
    } catch (_) {}
  }
}
