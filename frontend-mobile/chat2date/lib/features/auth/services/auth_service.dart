import 'dart:convert';
import 'dart:developer' as developer;

import 'package:chat2date/components/dialogs/restore_account_dialog.dart';
import 'package:chat2date/core/config/backend_base.dart';
import 'package:chat2date/models/user.dart';
import 'package:chat2date/services/preference_service.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_service.g.dart';

@riverpod
AuthService authService(Ref ref) {
  return AuthService(ref);
}

class AuthService {
  final Ref ref;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final _storage = const FlutterSecureStorage();
  AuthService(this.ref);

  bool _isInitialized = false;

  Future<void> _initializeGoogleSignIn() async {
    if (_isInitialized) return;

    await _googleSignIn.initialize(
      serverClientId:
          '51433966587-33hhoi1ungemr3b6p3nkn7p3tt130jop.apps.googleusercontent.com',
      clientId:
          '51433966587-87atkaev4sogi1k7rcq2fluhflo6ap11.apps.googleusercontent.com',
    );

    _isInitialized = true;
  }

  Future<Map<String, dynamic>> loginWithGoogle(BuildContext context) async {
    try {
      await _initializeGoogleSignIn();

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Failed to get Google ID Token');
      }

      developer.log('ID Token: $idToken', name: 'AuthService');

      final response = await http.post(
        Uri.parse('${ApiBase.baseUrl}/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      // ✅ เช็คว่าเป็น response แบบ error หรือไม่
      if (response.statusCode == 403) {
        final data = jsonDecode(response.body);

        if (data['error'] == 'ACCOUNT_DELETED' && context.mounted) {
          await RestoreAccountDialog.show(
            context,
            userId: data['userId'],
            daysRemaining: data['daysRemaining'],
          );
          return {'error': 'ACCOUNT_DELETED'};
        }
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final userJson = data['user'];
        if (userJson == null) {
          throw Exception('User data not found in response');
        }
        final user = User.fromJson(userJson);
        final email = user.email;
        final accountStatus = user.accountStatus;
        final version = user.version?.toString() ?? '0';

        if (user.userId.isNotEmpty) {
          await _storage.write(key: 'userId', value: user.userId);
          await _storage.write(key: 'version', value: version);
        }

        if (email != null) {
          await _storage.write(key: 'email', value: email);
        }

        developer.log('DATA: $data', name: 'AuthService');

        final accessToken = data['accessToken'] ?? data['access_token'];
        if (accessToken != null) {
          ref
              .read(userStoreProvider.notifier)
              .setUser(user, accessToken);

          // เก็บ access token ลง storage
          await _storage.write(key: 'access_token', value: accessToken);
        }

        final refreshToken = data['refreshToken'] ?? data['refresh_token'];
        if (refreshToken != null) {
          await _storage.write(
            key: 'refreshToken',
            value: refreshToken,
          );
        }

        await ref.read(preferenceServiceProvider).getPreference();

        return {
          'userId': user.userId,
          'email': userJson['email'],
          'accountStatus': userJson['accountStatus'],
          'version': user.version,
        };
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['message'] ?? 'Login failed with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Google Sign-In Error: $e');

      final String errorMessage = _getGoogleSignInErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  String _getGoogleSignInErrorMessage(dynamic error) {
    final errorStr = error.toString();

    if (errorStr.contains('canceled') ||
        errorStr.contains('cancelled') ||
        errorStr.contains('Cancelled by user')) {
      return 'ยกเลิกการเข้าสู่ระบบ';
    }

    if (errorStr.contains('network_error') ||
        errorStr.contains('NetworkError') ||
        errorStr.contains('SocketException')) {
      return 'ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้ กรุณาตรวจสอบการเชื่อมต่อ';
    }

    if (errorStr.contains('sign_in_failed') ||
        errorStr.contains('ApiException: 10')) {
      return 'เกิดข้อผิดพลาดในการเข้าสู่ระบบด้วย Google กรุณาลองใหม่อีกครั้ง';
    }

    if (errorStr.contains('sign_in_required') ||
        errorStr.contains('ApiException: 4')) {
      return 'กรุณาเข้าสู่ระบบด้วยบัญชี Google ของคุณ';
    }

    if (errorStr.contains('Failed to get Google ID Token')) {
      return 'ไม่สามารถยืนยันตัวตนกับ Google ได้ กรุณาลองใหม่อีกครั้ง';
    }

    if (errorStr.contains('Login failed')) {
      return 'เข้าสู่ระบบไม่สำเร็จ กรุณาลองใหม่อีกครั้ง';
    }

    return 'เกิดข้อผิดพลาดที่ไม่คาดคิด กรุณาลองใหม่อีกครั้ง';
  }

  Future<void> signOut() async {
    try {
      final accessToken = ref.read(userStoreProvider.notifier).accessToken;
      final refreshToken = await _storage.read(key: 'refreshToken');

      if (accessToken != null) {
        await http.post(
          Uri.parse('${ApiBase.baseUrl}/auth/logout'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'refreshToken': refreshToken}),
        );
      }

      await _storage.delete(key: 'refreshToken');
      await _storage.deleteAll();

      ref.read(userStoreProvider.notifier).state = {
        'user': null,
        'accessToken': null,
        'cardFaceBytes': null,
        'profile': null,
        'preferences': null,
      };

      debugPrint('✅ Signed out successfully');
    } catch (e) {
      debugPrint('❌ Sign out error: $e');

      await _storage.delete(key: 'refreshToken');
      await _storage.deleteAll();

      ref.read(userStoreProvider.notifier).state = {
        'user': null,
        'accessToken': null,
        'cardFaceBytes': null,
        'profile': null,
        'preferences': null,
      };

      rethrow;
    }
  }
}
