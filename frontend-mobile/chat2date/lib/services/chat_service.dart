import 'dart:convert';

import 'package:chat2date/config/backend_base.dart';
import 'package:chat2date/models/chat_access_status.dart';
import 'package:chat2date/models/chat_message.dart';
import 'package:chat2date/models/chat_room.dart';
import 'package:chat2date/models/chat_room_messages.dart';
import 'package:chat2date/models/match.dart';
import 'package:chat2date/models/user.dart' show User;
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// Provider for ChatService
final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService(ref);
});

class ChatService {
  final Ref ref;
  ChatService(this.ref);

  String _currentUserId(Map<String, Object?> userState) {
    final user = userState['user'];
    if (user is User) return user.userId;
    final profile = userState['profile'];
    if (profile is Map && profile['userId'] != null) {
      return profile['userId'].toString();
    }
    return '';
  }

  /// ดึงรายการห้องแชททั้งหมดของ user ปัจจุบัน
  /// GET /api/v1/chats/rooms
  Future<List<ChatRoom>> getChatRooms() async {
    final userState = ref.read(userStoreProvider);
    final accessToken = "${userState['accessToken']}";

    final uri = Uri.parse('${ApiBase.baseUrl}/chats/rooms');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> roomsJson = data['rooms'] ?? [];
      return roomsJson.map((json) => ChatRoom.fromJson(json)).toList();
    }

    if (response.statusCode == 401) {
      throw Exception('กรุณาเข้าสู่ระบบใหม่');
    }

    throw Exception('ไม่สามารถดึงรายการแชทได้: ${response.body}');
  }

  /// ดึงรายการข้อความในห้องแชท
  /// GET /api/v1/chats/{roomId}?paginate=0
  Future<ChatRoomMessages> getChatMessages(
    String roomId, {
    int paginate = 0,
  }) async {
    if (roomId.isEmpty) {
      throw Exception('ไม่พบ roomId สำหรับแชทนี้');
    }

    final userState = ref.read(userStoreProvider);
    final accessToken = "${userState['accessToken']}";
    final currentUserId = _currentUserId(userState);

    final uri = Uri.parse(
      '${ApiBase.baseUrl}/chats/$roomId?paginate=$paginate',
    );
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ChatRoomMessages.fromJson(
        json: data,
        currentUserId: currentUserId,
      );
    }

    if (response.statusCode == 401) {
      throw Exception('กรุณาเข้าสู่ระบบใหม่');
    }

    throw Exception('ไม่สามารถดึงข้อความแชทได้: ${response.body}');
  }

  /// ส่งข้อความ
  /// POST /api/v1/chats/send
  Future<ChatMessage> sendMessage({
    required String roomId,
    required String message,
  }) async {
    final userState = ref.read(userStoreProvider);
    final accessToken = "${userState['accessToken']}";
    final currentUserId = _currentUserId(userState);

    final uri = Uri.parse('${ApiBase.baseUrl}/chats/send');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'roomId': roomId,
        'message': message,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return ChatMessage.fromApi(
        json: data,
        currentUserId: currentUserId,
      );
    }

    if (response.statusCode == 401) {
      throw Exception('กรุณาเข้าสู่ระบบใหม่');
    }

    if (response.statusCode == 429) {
      throw Exception('ส่งข้อความถี่เกินไป กรุณารอสักครู่');
    }

    throw Exception('ส่งข้อความไม่สำเร็จ: ${response.body}');
  }

  /// เข้าห้อง (Mark as Read)
  /// POST /api/v1/chats/access
  Future<void> enterRoom(String roomId) async {
    final userState = ref.read(userStoreProvider);
    final accessToken = "${userState['accessToken']}";
    final userId = _currentUserId(userState);
    if (userId.isEmpty) {
      throw Exception('ไม่พบข้อมูลผู้ใช้');
    }

    final uri = Uri.parse('${ApiBase.baseUrl}/chats/access');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'roomId': roomId,
        'userId': userId,
        'type': 'ENTER',
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 409) {
      return;
    }

    if (response.statusCode == 401) {
      throw Exception('กรุณาเข้าสู่ระบบใหม่');
    }

    throw Exception('ไม่สามารถเข้าห้องได้: ${response.body}');
  }

  /// ออกจากห้อง
  /// PUT /api/v1/chats/access
  Future<void> exitRoom(String roomId) async {
    final userState = ref.read(userStoreProvider);
    final accessToken = "${userState['accessToken']}";
    final userId = _currentUserId(userState);
    if (userId.isEmpty) {
      return;
    }

    final uri = Uri.parse('${ApiBase.baseUrl}/chats/access');
    final response = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'roomId': roomId,
        'userId': userId,
        'type': 'EXIT',
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 409) {
      return;
    }
  }

  /// ดูสถานะสมาชิกในห้อง
  /// GET /api/v1/chats/access/{roomId}
  Future<ChatAccessStatus> getAccessStatus(String roomId) async {
    final userState = ref.read(userStoreProvider);
    final accessToken = "${userState['accessToken']}";
    final uri = Uri.parse('${ApiBase.baseUrl}/chats/access/$roomId');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ChatAccessStatus.fromJson(data as Map<String, dynamic>);
    }

    if (response.statusCode == 401) {
      throw Exception('กรุณาเข้าสู่ระบบใหม่');
    }

    throw Exception('ไม่สามารถดึงสถานะห้องได้: ${response.body}');
  }

  /// ดึงรายการ matches ทั้งหมดของ user ปัจจุบัน
  /// GET /api/v1/matches
  Future<List<Match>> getMatches() async {
    final userState = ref.read(userStoreProvider);
    final accessToken = "${userState['accessToken']}";

    final uri = Uri.parse('${ApiBase.baseUrl}/matches');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> matchesJson = data['matches'] ?? [];
      return matchesJson.map((json) => Match.fromJson(json)).toList();
    }

    if (response.statusCode == 401) {
      throw Exception('กรุณาเข้าสู่ระบบใหม่');
    }

    throw Exception('ไม่สามารถดึงรายการ matches ได้: ${response.body}');
  }
}
