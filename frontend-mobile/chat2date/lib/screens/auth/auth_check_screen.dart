import 'dart:convert';

import 'package:chat2date/config/backend_base.dart';
import 'package:chat2date/screens/date/discovery_screen.dart';
import 'package:chat2date/screens/home/home_login_page.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// ---- Refresh Token Function ----
Future<bool> tryRefresh(WidgetRef ref) async {
  final storage = const FlutterSecureStorage();

  // โหลด refresh token จาก storage
  final refreshToken = await storage.read(key: "refreshToken");
  if (refreshToken == null) return false;

  try {
    final res = await http.post(
      Uri.parse("${ApiBase.baseUrl}/auth/refresh-token"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refreshToken": refreshToken}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      final newAccessToken = data["accessToken"];
      if (newAccessToken == null) return false;

      // เก็บ access token ใหม่ลง storage
      await storage.write(key: "access_token", value: newAccessToken);

      // อัปเดต accessToken ลง Riverpod UserStore
      ref.read(userStoreProvider.notifier).setAccessToken(newAccessToken);

      return true;
    }

    return false;
  } catch (e) {
    return false;
  }
}

/// ---- Auth Check Page ----
class AuthCheckPage extends ConsumerStatefulWidget {
  const AuthCheckPage({super.key});

  @override
  ConsumerState<AuthCheckPage> createState() => _AuthCheckPageState();
}

class _AuthCheckPageState extends ConsumerState<AuthCheckPage> {
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final refreshToken = await storage.read(key: 'refreshToken');
    print('refreshToken: $refreshToken');

    if (refreshToken == null) {
      _goLogin();
      return;
    }

    final ok = await tryRefresh(ref);

    if (ok) {
      _goHome();
    } else {
      _goLogin();
    }
  }

  void _goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DiscoveryScreen()),
    );
  }

  void _goLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeLoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
