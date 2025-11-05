import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// IMPORT หน้าจริงที่มีแล้ว
import '../screens/splash/splash_page.dart';

// NOTE: ตอนนี้เรามีหน้า Splash แน่ ๆ ส่วน '/landing' ใส่ Placeholder ไว้ก่อน
// เดี๋ยวมีไฟล์จริงแล้วค่อยเปลี่ยน import + widget
class _LandingPlaceholder extends StatelessWidget {
  const _LandingPlaceholder();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Landing (placeholder)')));
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
    GoRoute(path: '/landing', builder: (_, __) => const _LandingPlaceholder()),

    // TIP: เพิ่มหน้าถัดไปได้แบบนี้
    // GoRoute(path: '/phone', builder: (_, __) => const PhonePage()),
    // GoRoute(path: '/otp', builder: (_, __) => const OtpPage()),
  ],
);
