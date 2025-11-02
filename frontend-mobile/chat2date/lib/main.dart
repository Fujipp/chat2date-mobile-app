import 'package:chat2date/theme/app_theme.dart'; // <— เพิ่ม
import 'package:flutter/material.dart';

import 'screens/index.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Component Test',
      theme: buildLightTheme(),
      initialRoute: '/test',
      routes: {
        '/test': (context) => const ComponentTestScreen(),
        '/profile': (context) => const ProfileSetupScreen(),
      },
      // home: ComponentTestScreen(),
    );
  }
}
