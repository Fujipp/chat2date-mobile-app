// main.dart
import 'package:flutter/material.dart';

// เรียกใช้ Component ของเรา
import 'components/chat/spin_date_component.dart';
//import 'components/chat/partner_text_top_component.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Component Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: const Center(
        // เรียกใช้ component ของเรา
        child: SpinDateModeComponent(
          mode: 'single',
          prizes: [
            {'label': 'Café', 'color': const Color(0xFF81C784)},
            {'label': 'Restaurant', 'color': const Color(0xFF64B5F6)},
            {'label': 'Park', 'color': const Color(0xFFFFB74D)},
            {'label': 'Cinema', 'color': const Color(0xFFE57373)},
            {'label': 'Shopping Mall', 'color': const Color(0xFFBA68C8)},
            {'label': 'Museum', 'color': const Color(0xFF4DB6AC)},
            {'label': 'Beach', 'color': const Color(0xFF9575CD)},
            {'label': 'Random', 'color': const Color(0xFFA1887F)},
          ],
        ),
      ),
    );
  }
}
