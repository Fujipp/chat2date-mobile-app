import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat2date/config/backend_base.dart';
import 'package:chat2date/models/user.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'user_service.g.dart';

@riverpod
UserService userService(Ref ref) {
  return UserService(ref);
}

class UserService {
  final Ref ref;
  UserService(this.ref);

  Future<User> updateUser(User user) async {
    final userState = ref.read(userStoreProvider);
    final accessToken = "${userState['accessToken']}";

    final response = await http.put(
      Uri.parse('${ApiBase.baseUrl}/users/${user.userId}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Update failed: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return User.fromJson(data);
  }

  Future<User> addPreferenceUser(Map<String, Object> preference) async {
    final userState = ref.read(userStoreProvider);
    final accessToken = "${userState['accessToken']}";

    final response = await http.put(
      Uri.parse('${ApiBase.baseUrl}/users/preference'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Update failed: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return User.fromJson(data);
  }

  static Future<bool> checkPhone(String phone) async {
    // 1. แก้ไข Return Type เป็น Future<bool>
    final response = await http.post(
      Uri.parse('${ApiBase.baseUrl}/users/phone'),
      headers: {
        'Content-Type': 'application/json',
      }, // ต้องเพิ่ม header สำหรับ JSON
      // 2. แก้ไข body ให้เป็น Map ที่ถูกต้อง
      body: jsonEncode({'phoneNumber': phone}),
    );

    // 3. จัดการสถานะการตอบกลับ
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // คืนค่าตามการตอบกลับของ Backend
      if (data is bool) {
        return data;
      } else {
        throw Exception('Unexpected response format from server: expected boolean.');
      }
    }

    throw Exception(
      'Check phone failed with status ${response.statusCode}: ${response.body}',
    );
  }
}
