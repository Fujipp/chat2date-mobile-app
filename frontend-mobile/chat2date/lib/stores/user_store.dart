import 'package:chat2date/models/user.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod/riverpod.dart';
part 'user_store.g.dart';

@riverpod
class UserStore extends _$UserStore {
  @override
  Map<String, Object?> build() {
    return {
      'user': null,
      'accessToken': null,
    };
  }

  void setUser(User user, String accessToken) {
    state = {
      'user': user,
      'accessToken': accessToken,
    };
  }
}