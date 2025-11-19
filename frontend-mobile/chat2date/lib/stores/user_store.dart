import 'dart:typed_data';

import 'package:chat2date/models/user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_store.g.dart';

@riverpod
class UserStore extends _$UserStore {
  @override
  Map<String, Object?> build() {
    return {'user': null, 'accessToken': null, 'cardFaceBytes': null};
  }

  void setUser(User user, String accessToken) {
    state = {...state, 'user': user, 'accessToken': accessToken};
  }

  void setCardFaceBytes(String bytes) {
    state = {...state, 'cardFaceBytes': bytes};
  }
}
