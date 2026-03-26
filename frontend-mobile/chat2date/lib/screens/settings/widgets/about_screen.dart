import 'package:chat2date/components/layout/header.dart';
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String routeName = '/about';

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(content),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF98FB98),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        title: const Text(
          'About',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 22,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
                  // App Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FAFE),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/branding/logos/logo_chat2date_default.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const FlutterLogo(size: 60),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // App Name
                  const Text(
                    'Chat 2 Date',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 28,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.56,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Version
                  const Text(
                    'Version 3.0.0',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'ค้นหาคู่ที่เหมาะสมกับคุณผ่านการแชทและเกมสนุก ๆ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                      letterSpacing: 0.14,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // About Section Card
                  _AboutCard(
                    title: 'เกี่ยวกับแอปพลิเคชัน',
                    children: [
                      _buildInfoRow('ชื่อ:', 'Chat 2 Date'),
                      const SizedBox(height: 16),
                      _buildInfoRow('เวอร์ชัน:', 'Version 3.0.0'),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        'หมวดหมู่:',
                        'Social & Dating',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Features Section
                  _AboutCard(
                    title: 'ฟีเจอร์หลัก',
                    children: [
                      _buildFeature(Icons.chat_bubble_outline, 'ระบบแชทแบบ Real-time'),
                      const SizedBox(height: 12),
                      _buildFeature(Icons.videogame_asset_outlined, 'เกมมิ่งทำให้การหาคู่สนุก'),
                      const SizedBox(height: 12),
                      _buildFeature(Icons.lock_outline, 'ระบบยืนยันตัวตน KYC'),
                      const SizedBox(height: 12),
                      _buildFeature(Icons.location_on_outlined, 'ค้นหาตามสถานที่'),
                      const SizedBox(height: 12),
                      _buildFeature(Icons.notifications_none, 'การแจ้งเตือนแบบ Push'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Developer Section
                  _AboutCard(
                    title: 'ทีมพัฒนา',
                    children: [
                      const Text(
                        'Chat 2 Date ถูกสร้างมาเพื่อให้ผู้ใช้สามารถค้นหาคู่ที่เหมาะสมกับตนเอง ผ่านการแชทและเกมสนุก ๆ โดยรักษาความปลอดภัยและความเป็นส่วนตัว',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.54,
                          letterSpacing: 0.13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Links Section
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     _buildLinkButton(
                  //       context: context,
                  //       label: 'นโยบาย',
                  //       onTap: () => _showInfoDialog(
                  //         context,
                  //         'นโยบายความเป็นส่วนตัว',
                  //         'ยินดีต้อนรับสู่ Chat 2 Date นโยบายความเป็นส่วนตัวของเราได้รับการออกแบบมาเพื่อปกป้องข้อมูลส่วนบุคคลของคุณและ ขณะที่ทำให้ คุณมีประสบการณ์ที่ดีที่สุด',
                  //       ),
                  //     ),
                  //     const SizedBox(width: 16),
                  //     _buildLinkButton(
                  //       context: context,
                  //       label: 'เงื่อนไข',
                  //       onTap: () => _showInfoDialog(
                  //         context,
                  //         'เงื่อนไขการใช้บริการ',
                  //         'โดยการใช้ Chat 2 Date แสดงว่าคุณยอมรับเงื่อนไขการใช้บริการของเรา โปรดอ่านอย่างละเอียดก่อนใช้งาน',
                  //       ),
                  //     ),
                  //     const SizedBox(width: 16),
                  //     _buildLinkButton(
                  //       context: context,
                  //       label: 'ติดต่อ',
                  //       onTap: () => _showInfoDialog(
                  //         context,
                  //         'ติดต่อเรา',
                  //         'หากคุณมีคำถามหรือขอความช่วยเหลือ โปรดติดต่อเราที่:\n\nอีเมล: support@chat2date.com\nเว็บไซต์: www.chat2date.com',
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(height: 32),

                  // Footer
                  const Text(
                    '© 2025 Chat 2 Date. All rights reserved.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                      letterSpacing: 0.12,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  static Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 13,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF5ce1e6)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 13,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              height: 1.54,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildLinkButton({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAFE),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFE0F2F7),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF5ce1e6),
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// About Card Widget
class _AboutCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _AboutCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: const Color(0xFFF7FAFE),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              letterSpacing: -0.32,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
