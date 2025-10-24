import 'package:chat2date/components/card/generic_card.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Component Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ComponentTestScreen(), // เปลี่ยนบรรทัดนี้
    );
  }
}

// เพิ่มหน้าทดสอบ component
class ComponentTestScreen extends StatelessWidget {
  const ComponentTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Generic Card Test'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GenericCard(
            iconType: CardIconType.image,
            iconBackground: Colors.blue[50],
            title: 'Title',
            subtitle: 'Subtitle',
            actionType: CardActionType.button,
            buttonText: 'Button',
            onTap: () => print('Card tapped'),
            onButtonTap: () => print('Button tapped'),
          ),

          GenericCard(
            iconType: CardIconType.avatar,
            icon: Icons.person,
            iconBackground: Colors.blue[100],
            iconColor: Colors.blue[700],
            title: 'John Doe',
            subtitle: 'Software Engineer',
            actionType: CardActionType.button,
            buttonText: 'Follow',
            onButtonTap: () => print('Follow tapped'),
          ),

          GenericCard(
            iconType: CardIconType.icon,
            icon: Icons.favorite,
            iconColor: Colors.blue,
            iconBackground: const Color.fromARGB(255, 248, 247, 247),
            title: 'Favorites',
            subtitle: '24 items',
            actionType: CardActionType.chevron,
            onTap: () => print('Navigate to favorites'),
          ),

          const GenericCard(
            title: 'My Title',
            subtitle: 'My Subtitle',
            actionType: CardActionType.button,
            buttonText: 'Action',
          ),

          GenericCard(
            iconType: CardIconType.avatar,
            icon: Icons.person,
            iconBackground: Colors.grey[800],
            iconColor: Colors.white,
            title: 'Dark Avatar',
            subtitle: 'With dark theme',
          ),
        ],
      ),
    );
  }
}
