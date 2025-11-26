import 'dart:convert';
import 'dart:developer' as developer;

import 'package:chat2date/config/backend_base.dart';
import 'package:chat2date/models/user.dart';
import 'package:chat2date/services/preference_service.dart';
import 'package:chat2date/stores/user_store.dart';
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
    );

    _isInitialized = true;
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final userId = data['user']?['id'];
        final email = data['user']?['email'];
        final accountStatus = data['user']?['accountStatus'];
        final version = data['user']?['version']?.toString() ?? '0';
        // final name = data['user']?['name'];
        // final accountStatus = data['user']?['accountStatus'] ?? 'PENDING';

        if (userId != null) {
          await _storage.write(key: 'userId', value: userId);
          await _storage.write(key: 'version', value: version);
        }

        if (email != null) {
          await _storage.write(key: 'email', value: email);
        }

        // if (accountStatus != null) {
        //   await _storage.write(key: 'accountStatus', value: accountStatus);
        // }
        developer.log('DATA: $data', name: 'AuthService');

        final user = User(
          userId: userId,
          version: int.parse(version), // แปลง String เป็น int
        );

        if (data['accessToken'] != null) {
          //await _storage.write(key: 'accessToken', value: data['accessToken']);
          ref
              .read(userStoreProvider.notifier)
              .setUser(user, data['accessToken']);
          final userState = ref.watch(userStoreProvider);
          // print("                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       ${userState['accessToken']}");
          // ref
          //     .read(userStoreProvider.notifier)
          //     .setUser(user, data['accessToken']);
        }

        if (data['refreshToken'] != null) {
          await _storage.write(
            key: 'refreshToken',
            value: data['refreshToken'],
          );
        }

        await ref.read(preferenceServiceProvider).getPreference();

        return {
          'userId': userId,
          'email': email,
          'accountStatus': accountStatus,
          'version': int.parse(version),
        };
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['message'] ?? 'Login failed with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
