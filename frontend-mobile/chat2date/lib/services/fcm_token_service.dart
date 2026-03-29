// lib/services/fcm_token_service.dart
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:chat2date/config/backend_base.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat2date/services/authenticated_client.dart';

final fcmTokenServiceProvider = Provider(
  (ref) => FcmTokenService(ref),
);

class FcmTokenService {
  final Ref ref;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  FcmTokenService(this.ref);

  /// ขอ permission (iOS / Android 13+) + เอา FCM token ปัจจุบัน
  Future<String?> _getOrRequestToken() async {
    // Web ยังไม่ได้ทำ push ตอนนี้
    if (kIsWeb) {
      debugPrint('[FCM] Web platform, skip token');
      return null;
    }

    // ขอ permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('[FCM] Permission denied');
      return null;
    }

    final token = await _messaging.getToken();
    debugPrint('[FCM] Current token = $token');
    return token;
  }

  String _detectPlatform() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'other';
  }

  /// เรียกตอน login สำเร็จ / เข้า discovery ครั้งแรก
 Future<void> registerDeviceToken() async {
  debugPrint('[FCM] registerDeviceToken() start');

  final userState = ref.read(userStoreProvider);
  final user = userState['user'];
  final accessToken = userState['accessToken'] as String?;

  debugPrint('[FCM] user = $user, accessToken = ${accessToken != null}');

  if (user == null || accessToken == null) {
    throw Exception('User not logged in');
  }

  final userId = (user as dynamic).userId as String?;
  debugPrint('[FCM] userId = $userId');

  if (userId == null) {
    throw Exception('User ID is null');
  }

  final token = await _getOrRequestToken();
  debugPrint('[FCM] _getOrRequestToken() returned: $token');

  if (token == null) {
    throw Exception('FCM token is null');
  }

  final platform = _detectPlatform();
  debugPrint('[FCM] platform = $platform');

    final body = {
      'userId': userId,
      'fcmToken': token,
      'platform': platform,
    };

    final uri = Uri.parse('${ApiBase.baseUrl}/device-tokens/register');
    debugPrint('[FCM] POST $uri body=$body');

    final client = ref.read(authenticatedClientProvider);
    final res = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      debugPrint('[FCM] Register failed: ${res.statusCode} ${res.body}');
      try {
        final data = jsonDecode(res.body);
        throw Exception(data['message'] ?? 'Failed to register FCM token');
      } catch (_) {
        throw Exception('Failed to register FCM token: HTTP ${res.statusCode}');
      }
    }

    debugPrint('[FCM] Register success');
  }

  /// เวอร์ชันเงียบ ๆ เรียกจาก UI ได้ ไม่ทำให้จอเด้ง error
  Future<void> registerDeviceTokenSilently() async {
    try {
      await registerDeviceToken();
    } catch (e) {
      debugPrint('[FCM] Silent error: $e');
    }
  }

  /// ใช้ตอน logout ถ้าอยากลบ token ออกจาก backend ด้วย
  Future<void> removeDeviceToken() async {
    final userState = ref.read(userStoreProvider);
    final user = userState['user'];
    final accessToken = userState['accessToken'] as String?;

    if (user == null || accessToken == null) {
      throw Exception('User not logged in');
    }

    final userId = (user as dynamic).userId as String?;
    if (userId == null) {
      throw Exception('User ID is null');
    }

    final token = await _messaging.getToken();
    if (token == null) {
      debugPrint('[FCM] No token to remove');
      return;
    }

    final body = {
      'userId': userId,
      'fcmToken': token,
      'platform': _detectPlatform(),
    };

    final uri = Uri.parse('${ApiBase.baseUrl}/device-tokens/remove');
    debugPrint('[FCM] POST $uri body=$body');

    final client = ref.read(authenticatedClientProvider);
    final res = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      debugPrint('[FCM] Remove failed: ${res.statusCode} ${res.body}');
    } else {
      debugPrint('[FCM] Remove success');
    }
  }
}
