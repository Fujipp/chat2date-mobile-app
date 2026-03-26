import 'package:chat2date/components/layout/header.dart';
import 'package:chat2date/components/modal/feature_guide_modal.dart';
import 'package:chat2date/screens/settings/widgets/delete_account_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../components/layout/menu_bar.dart';
import '../main_tabs.dart';
import 'widgets/logout_modal.dart';

// ✅ เปลี่ยนจาก StatefulWidget เป็น ConsumerStatefulWidget
class SettingsScreen extends ConsumerStatefulWidget {
  final bool showBottomNav;
  const SettingsScreen({super.key, this.showBottomNav = true});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _selectedIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 25),
          ChatToDateHeaderWhite(
            leftIconPath: 'assets/icons/ui/icon_chat2date_full.svg',
            rightIconPath: '',
            iconColor: const Color(0xFF5ce1e6),
            onBack: () {},
          ),

          // Content area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // Account
                  _SettingsCard(
                    icon: Icons.person_outline,
                    title: 'บัญชีของฉัน',
                    subtitle: 'จัดการบัญชีผู้ใช้และข้อมูลส่วนตัว',
                    onTap: () {
                      Navigator.pushNamed(context, '/account-settings');
                    },
                  ),
                  const SizedBox(height: 12),

                  // 🆕 Partner Preferences
                  _SettingsCard(
                    icon: Icons.favorite_border,
                    title: 'ตั้งค่าคู่ของคุณ',
                    subtitle: 'กำหนดความชอบและเงื่อนไขของคู่ที่ต้องการ',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/matchPreference',
                        arguments: {"onUpdate": true},
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Tutorial
                  _SettingsCard(
                    icon: Icons.menu_book_outlined,
                    title: 'คู่มือการใช้งาน',
                    subtitle: 'เรียนรู้วิธีใช้แอปพลิเคชัน',
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const FeatureGuideModal(),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // About
                  _SettingsCard(
                    icon: Icons.info_outline,
                    title: 'เกี่ยวกับเรา',
                    subtitle: 'ข้อมูลเกี่ยวกับแอปพลิเคชัน',
                    onTap: () {
                      Navigator.pushNamed(context, '/about');
                    },
                  ),
                  const SizedBox(height: 12),

                  // Contact
                  _SettingsCard(
                    icon: Icons.support_agent_outlined,
                    title: 'ติดต่อเรา',
                    subtitle: 'ช่องทางการติดต่อ Admin และทีมงาน',
                    onTap: () {
                      Navigator.pushNamed(context, '/contact');
                    },
                  ),
                  const SizedBox(height: 12),

                  // Privacy & Terms
                  _SettingsCard(
                    icon: Icons.privacy_tip_outlined,
                    title: 'นโยบายความเป็นส่วนตัว',
                    subtitle: 'เงื่อนไขการใช้งานและนโยบาย',
                    onTap: () {
                      Navigator.pushNamed(context, '/privacy-policy');
                    },
                  ),

                  const SizedBox(height: 32),

                  // ✅ Logout Button - ใช้ ref ได้แล้ว
                  _ActionButton(
                    label: 'ออกจากระบบ',
                    color: const Color(0xFFFF6B6B),
                    onTap: () {
                      showLogoutModal(context, ref);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Delete Account Button
                  _ActionButton(
                    label: 'ลบบัญชี',
                    color: const Color(0xFFEF4444),
                    onTap: () {
                      showDeleteAccountModal(context, ref);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.showBottomNav
          ? CustomBottomNavBar(
              selectedIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });

                // Jump back into the persistent tab shell without route animation
                Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => MainTabs(initialIndex: index),
                    transitionDuration: const Duration(milliseconds: 0),
                    reverseTransitionDuration: const Duration(milliseconds: 0),
                  ),
                  (route) => false,
                );
              },
            )
          : null,
    );
  }
}

// Settings Card Widget
class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: const Color(0xFFF7FAFE),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: const Color(0xFF5ce1e6)),
            ),
            const SizedBox(width: 16),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                      letterSpacing: 0.12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Arrow Icon
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }
}

// Action Button Widget (Logout/Delete)
class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
