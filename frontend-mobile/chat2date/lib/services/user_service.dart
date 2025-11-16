import 'dart:convert';

import 'package:chat2date/config/backend_base.dart';
import 'package:chat2date/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

final _storage = const FlutterSecureStorage();

class UserService {
  static Future<User> updateUser(User user) async {
    final token = await _storage.read(key: 'accessToken');

    final response = await http.put(
      Uri.parse('${ApiBase.baseUrl}/users/${user.userId}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Update failed: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return User.fromJson(data);
  }
}
