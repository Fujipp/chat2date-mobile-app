import 'dart:convert';
import 'dart:io';
import 'package:chat2date/services/preference_service.dart';
import 'package:http/http.dart' as http;
import 'package:chat2date/config/backend_base.dart'; // << เพิ่มบรรทัดนี้
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final backendOtpServiceProvider = Provider(
  (ref) => BackendOtpService(ref),
);

class BackendOtpService {
  final Ref ref;
  static String get _base => ApiBase.baseUrl; // << ใช้จากไฟล์ใหม่
  static const _headers = {'Content-Type': 'application/json'};
  static const _timeout = Duration(seconds: 15);

  BackendOtpService(this.ref);

  static Future<String> getDeviceId() async {
    final deviceInfoPlugin = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        if (androidInfo.id != null) return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        if (iosInfo.identifierForVendor != null) {
          return iosInfo.identifierForVendor!;
        }
      }
    } catch (_) {
      // ignore errors
    }

    // ❗ ถ้าไม่เจอ deviceId จริง → ใช้ fallback UUID
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString("fallback_device_id");

    if (saved != null) {
      return saved; // มี UUID เก่า → ใช้เลย
    }

    // ยังไม่มี → สร้างใหม่แล้วเก็บ
    final fallbackId = const Uuid().v4();
    await prefs.setString("fallback_device_id", fallbackId);
    return fallbackId;
  }

  static Future<String> sendOtp(String phoneNumber) async {
    final deviceId = await getDeviceId();
    final uri = Uri.parse('$_base/auth/request-otp');
    final res = await http
        .post(
          uri,
          headers: _headers,
          body: jsonEncode({'phoneNumber': phoneNumber, 'deviceId': deviceId}),
        )
        .timeout(_timeout);
    if (res.statusCode != 200) throw 'HTTP ${res.statusCode}: ${res.body}';
    final token = (jsonDecode(res.body)['token'] ?? '') as String;
    if (token.isEmpty) throw 'No token from backend';
    return token;
    //return "true";
  }

  Future<Map<String, dynamic>> validateOtp({
    required String token,
    required String code,
    required String phone,
    required bool onLogin,
  }) async {
    final uri = Uri.parse('$_base/auth/verify-otp');
    final res = await http
        .post(
          uri,
          headers: _headers,
          body: jsonEncode({
            'token': token,
            'otpCode': code,
            'phoneNumber': phone,
            'onLogin': onLogin,
          }),
        )
        .timeout(_timeout);
    await ref.read(preferenceServiceProvider).getPreference();
    return {'statusCode': res.statusCode, 'body': jsonDecode(res.body)};
  }
}
