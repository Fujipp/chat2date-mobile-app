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
          '51433966587-h0ni6ia4jj6rvvohd28dr6rmd3bnki9l.apps.googleusercontent.com',
    );

    _isInitialized = true;
  }

  Future<String?> signInWithGoogle() async {
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
        body: jsonEncode({'id_token': idToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        await _storage.write(key: 'accessToken', value: data['accessToken']);
        await _storage.write(key: 'refreshToken', value: data['refreshToken']);

        return data['user']['id'];
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
