import 'package:chat2date/components/card/generic_card.dart';
import 'package:chat2date/components/chat/content_switcher.dart';
import 'package:chat2date/components/layout/header.dart';
import 'package:flutter/material.dart';

class ComponentTestScreen extends StatefulWidget {
  const ComponentTestScreen({Key? key}) : super(key: key);

  @override
  State<ComponentTestScreen> createState() => _ComponentTestScreenState();
}

class _ComponentTestScreenState extends State<ComponentTestScreen> {
  int selectedIndex1 = 1; // เริ่มที่ Section 2
  int selectedIndex2 = 1; // เริ่มที่ Tab 2
  int selectedIndex3 = 1; // เริ่มที่ icon people
  int selectedIndex4 = 0; // เริ่มที่ Name A

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
          // Generic Cards
          const Text(
            'Generic_card',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          GenericCard(
            iconType: CardIconType.image,
            //iconBackground: Colors.blue[50],
            title: 'Title',
            subtitle: 'Subtitle',
            actionType: CardActionType.button,
            buttonText: 'Button',
            onTap: () => print('Card tapped'),
            onButtonTap: () => print('Button tapped'),
          ),
          GenericCard(
            iconType: CardIconType.image,
            //iconBackground: Colors.blue[50],
            title: 'Title',
            subtitle: 'Subtitle',
            actionType: CardActionType.chevron,
            onTap: () => print('Card tapped'),
          ),
          GenericCard(
            iconType: CardIconType.image,
            //iconBackground: Colors.blue[50],
            title: 'Title',
            subtitle: 'Subtitle',
            onTap: () => print('Card tapped'),
          ),
          const SizedBox(height: 8),
          GenericCard(
            iconType: CardIconType.avatar,
            //iconBackground: Colors.blue[100],
            icon: Icons.person,
            iconColor: Colors.blue[700],
            title: 'Title',
            subtitle: 'Subtitle',
            actionType: CardActionType.button,
            buttonText: 'Button',
            onButtonTap: () => print('Button tapped'),
          ),
          GenericCard(
            iconType: CardIconType.avatar,
            //iconBackground: Colors.blue[100],
            icon: Icons.person,
            iconColor: Colors.blue[700],
            title: 'Title',
            subtitle: 'Subtitle',
            actionType: CardActionType.chevron,
            onTap: () => print('Card tapped'),
          ),
          GenericCard(
            iconType: CardIconType.avatar,
            icon: Icons.person,
            iconColor: Colors.blue[700],
            title: 'Title',
            subtitle: 'Subtitle',
          ),
          GenericCard(
            iconType: CardIconType.avatar,
            //iconBackground: Colors.grey[800],
            icon: Icons.person,
            iconColor: Colors.white,
            title: 'Title',
            subtitle: 'Subtitle',
          ),
          const SizedBox(height: 8),
          GenericCard(
            iconType: CardIconType.icon,
            icon: Icons.favorite,
            iconColor: Colors.blue,
            //iconBackground: Colors.blue[50],
            title: 'Title',
            subtitle: 'Subtitle',
            actionType: CardActionType.button,
            buttonText: 'Button',
            onButtonTap: () => print('Button tapped'),
          ),
          GenericCard(
            iconType: CardIconType.icon,
            icon: Icons.favorite,
            iconColor: Colors.blue,
            //iconBackground: Colors.blue[50],
            title: 'Title',
            subtitle: 'Subtitle',
            actionType: CardActionType.chevron,
            onTap: () => print('Card tapped'),
          ),
          GenericCard(
            iconType: CardIconType.icon,
            title: 'Title',
            subtitle: 'Subtitle',
          ),
          const SizedBox(height: 8),
          const GenericCard(
            title: 'Title',
            subtitle: 'Subtitle',
            actionType: CardActionType.button,
            buttonText: 'Button',
          ),
          const GenericCard(
            title: 'Title',
            subtitle: 'Subtitle',
            actionType: CardActionType.chevron,
          ),
          const GenericCard(title: 'Title', subtitle: 'Subtitle'),

          // Headers
          const Text(
            'Headers',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Header(
            name: 'John Doe',
            showCalendar: true,
            showSpinwheel: true,
            showFlag: true,
            onBack: () => print('Back pressed'),
          ),
          SizedBox(height: 16),
          Header(
            name: 'เบรโต',
            showCalendar: true,
            showSpinwait: true,
            showFlag: true,
          ),
          SizedBox(height: 16),
          Header(name: 'User 3', showFlag: true),
          SizedBox(height: 16),
          Header(name: 'โมจิกิ', showOptions: true),
          SizedBox(height: 16),
          ChatToDateHeaderWhite(
            leftIconPath: 'assets/icons/icon_chat2date_full.svg',
            rightIconPath: 'assets/icons/icon_menu.svg',
            iconColor: Color(0xFF5ce1e6),
            onBack: () {},
            onSettings: () {},
          ),
          SizedBox(height: 16),
          ChatToDateHeaderGradient(
            leftIconPath: 'assets/icons/icon_chat2date_full.svg',
            rightIconPath: 'assets/icons/icon_menu.svg',
            iconColor: Colors.white,
            onBack: () {},
            onSettings: () {},
          ),

          // Content Switchers
          const Text(
            'Content Switchers',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ContentSwitcher(
            items: const ['Section 1', 'Section 2'],
            selectedIndex: selectedIndex1,
            onChanged: (index) => setState(() => selectedIndex1 = index),
          ),
          const SizedBox(height: 12),

          ContentSwitcher(
            items: const ['Tab 1', 'Tab 2', 'Tab 3', 'Tab 4'],
            selectedIndex: selectedIndex2,
            onChanged: (index) => setState(() => selectedIndex2 = index),
          ),
          const SizedBox(height: 12),

          IconSwitcher(
            selectedIndex: selectedIndex3,
            onChanged: (index) => setState(() => selectedIndex3 = index),
          ),
          const SizedBox(height: 12),

          NameSwitcher(
            items: const ['Name A', 'Name B'],
            selectedIndex: selectedIndex4,
            onChanged: (index) => setState(() => selectedIndex4 = index),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
