import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    // auto ไปหน้า /home หลัง 100 วินาที (คงพฤติกรรมเดิม)
    _autoTimer = Timer(const Duration(seconds: 100), () {
      if (!mounted) return;
      Navigator.pop(context); // ปิด success
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
                            fontSize: 18, // ลดนิดให้พอดีกับจอเล็ก
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.35,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),

                      // ระยะหายใจแบบยืดหยุ่น
                      SizedBox(height: constraints.maxHeight * 0.08),

                      // ไอคอนสำเร็จ
                      SizedBox(
                        width: 211,
                        height: 213,
                        child: SvgPicture.asset(
                          'assets/icons/icon_success_ring.svg',
                          fit: BoxFit.contain,
                        ),
                      ),

                      // เว้นช่วงก่อนจบ
                      SizedBox(height: constraints.maxHeight * 0.12),

                      // ปุ่มลัดไปหน้า Home ทันที (ถ้าผู้ใช้ไม่อยากรอ)
                      SizedBox(
                        width: 200,
                        height: 40,
                        child: FilledButton(
                          onPressed: () {
                            _autoTimer?.cancel();
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/profileSetup');
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF22C55E),
                          ),
                          child: const Text(
                            'ไปหน้าแรกเลย',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
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
