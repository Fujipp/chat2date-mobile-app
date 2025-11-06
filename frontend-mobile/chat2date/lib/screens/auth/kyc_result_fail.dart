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
    return Scaffold(
      body: Center(
        child: Container(
          width: 375,
          height: 812,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 200),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50), // ไม่มีเส้นกรอบ
            ),
          ),
          // ทำให้เว้นระยะแกน Y เยอะขึ้นด้วย Spacer
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ===== Text =====
              SizedBox(
                width: 370,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    // หัวข้อ (ยังคงสูงพอด้วยตัวเอง ไม่ต้อง fix height)
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        'ยืนยันตัวตนไม่สำเร็จ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF0F172A), // text-primary
                          fontSize: 32,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height:
                              1.15, // line-height ~115% กันโดนตัดหางตัวหนังสือ
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'กรุณาตรวจสอบว่าบัตรประชาชนของคุณชัดเจนและรูปเซลฟี่ชัดเจน',
                        textAlign: TextAlign.center,
                        softWrap: true,
                        maxLines: 3, // กันยาวเกิน เผื่อ textScaleFactor ใหญ่
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                          color: Color(0xFF334155), // text-secondary
                          fontSize: 20,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.32,
                          height: 1.3, // line-height ~130% อ่านสบายและไม่โดนตัด
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // เว้นเยอะ (ดัน Icon ลงไป)
              const Spacer(flex: 3),

              // ===== Icon (SVG) =====
              SizedBox(
                width: 211,
                height: 213,
                child: SvgPicture.asset(
                  'assets/icons/icon_fail_ring.svg',
                  fit: BoxFit.contain,
                ),
              ),

              // เว้นเยอะมาก (ดันปุ่มลงไปล่าง ๆ)
              const Spacer(flex: 5),

              // ===== Button (DS ของเรา) =====
              SizedBox(
                width: 231,
                height: 40,
                child: DsButton(
                  label: 'ลองสแกนอีกครั้ง',
                  size: DsButtonSize.md,
                  variant: DsButtonVariant.primary, // พื้นสีฟ้าเขียวของ Dev
                  onPressed: () {
                    // กลับไปสแกนใหม่
                    Navigator.pop(context); // ปิด fail
                    Navigator.popUntil(context, (r) => r.isFirst);
                    Navigator.pushNamed(context, '/kyc-id-ocr');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
