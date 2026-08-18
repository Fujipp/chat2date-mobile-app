import 'dart:ui';

import 'package:chat2date/components/design_system/buttons/ds_button.dart';
import 'package:chat2date/components/design_system/navigation/ds_bottom_nav_bar.dart';
import 'package:chat2date/components/design_system/organisms/ds_app_home_header.dart';
import 'package:chat2date/components/modal/feature_guide_modal.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:chat2date/core/theme/tokens/typography/body_text_styles.dart';
import 'package:chat2date/features/discovery/screens/main_tabs.dart';
import 'package:chat2date/features/settings/screens/widgets/delete_account_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/logout_modal.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  final bool showBottomNav;

  const SettingsScreen({super.key, this.showBottomNav = true});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const List<_SettingsEntry> _entries = [
    _SettingsEntry(
      title: 'บัญชีของฉัน',
      subtitle: 'จัดการบัญชีผู้ใช้และข้อมูลส่วนตัว',
      icon: Icons.account_circle_rounded,
      routeName: '/account-settings',
    ),
    _SettingsEntry(
      title: 'ตั้งค่าคู่ของคุณ',
      subtitle: 'กำหนดความชอบและเงื่อนไขของคู่ที่ต้องการ',
      icon: Icons.favorite_rounded,
      routeName: '/matchPreference',
      routeArguments: {'onUpdate': true},
    ),
    _SettingsEntry(
      title: 'คู่มือการใช้งาน',
      subtitle: 'เรียนรู้วิธีการใช้แอปพลิเคชัน',
      icon: Icons.menu_book_rounded,
      opensGuideModal: true,
    ),
    _SettingsEntry(
      title: 'เกี่ยวกับเรา',
      subtitle: 'ข้อมูลเกี่ยวกับแอปพลิเคชัน',
      icon: Icons.info_rounded,
      routeName: '/about',
    ),
    _SettingsEntry(
      title: 'ติดต่อเรา',
      subtitle: 'ช่องทางการติดต่อและสอบถามข้อมูล',
      icon: Icons.public_rounded,
      routeName: '/contact',
    ),
    _SettingsEntry(
      title: 'นโยบายความเป็นส่วนตัว',
      subtitle: 'ข้อกำหนดตกลงการใช้',
      icon: Icons.note_alt_rounded,
      routeName: '/policy',
    ),
  ];

  int _selectedIndex = 3;

  void _handleBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => MainTabs(initialIndex: index),
        transitionDuration: const Duration(milliseconds: 0),
        reverseTransitionDuration: const Duration(milliseconds: 0),
      ),
      (route) => false,
    );
  }

  Future<void> _openEntry(_SettingsEntry entry) async {
    if (entry.opensGuideModal) {
      await showGeneralDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierLabel: 'feature-guide',
        barrierColor: Colors.transparent,
        pageBuilder: (context, _, __) => Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: ColoredBox(
                  color: AppColors.overlay.withValues(alpha: 0.7),
                ),
              ),
            ),
            const FeatureGuideModal(),
          ],
        ),
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
              child: child,
            ),
          );
        },
      );
      return;
    }

    if (entry.routeName == null) {
      return;
    }

    await Navigator.pushNamed(
      context,
      entry.routeName!,
      arguments: entry.routeArguments,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            DsAppHomeHeader(
              action: const SizedBox.shrink(),
              showBottomBorder: true,
              bottomBorderSpacing: 10,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 24),
                child: Column(
                  children: [
                    for (final entry in _entries) ...[
                      _SettingsMenuCard(
                        title: entry.title,
                        subtitle: entry.subtitle,
                        icon: entry.icon,
                        onTap: () => _openEntry(entry),
                      ),
                      if (entry != _entries.last) const SizedBox(height: 10),
                    ],
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 26),
                      child: Column(
                        children: [
                          _SettingsActionButton(
                            label: 'ออกจากระบบ',
                            onPressed: () => showLogoutModal(context, ref),
                          ),
                          const SizedBox(height: 20),
                          _SettingsActionButton(
                            label: 'ลบบัญชี',
                            onPressed: () => showDeleteAccountModal(
                              context,
                              ref,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.showBottomNav
          ? CustomBottomNavBar(
              selectedIndex: _selectedIndex,
              onTap: _handleBottomNavTap,
            )
          : null,
    );
  }
}

class _SettingsMenuCard extends StatelessWidget {
  const _SettingsMenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: Icon(icon, size: 38, color: AppColors.surface),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppBodyTextStyles.body.copyWith(
                        fontSize: 16,
                        height: 22 / 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppBodyTextStyles.body.copyWith(
                        color: AppColors.textSupport,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsActionButton extends StatelessWidget {
  const _SettingsActionButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DsButton(
      label: label,
      onPressed: onPressed,
      variant: DsButtonVariant.error,
      size: DsButtonSize.md,
      width: double.infinity,
    );
  }
}

class _SettingsEntry {
  const _SettingsEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.routeName,
    this.routeArguments,
    this.opensGuideModal = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? routeName;
  final Object? routeArguments;
  final bool opensGuideModal;
}
