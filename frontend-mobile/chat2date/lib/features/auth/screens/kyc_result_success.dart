import 'dart:async';

import 'package:chat2date/core/theme/app_colors.dart';
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
    _autoTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      _goNext();
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    super.dispose();
  }

  void _goNext() {
    _autoTimer?.cancel();
    Navigator.pop(context);
    Navigator.pushNamed(context, '/profileSetup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 211,
                    height: 213,
                    child: SvgPicture.asset(
                      'assets/icons/ui/icon_success_ring.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'ยืนยันตัวตนสำเร็จ',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'เริ่มต้นไปด้วยกัน ระบบจะพาคุณไปตั้งค่าโปรไฟล์ในอีกไม่กี่วินาที',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'ระบบจะพาไปหน้าถัดไปอัตโนมัติภายใน 5 วินาที',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
