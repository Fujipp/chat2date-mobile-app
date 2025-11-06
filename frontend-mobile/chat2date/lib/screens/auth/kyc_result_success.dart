// lib/screens/auth/kyc_result_success.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class KycResultSuccessScreen extends StatefulWidget {
  const KycResultSuccessScreen({super.key});
  @override
  State<KycResultSuccessScreen> createState() => _KycResultSuccessScreenState();
}

class _KycResultSuccessScreenState extends State<KycResultSuccessScreen> {
  @override
  void initState() {
    super.initState();
    // auto ไปหน้า /home หลัง 100 วินาที (ตามเดิม)
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      Navigator.pop(context); // ปิด success
      Navigator.pushNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 375,
          height: 812,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 200),
          clipBehavior: Clip.antiAlias,
          // ไม่มีเส้นกรอบ: ตัด BorderSide ออก เหลือเฉพาะสีพื้น + มุมโค้ง
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          // เหลือ 2 ส่วน: Text + Icon และเว้นแกน Y ให้ห่างด้วย Spacer
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
                    // หัวข้อ: เอา height คงที่ออก + ใส่ line-height
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        'ยืนยันตัวตนสำเร็จ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF0F172A), // text-primary
                          fontSize: 32,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.15, // กันโดนตัดหางตัวอักษร
                        ),
                      ),
                    ),

                    // คำโปรย: เอา height คงที่ออก + ให้ห่อบรรทัดเอง
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'เริ่มต้นไปด้วยกัน',
                        textAlign: TextAlign.center,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                          color: Color(0xFF334155), // text-secondary
                          fontSize: 20,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.3, // อ่านสบาย ไม่โดนตัด
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // เว้นเยอะ (ดัน Icon ลงไป)
              const Spacer(flex: 4),

              // ===== Icon (SVG) =====
              SizedBox(
                width: 211,
                height: 213,
                child: SvgPicture.asset(
                  'assets/icons/icon_success_ring.svg',
                  fit: BoxFit.contain,
                ),
              ),

              // เว้นเยอะอีก (ดันลงล่างให้โล่ง)
              const Spacer(flex: 6),
            ],
          ),
        ),
      ),
    );
  }
}
