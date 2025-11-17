import 'dart:async';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  // ใช้ path เดียวกับ HomeLoginPage
  static const _logoPath = 'assets/images/logo_chat2date_text.png';

  @override
  void initState() {
    super.initState();

    // ดีเลย์แล้วเด้งไปหน้า HomeLogin
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ โหลด PNG ตรง ๆ แบบเดียวกับ HomeLoginPage
            Image.asset(
              _logoPath,
              width: 250,
              height: 250,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const FlutterLogo(size: 120),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.6),
            ),
          ],
        ),
      ),
    );
  }
}
