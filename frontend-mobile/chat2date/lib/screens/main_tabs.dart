import 'package:chat2date/components/layout/menu_bar.dart';
import 'package:chat2date/screens/date/discovery_screen.dart';
import 'package:chat2date/screens/menu/profile_screen.dart';
import 'package:chat2date/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';

class MainTabs extends StatefulWidget {
  final int initialIndex;
  const MainTabs({super.key, this.initialIndex = 0});

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  late final List<Widget> _pages = <Widget>[
    const DiscoveryScreen(showBottomNav: false),
    const _ChatPlaceholder(),
    const ProfileScreen(showBottomNav: false),
    const SettingsScreen(showBottomNav: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _ChatPlaceholder extends StatelessWidget {
  const _ChatPlaceholder();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Chat will be here')));
  }
}
