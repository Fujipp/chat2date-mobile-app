// lib/screens/auth/kyc_result_fail.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ใช้ปุ่มจาก DS ของเรา
import 'package:chat2date/components/buttons/ds_button.dart';
import 'package:chat2date/components/buttons/ds_button_schemes.dart';

class KycResultFailScreen extends StatelessWidget {
  const KycResultFailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ดึง arguments จาก Navigator
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    bool? matched;
    double? score;
    Map<String, dynamic>? raw;

    if (args != null) {
      // matched
      final m = args['matched'];
      if (m is bool) {
        matched = m;
      }

      // score
      final s = args['score'];
      if (s is num) {
        score = s.toDouble();
      }

      // raw (ตรวจแบบง่าย ๆ กัน type error)
      final r = args['raw'];
      if (r is Map) {
        // cast ให้เป็น Map<String, dynamic> แบบปลอดภัย
        raw = r.map((key, value) => MapEntry(key.toString(), value));
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // รองรับหน้าจอเตี้ย: ใส่สกอลล์ได้
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ===== ข้อความหัว-รอง =====
                      const Text(
                        'ยืนยันตัวตนไม่สำเร็จ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 32,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.15,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          'กรุณาตรวจสอบว่าบัตรประชาชนของคุณชัดเจนและรูปเซลฟี่ชัดเจน',
                          textAlign: TextAlign.center,
                          softWrap: true,
                          style: TextStyle(
                            color: Color(0xFF334155),
                            fontSize: 18,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.35,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),

                      // ===== ระยะหายใจ =====
                      SizedBox(height: constraints.maxHeight * 0.06),

                      // ===== ไอคอนผลล้มเหลว =====
                      SizedBox(
                        width: 211,
                        height: 213,
                        child: SvgPicture.asset(
                          'assets/icons/icon_fail_ring.svg',
                          fit: BoxFit.contain,
                        ),
                      ),

                      // ===== ระยะหายใจก่อน debug + ปุ่ม =====
                      SizedBox(height: constraints.maxHeight * 0.06),

                      // // ===== Debug: แสดงค่าจาก Backend =====
                      // if (score != null || matched != null || raw != null) ...[
                      //   const Text(
                      //     'รายละเอียดจากระบบตรวจใบหน้า (debug)',
                      //     textAlign: TextAlign.center,
                      //     style: TextStyle(
                      //       color: Color(0xFF475569),
                      //       fontSize: 14,
                      //       fontFamily: 'Inter',
                      //       fontWeight: FontWeight.w600,
                      //     ),
                      //   ),
                      //   const SizedBox(height: 4),
                      //   if (score != null)
                      //     Text(
                      //       'score: ${score!.toStringAsFixed(3)}',
                      //       style: const TextStyle(
                      //         color: Color(0xFF64748B),
                      //         fontSize: 13,
                      //       ),
                      //     ),
                      //   if (matched != null)
                      //     Text(
                      //       'matched: $matched',
                      //       style: const TextStyle(
                      //         color: Color(0xFF64748B),
                      //         fontSize: 13,
                      //       ),
                      //     ),
                      //   if (raw != null) ...[
                      //     const SizedBox(height: 4),
                      //     Text(
                      //       'raw: ${raw.toString()}',
                      //       style: const TextStyle(
                      //         color: Color(0xFF94A3B8),
                      //         fontSize: 11,
                      //       ),
                      //     ),
                      //   ],
                      //   const SizedBox(height: 16),
                      // ],

                      // ===== ปุ่มลองใหม่ =====
                      SizedBox(
                        width: 231,
                        height: 40,
                        child: DsButton(
                          label: 'ลองสแกนอีกครั้ง',
                          size: DsButtonSize.md,
                          variant: DsButtonVariant.primary,
                          onPressed: () {
                            // กลับไปเริ่มที่หน้าสแกนบัตรใหม่
                            Navigator.popUntil(context, (r) => r.isFirst);
                            Navigator.pushNamed(context, '/face-scan');
                          },
                        ),
                      ),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
