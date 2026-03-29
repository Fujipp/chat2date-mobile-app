import 'dart:convert';

import 'package:chat2date/config/backend_base.dart';
import 'package:chat2date/screens/date/discovery_screen.dart';
import 'package:chat2date/screens/home/home_login_page.dart';
import 'package:chat2date/services/user_service.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// ---- Refresh Token Function ----
Future<Map<String, dynamic>> tryRefresh(WidgetRef ref) async {
  final storage = const FlutterSecureStorage();
  final refreshToken = await storage.read(key: "refreshToken");
  if (refreshToken == null) return {'success': false};

  try {
    final res = await http.post(
      Uri.parse("${ApiBase.baseUrl}/auth/refresh-token"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refreshToken": refreshToken}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final newAccessToken = data["accessToken"];

      await storage.write(key: "access_token", value: newAccessToken);
      if (data["refreshToken"] != null) {
        await storage.write(key: "refreshToken", value: data["refreshToken"]);
      }
      ref.read(userStoreProvider.notifier).setAccessToken(newAccessToken);

      return {'success': true, 'accessToken': newAccessToken};
    }

    if (res.statusCode == 403) {
      final data = jsonDecode(res.body);

      if (data['error'] == 'ACCOUNT_DELETED') {
        return {
          'success': false,
          'accountDeleted': true,
          'userId': data['userId'],
          'daysRemaining': data['daysRemaining'],
          'canRestore': data['canRestore'],
          'deletedAt': data['deletedAt'],
        };
      }

      return {'success': false, 'accountDeleted': false};
    }

    return {'success': false};
  } catch (e) {
    print('❌ Refresh token error: $e');
    return {'success': false};
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

    if (refreshToken == null) {
      _goLogin();
      return;
    }

    // STEP 1 — Refresh token
    final refreshResult = await tryRefresh(ref);

    // บัญชีถูกลบ → popup
    if (refreshResult['accountDeleted'] == true) {
      _showRestoreDialog(
        userId: refreshResult['userId'],
        daysRemaining: refreshResult['daysRemaining'],
      );
      return;
    }

    // Refresh fail → กลับไป login
    if (refreshResult['success'] != true) {
      _goLogin();
      return;
    }

    // STEP 2 — load userId จาก storage
    final userId = await storage.read(key: "userId");
    if (userId == null) {
      _goLogin();
      return;
    }

    // STEP 3 — load user จาก backend
    final user = await ref.read(userServiceProvider).getUser(userId);
    // ignore: unnecessary_null_comparison
    if (user == null) {
      _goLogin();
      return;
    }

    final profile = ref.read(userServiceProvider)..getProfile();
    // ignore: unnecessary_null_comparison, dead_code
    if (profile == null) {
      _goLogin();
      return;
    }

    // STEP 4 — เก็บ user ลง Riverpod store
    ref
        .read(userStoreProvider.notifier)
        .setUser(user, refreshResult['accessToken']);

    // STEP 5 — เข้าบ้าน
    _goHome();
  }

  void _showRestoreDialog({
    required String userId,
    required int daysRemaining,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('บัญชีของคุณถูกระงับ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('บัญชีของคุณถูกระงับชั่วคราว'),
              const SizedBox(height: 12),
              Text(
                'คุณยังสามารถกู้คืนบัญชีได้อีก $daysRemaining วัน',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF8C00),
                ),
              ),
              const SizedBox(height: 12),
              const Text('ต้องการกู้คืนบัญชีหรือไม่?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _goLogin();
              },
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                // แสดง loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                );

                try {
                  // เรียก API กู้คืน
                  final accessToken = await storage.read(key: 'access_token');
                  final response = await http.post(
                    Uri.parse('${ApiBase.baseUrl}/users/$userId/restore'),
                    headers: {
                      'Authorization': 'Bearer $accessToken',
                      'Content-Type': 'application/json',
                    },
                  );

                  // ปิด loading
                  if (mounted) Navigator.of(context).pop();

                  if (response.statusCode == 200) {
                    // ✅ ลบ tokens ออกจาก storage
                    await storage.delete(key: 'access_token');
                    await storage.delete(key: 'refreshToken');

                    // ✅ แสดง Toast สำเร็จ
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'กู้คืนบัญชีสำเร็จ โปรดล็อกอินอีกครั้ง',
                          ),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 3),
                        ),
                      );

                      // รอให้ Toast แสดง แล้วไปหน้า Login
                      await Future.delayed(const Duration(milliseconds: 500));
                      _goLogin();
                    }
                  } else {
                    // กู้คืนไม่สำเร็จ
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'ไม่สามารถกู้คืนบัญชีได้ กรุณาลองใหม่อีกครั้ง',
                          ),
                        ),
                      );
                      _goLogin();
                    }
                  }
                } catch (e) {
                  // ปิด loading
                  if (mounted) Navigator.of(context).pop();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
                    );
                    _goLogin();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5ce1e6),
              ),
              child: const Text('กู้คืนบัญชี'),
            ),
          ],
        );
      },
    );
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DiscoveryScreen()),
    );
  }

  void _goLogin() {
    if (!mounted) return;
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
