import 'package:chat2date/components/card/card_chat_component.dart';
import 'package:chat2date/components/chat/content_switcher.dart';
import 'package:chat2date/components/layout/header.dart';
import 'package:chat2date/components/layout/menu_bar.dart';
import 'package:chat2date/screens/main_tabs.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatefulWidget {
  final bool showBottomNav;

  const ChatListScreen({super.key, this.showBottomNav = true});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  int _selectedIndex = 1;
  int selectedIndex1 = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 25),
          ChatToDateHeaderWhite(
            leftIconPath: 'assets/icons/icon_chat2date_full.svg',
            rightIconPath: '',
            iconColor: const Color(0xFF5ce1e6),
            onBack: () async => true,
            onSettings: () async => true,
          ),
          const SizedBox(height: 10),
          ContentSwitcher(
            items: const ['CHAT', 'MATCH'],
            selectedIndex: selectedIndex1,
            onChanged: (index) => setState(() => selectedIndex1 = index),
          ),
          const SizedBox(height: 10),

          // แสดงเนื้อหาตาม tab ที่เลือก
          Expanded(
            child: selectedIndex1 == 0 ? _buildChatTab() : _buildMatchTab(),
          ),
        ],
      ),
      bottomNavigationBar: widget.showBottomNav
          ? CustomBottomNavBar(
              selectedIndex: _selectedIndex,
              onTap: (index) {
                if (!mounted) return;
                setState(() => _selectedIndex = index);
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => MainTabs(initialIndex: index),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
            )
          : null,
    );
  }

  Widget _buildChatTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        CardChatComponent(
          svgPath: 'assets/icons/icon_avatar.svg',
          title: 'Ava Martinez',
          subtitle: 'What time works for you?',
          svgPathEnd: 'assets/icons/icon_unseen-message.svg',
          widthSvgEnd: 33,
          heightSvgEnd: 33,
          onClick: () {
            print('Open chat with Ava (has unread messages)');
          },
        ),

        const SizedBox(height: 10),

        CardChatComponent(
          svgPath: 'assets/icons/icon_avatar.svg',
          title: 'Sassy',
          subtitle: 'Nuna',
          svgPathEnd: 'assets/icons/icon_new-white.svg',
        ),
        const SizedBox(height: 10),
        CardChatComponent(
          svgPath: 'assets/icons/icon_avatar.svg',
          title: 'Sassy',
          subtitle: 'Nuna',
          colors: [AppColors.backgroundWhite],
        ),

        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildMatchTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        CardChatComponent(
          svgPath: 'assets/icons/icon_avatar.svg',
          title: 'แอมจิฮัช (99)',
          subtitle: 'แมทต์เมื่อวันที่ 22 กันยายน 2025',
          svgPathEnd: 'assets/icons/icon_new-white.svg',
        ),
        CardChatComponent(
          svgPath: 'assets/icons/icon_avatar.svg',
          title: 'แอมจิฮัช (99)',
          subtitle: 'แมทต์เมื่อวันที่ 22 กันยายน 2025',
          colors: [AppColors.backgroundWhite],
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}
