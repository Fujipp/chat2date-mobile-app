import 'package:chat2date/components/layout/menu_bar.dart';
import 'package:chat2date/features/chat/screens/chat_list_screen.dart';
import 'package:chat2date/features/discovery/screens/discovery_screen.dart';
import 'package:chat2date/features/menu/screens/profile_screen.dart';
import 'package:chat2date/features/settings/screens/settings_screen.dart';
import 'package:flutter/material.dart';

class MainTabs extends StatefulWidget {
  final int initialIndex;
  const MainTabs({super.key, this.initialIndex = 0});

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  late int _index;
  late List<Key> _pageKeys;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pageKeys = List<Key>.generate(4, (_) => UniqueKey());
  }

  Widget _buildPage(int i) {
    switch (i) {
      case 0:
        return DiscoveryScreen(key: _pageKeys[i], showBottomNav: false);
      case 1:
        return ChatListScreen(key: _pageKeys[i], showBottomNav: false);
      case 2:
        return ProfileScreen(key: _pageKeys[i], showBottomNav: false);
      case 3:
        return SettingsScreen(key: _pageKeys[i], showBottomNav: false);
      default:
        return const SizedBox.shrink();
    }
  }

  late final List<Widget> _pages = <Widget>[
    _buildPage(0),
    _buildPage(1),
    _buildPage(2),
    _buildPage(3),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _index,
        onTap: (i) {
          if (i == _index) {
            if (i == 0) {
              return;
            }

            setState(() {
              _pageKeys[i] = UniqueKey();
              _pages[i] = _buildPage(i);
            });
          } else {
            setState(() => _index = i);
          }
        },
      ),
    );
  }
}
