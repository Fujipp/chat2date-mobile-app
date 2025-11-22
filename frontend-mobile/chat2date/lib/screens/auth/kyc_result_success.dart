// lib/screens/auth/kyc_result_success_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// เปลี่ยน path ให้ตรงกับโปรเจกต์ Dev
import 'package:chat2date/components/buttons/ds_button.dart';

class KycResultSuccessScreen extends StatefulWidget {
  const KycResultSuccessScreen({super.key});

  @override
  State<KycResultSuccessScreen> createState() => _KycResultSuccessScreenState();
}

class _KycResultSuccessScreenState extends State<KycResultSuccessScreen> {
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();

    // Auto กลับ /home หลัง 100 วินาที (พฤติกรรมเดิม)
    _autoTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      Navigator.pop(context); // ปิดหน้าปัจจุบัน
      Navigator.pushNamed(context, '/home');
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
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
                      const Text(
                        'ยืนยันตัวตนสำเร็จ',
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
                          'เริ่มต้นไปด้วยกัน',
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

                      SizedBox(height: constraints.maxHeight * 0.08),

                      // รูป success
                      SizedBox(
                        width: 211,
                        height: 213,
                        child: SvgPicture.asset(
                          'assets/icons/icon_success_ring.svg',
                          fit: BoxFit.contain,
                        ),
                      ),

                      SizedBox(height: constraints.maxHeight * 0.12),

                      // ปุ่มไปหน้า profile setup (สีเขียว)
                      DsButton(
                        label: 'ไปหน้าถัดไป',
                        onPressed: () {
                          _autoTimer?.cancel();
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/profileSetup');
                        },
                        variant: DsButtonVariant.secondary, // ✅ ปุ่มสีเขียว
                        size: DsButtonSize.md,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),

                      const SizedBox(height: 12),

                      // บอกนิดนึงว่าเดี๋ยวจะ auto กลับหน้าแรก
                      const Text(
                        'ระบบจะพาไปหน้าถัดไปอัตโนมัติภายใน 5 วินาที',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
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
