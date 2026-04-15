import 'package:chat2date/models/user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_store.g.dart';

@Riverpod(keepAlive: true)
class UserStore extends _$UserStore {
  @override
  Map<String, Object?> build() {
    return {
      'user': null,
      'accessToken': null,
      'cardFaceBytes': null,
      'profile': null, // ข้อมูล profile จาก backend
      'preferences': null,
    };
  }

  String? get cardFaceBase64 => state['cardFaceBytes'] as String?;
  User? get user => state['user'] as User?;
  String? get accessToken => state['accessToken'] as String?;
  Map<String, dynamic>? get profile =>
      state['profile'] as Map<String, dynamic>?;
  Map<String, dynamic>? get preferences =>
      state['preferences'] as Map<String, dynamic>?;

  void setUser(User user, String accessToken) {
    state = {...state, 'user': user, 'accessToken': accessToken};
  }

  void setAccessToken(String token) {
    state = {...state, 'accessToken': token};
  }

  void setCardFaceBytes(String bytes) {
    state = {...state, 'cardFaceBytes': bytes};
  }

  void setProfile(Map<String, dynamic> profileData) {
    state = {...state, 'profile': profileData};
  }

  void setPreferences(Map<String, dynamic> pref) {
    state = {...state, 'preferences': pref};
  }

  void clearUser() {
    state = {
      'user': null,
      'accessToken': null,
      'cardFaceBytes': null,
      'profile': null,
      'preferences': null,
    };
  }
}
