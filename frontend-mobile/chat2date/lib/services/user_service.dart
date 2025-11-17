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
}
