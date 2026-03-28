import 'dart:typed_data';

import 'package:chat2date/components/design_system/index.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:chat2date/models/face_scan_args.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class KycResultFailScreen extends StatelessWidget {
  const KycResultFailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

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
                      'assets/icons/ui/icon_fail_ring.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'ยืนยันตัวตนไม่สำเร็จ',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'กรุณาตรวจสอบว่าบัตรประชาชนชัดเจน และใบหน้าของคุณตรงกับบัตร จากนั้นลองสแกนอีกครั้ง',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                  ),
                  const SizedBox(height: 32),
                  DsButton(
                    width: 231,
                    label: 'ลองสแกนอีกครั้ง',
                    size: DsButtonSize.md,
                    variant: DsButtonVariant.primary,
                    onPressed: () {
                      final cardBytes = args?['cardFaceBytes'];
                      final fullName = args?['fullName'] as String?;
                      final dob = args?['dob'] as DateTime?;
                      final gender = args?['gender'] as String?;

                      Navigator.pushReplacementNamed(
                        context,
                        '/face-scan',
                        arguments: FaceScanArgs(
                          cardFaceBytes:
                              cardBytes is Uint8List ? cardBytes : null,
                          fullName: fullName,
                          dob: dob,
                          gender: gender,
                        ),
                      );
                    },
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
