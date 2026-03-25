import 'dart:convert';
import 'dart:io';

import 'package:chat2date/components/dialogs/restore_account_dialog.dart';
import 'package:chat2date/components/toasts/toast.dart';
import 'package:chat2date/config/backend_base.dart'; // << เพิ่มบรรทัดนี้
import 'package:chat2date/services/preference_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

final backendOtpServiceProvider = Provider((ref) => BackendOtpService(ref));

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
        return androidInfo.id;
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

  static Future<String> sendOtp(
    String phoneNumber,
    BuildContext context,
  ) async {
    final deviceId = await getDeviceId();
    final uri = Uri.parse('$_base/auth/request-otp');
    final res = await http
        .post(
          uri,
          headers: _headers,
          body: jsonEncode({'phoneNumber': phoneNumber, 'deviceId': deviceId}),
        )
        .timeout(_timeout);

    if (res.statusCode == 403) {
      final data = jsonDecode(res.body);

      if (data['error'] == 'ACCOUNT_DELETED' && context.mounted) {
        final userId = data['userId'] ?? '';
        final daysRemaining = data['daysRemaining'] ?? 30;

        await RestoreAccountDialog.show(
          context,
          userId: userId,
          daysRemaining: daysRemaining,
        );

        throw Exception('ACCOUNT_DELETED');
      }

      if (data['message'] == 'ACCOUNT_SUSPENDED') {
        if (context.mounted) {
          Toast.show(
            context,
            type: ToastType.error,
            title: 'บัญชีถูกระงับ',
            message:
                'ขออภัย บัญชีของคุณถูกระงับการใช้งาน',
          );
          return '';
        }
      }
    }
    final phone = (jsonDecode(res.body)['phoneNumber'] ?? '') as String;
    if (phone.isEmpty) throw 'No phone from backend';
    return phone;
  }

  Future<Map<String, dynamic>> validateOtp({
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
