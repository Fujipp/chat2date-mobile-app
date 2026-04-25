import 'dart:ui';

import 'package:chat2date/components/design_system/buttons/index.dart';
import 'package:chat2date/core/theme/app_assets.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:chat2date/core/theme/tokens/typography/body_text_styles.dart';
import 'package:chat2date/core/theme/tokens/typography/display_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UnlockDateModal extends StatelessWidget {
  const UnlockDateModal({
    super.key,
    required this.isVisible,
    required this.onConfirm,
  });

  final bool isVisible;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: ColoredBox(
                color: AppColors.overlay.withValues(alpha: 0.18),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: 0.96 + (0.04 * value),
                  child: child,
                ),
              );
            },
            child: Center(child: _buildMainCard()),
          ),
        ),
      ],
    );
  }

  Widget _buildMainCard() {
    return Container(
      width: 310,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: SizedBox(
              height: 64,
              child: Stack(
                children: [
                  Positioned(
                    top: -22,
                    left: -18,
                    child: Container(
                      width: 79,
                      height: 79,
                      decoration: const BoxDecoration(
                        color: AppColors.brandPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -22,
                    right: -18,
                    child: Container(
                      width: 79,
                      height: 79,
                      decoration: const BoxDecoration(
                        color: AppColors.brandPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 74,
                  height: 82,
                  child: Center(
                    child: SvgPicture.asset(
                      AppAssets.spinwheelIcon,
                      width: 74,
                      height: 74,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Unlock Date',
                  textAlign: TextAlign.center,
                  style: AppDisplayTextStyles.subtitleBold.copyWith(
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'เตรียมตัวไปสร้างเดตสุดพิเศษ\nกับคู่ของคุณกัน',
                  textAlign: TextAlign.center,
                  style: AppBodyTextStyles.bodySmall.copyWith(
                    color: AppColors.textSupport,
                  ),
                ),
                const SizedBox(height: 20),
                DsButton(
                  label: 'ไปเดตกันเลย',
                  variant: DsButtonVariant.primary,
                  width: 231,
                  onPressed: onConfirm,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
