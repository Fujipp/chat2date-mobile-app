import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ใช้ปุ่มจาก DS ของเรา
import 'package:chat2date/components/buttons/ds_button.dart';
import 'package:chat2date/components/buttons/ds_button_schemes.dart';

class KycResultFailScreen extends StatelessWidget {
  const KycResultFailScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                            fontSize: 18, // ลดนิดให้พอดีกับจอเล็ก
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

                      // ===== ระยะหายใจก่อนปุ่ม =====
                      SizedBox(height: constraints.maxHeight * 0.10),

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
                            // เคลียร์สแตกจนเหลือหน้าแรก แล้ว push ไป /kyc-id-ocr
                            Navigator.popUntil(context, (r) => r.isFirst);
                            Navigator.pushNamed(context, '/kyc-id-ocr');
                          },
                        ),
                      ),

                      const SizedBox(height: 12),
                      // ลิงก์ตัวช่วย (ถ้าต้องการเสริม UX)
                      // TextButton(
                      //   onPressed: () {
                      //     // ตัวอย่าง: เปิดหน้าคู่มือ/ทิป (ถ้ามี route)
                      //     // Navigator.pushNamed(context, '/kyc-help');
                      //     Navigator.maybePop(context);
                      //   },
                      //   child: const Text(
                      //     'ย้อนกลับ',
                      //     style: TextStyle(
                      //       color: Color(0xFF64748B),
                      //       fontWeight: FontWeight.w600,
                      //     ),
                      //   ),
                      // ),
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
