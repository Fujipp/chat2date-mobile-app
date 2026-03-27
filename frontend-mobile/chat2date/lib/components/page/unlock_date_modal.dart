import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// อย่าลืม import ไฟล์ AppColors ของคุณด้วยนะครับ
import 'package:chat2date/theme/app_colors.dart'; 

class UnlockDateModal extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onConfirm;

  const UnlockDateModal({
    super.key,
    required this.isVisible,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Stack(
      children: [
        // 1. Full Screen Blur Background
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
              ),
            ),
          ),
        ),

        // 2. Animated Content
        Positioned.fill(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Center(
              child: _buildMainCard(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainCard(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.88,
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.95),
        borderRadius: BorderRadius.circular(45),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandPrimary.withOpacity(0.2),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTopDecoration(),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
            child: Column(
              children: [
                _buildIconSection(),
                const SizedBox(height: 32),
                const Text(
                  'Unlock Your Date!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'เตรียมตัวไปสร้างเดตสุดพิเศษ\nกับคู่ของคุณกัน!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                _buildConfirmButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopDecoration() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(45),
        topRight: Radius.circular(45),
      ),
      child: SizedBox(
        height: 100,
        child: Stack(
          children: [
            Positioned(
              top: -50, left: -20,
              child: CircleAvatar(radius: 60, backgroundColor: AppColors.info.withOpacity(0.3)),
            ),
            Positioned(
              top: -20, right: -10,
              child: CircleAvatar(radius: 40, backgroundColor: AppColors.brandPrimary200.withOpacity(0.5)),
            ),
            const Center(
              child: Text(
                "IT'S DATE TIME!",
                style: TextStyle(
                  color: AppColors.brandPrimary700,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconSection() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 140, height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.brandPrimary200.withOpacity(0.6),
                AppColors.background.withOpacity(0.0),
              ],
            ),
          ),
        ),
        Container(
          width: 100, height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.brandPrimary, AppColors.brandPrimary700],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.brandPrimary.withOpacity(0.4),
                blurRadius: 15, offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(5),
          child: SvgPicture.asset('assets/icons/icon_spinwheel.svg', fit: BoxFit.contain),
        ),
        Positioned(
          top: 5, right: 5,
          child: SvgPicture.asset('assets/icons/HEART_STATUS_BAR.svg', width: 28),
        ),
        Positioned(
          bottom: 0, left: 10,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: AppColors.textPrimary, shape: BoxShape.circle),
            child: SvgPicture.asset(
              'assets/icons/icon_unlock.svg',
              width: 20, color: AppColors.warning,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [AppColors.btnPrimary, AppColors.btnHoverPrimary]),
        boxShadow: [
          BoxShadow(
            color: AppColors.btnPrimary.withOpacity(0.3),
            blurRadius: 15, offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onConfirm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: const Text(
          'ไปเดตกันเลย!',
          style: TextStyle(color: AppColors.btnTextPrimary, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}