import 'dart:convert';

import 'package:chat2date/core/config/backend_base.dart';
import 'package:chat2date/core/utils/authenticated_client.dart';
import 'package:chat2date/models/user.dart';
import 'package:chat2date/services/auth_service.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  Future<User?> fetchUserById(String id) async {
    final client = ref.read(authenticatedClientProvider);

    final response = await client.get(
      Uri.parse('${ApiBase.baseUrl}/users/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Fetch user failed: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return User.fromJson(data);
  }

  Future<User?> getUser(String id) async {
    final client = ref.read(authenticatedClientProvider);

    final response = await client.get(
      Uri.parse('${ApiBase.baseUrl}/users/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Update failed: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final currentUser = User.fromJson(data);
    
    // ดึง accessToken ล่าสุดจาก store (เผื่อถูก refresh ไปแล้ว)
    final accessToken = ref.read(userStoreProvider.notifier).accessToken ?? '';
    final userStoreNotifier = ref.read(userStoreProvider.notifier);
    userStoreNotifier.setUser(currentUser, accessToken);

    return User.fromJson(data);
  }

  Future<User> updateUser(User user) async {
    final client = ref.read(authenticatedClientProvider);

    final response = await client.put(
      Uri.parse('${ApiBase.baseUrl}/users/${user.userId}'),
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Update failed: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final updatedUser = User.fromJson(data);
    
    final accessToken = ref.read(userStoreProvider.notifier).accessToken ?? '';
    final userStoreNotifier = ref.read(userStoreProvider.notifier);
    userStoreNotifier.setUser(updatedUser, accessToken);
    
    return updatedUser;
  }

  Future<bool> deleteUser() async {
    try {
      final user = ref.read(userStoreProvider.notifier).user;
      final client = ref.read(authenticatedClientProvider);

      if (user == null) {
        throw Exception('User not logged in');
      }

      final response = await client.delete(
        Uri.parse('${ApiBase.baseUrl}/users/${user.userId}'),
      );

      if (response.statusCode == 204) {
        // ลบข้อมูล local
        await authService(ref).signOut();
        print('✅ Account deleted successfully');
        return true;
      } else {
        print('❌ Failed to delete account: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Delete account error: $e');
      return false;
    }
  }

  Future<void> restoreUser() async {
    try {
      final user = ref.read(userStoreProvider.notifier).user;
      final client = ref.read(authenticatedClientProvider);

      if (user == null) {
        throw Exception('User not logged in');
      }

      final response = await client.post(
        Uri.parse('${ApiBase.baseUrl}/users/${user.userId}/restore'),
      );

      if (response.statusCode == 200) {
        print('✅ Account been store');
      } else {
        throw Exception('Failed to restore account: ${response.body}');
      }
    } catch (e) {
      print('❌ error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addPreferenceUser(
    Map<String, Object> preference,
  ) async {
    final client = ref.read(authenticatedClientProvider);

    final response = await client.post(
      Uri.parse('${ApiBase.baseUrl}/users/preference'),
      body: jsonEncode(preference),
    );

    if (response.statusCode != 201) {
      throw Exception('Update failed: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return data;
  }

  Future<Map<String, dynamic>> addPreferenceMatchUser(
    Map<String, Object> preferenceMatch,
  ) async {
    final client = ref.read(authenticatedClientProvider);

    final response = await client.post(
      Uri.parse('${ApiBase.baseUrl}/users/preferenceMatch'),
      body: jsonEncode(preferenceMatch),
    );

    if (response.statusCode != 200) {
      throw Exception('Update failed: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return data;
  }

  // checkPhone ไม่เรียกผ่าน client ที่มี header เพราะยังไม่ login
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

  Future<Map<String, dynamic>> getProfile() async {
    final userStore = ref.read(userStoreProvider) as Map<String, dynamic>?;
    final user = userStore?['user'] as User?;
    final client = ref.read(authenticatedClientProvider);
    
    if (user == null) throw Exception('User not logged in');
    final userId = user.userId;

    final response = await client.get(
      Uri.parse('${ApiBase.baseUrl}/users/$userId/profile'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      ref
          .read(userStoreProvider.notifier)
          .setCardFaceBytes(data?['base64Card'] ?? '');
      ref.read(userStoreProvider.notifier).setProfile(data ?? {});
      return data ?? {};
    }

    // error อื่นที่ไม่คาดคิด
    throw Exception(
      'Failed with status ${response.statusCode}: ${response.body}',
    );
  }
}
