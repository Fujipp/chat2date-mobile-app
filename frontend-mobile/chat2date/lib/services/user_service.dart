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

  Future<User> getUser(String id) async {
    final userState = ref.read(userStoreProvider);
    final accessToken = "${userState['accessToken']}";

    final response = await http.get(
      Uri.parse('${ApiBase.baseUrl}/users/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': accessToken,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Update failed: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return User.fromJson(data);
  }

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

  Future<Map<String, dynamic>> addPreferenceUser(
    Map<String, Object> preference,
  ) async {
    final userState = ref.read(userStoreProvider);
    final accessToken = "${userState['accessToken']}";

    final response = await http.post(
      Uri.parse('${ApiBase.baseUrl}/users/preference'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(preference),
    );

    if (response.statusCode != 200) {
      throw Exception('Update failed: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return data;
  }

  Future<Map<String, dynamic>> addPreferenceMatchUser(
    Map<String, Object> preferenceMatch,
  ) async {
    final userState = ref.read(userStoreProvider);
    final accessToken = "${userState['accessToken']}";

    final response = await http.post(
      Uri.parse('${ApiBase.baseUrl}/users/preferenceMatch'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(preferenceMatch),
    );

    if (response.statusCode != 200) {
      throw Exception('Update failed: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return data;
  }

  static Future<bool> checkPhone(String phone) async {
    final response = await http.post(
      Uri.parse('${ApiBase.baseUrl}/users/phone'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phoneNumber': phone}),
    );

    if (response.statusCode == 200) {
      // มี user → true
      final data = jsonDecode(response.body);
      return data != null; // Optional<User> → ถ้าไม่ null ถือว่ามี user
    }

    if (response.statusCode == 404) {
      // ไม่มี user → false
      return false;
    }

    // error อื่นที่ไม่คาดคิด
    throw Exception(
      'Check phone failed with status ${response.statusCode}: ${response.body}',
    );
  }

  Future<Map<String, dynamic>> getProfile(String id) async {
    final userState = ref.read(userStoreProvider);
    final accessToken = "${userState['accessToken']}";
    final response = await http.get(
      Uri.parse('${ApiBase.baseUrl}/users/$id/photo'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data; 
    }

    // error อื่นที่ไม่คาดคิด
    throw Exception(
      'Check phone failed with status ${response.statusCode}: ${response.body}',
    );
  }
}
