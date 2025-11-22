import 'package:chat2date/models/user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_store.g.dart';

@Riverpod(keepAlive: true)
class UserStore extends _$UserStore {
  @override
  Map<String, Object?> build() {
    return {'user': null, 'accessToken': null, 'cardFaceBytes': null};
  }

  String? get cardFaceBase64 => state['cardFaceBytes'] as String?;
  User? get user => state['user'] as User?;
  String? get accessToken => state['accessToken'] as String?;

  void setUser(User user, String accessToken) {
    state = {...state, 'user': user, 'accessToken': accessToken};
  }

  void setCardFaceBytes(String bytes) {
    state = {...state, 'cardFaceBytes': bytes};
  }
}
