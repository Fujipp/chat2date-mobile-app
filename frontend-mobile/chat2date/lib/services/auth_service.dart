import 'dart:convert';
import 'dart:developer' as developer;

import 'package:chat2date/config/backend_base.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final _storage = const FlutterSecureStorage();

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

        if (data['accessToken'] != null) {
          await _storage.write(key: 'accessToken', value: data['accessToken']);
        }

        if (data['refreshToken'] != null) {
          await _storage.write(
            key: 'refreshToken',
            value: data['refreshToken'],
          );
        }

        return {'userId': userId, 'email': email};
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
