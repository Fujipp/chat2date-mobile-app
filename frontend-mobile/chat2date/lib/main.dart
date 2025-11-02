import 'package:chat2date/theme/app_theme.dart';
import 'package:flutter/material.dart';

import 'screens/index.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Component Test',
      theme: buildLightTheme(),
      navigatorKey: navigatorKey,
      initialRoute: '/profile',
      routes: {
        '/test': (context) => const ComponentTestScreen(),
        '/profile': (context) => const ProfileSetupScreen(),
      },
      //ปุ่มไว้สำหรับดู comp
      builder: (context, child) {
        return Stack(
          children: [
            child ?? const SizedBox(),
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                onPressed: () {
                  final nav = navigatorKey.currentState!;
                  if (nav.canPop()) {
                    nav.pop(); // 🔹 ถ้ามีหน้าก่อนหน้า -> กลับ
                  } else {
                    nav.pushNamed(
                      '/test',
                    ); // 🔹 ถ้ายังอยู่หน้าแรก -> ไปหน้า test
                  }
                },
                backgroundColor: Colors.blueAccent,
                heroTag: 'globalTestBtn',
                child: const Icon(Icons.help, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
