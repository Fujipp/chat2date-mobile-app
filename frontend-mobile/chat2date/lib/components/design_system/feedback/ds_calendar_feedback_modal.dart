import 'dart:async';
import 'dart:ui';

import 'package:chat2date/components/design_system/buttons/index.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:chat2date/core/theme/tokens/typography/body_text_styles.dart';
import 'package:chat2date/core/theme/tokens/typography/display_text_styles.dart';
import 'package:flutter/material.dart';

class DsCalendarDecisionModal extends StatelessWidget {
  const DsCalendarDecisionModal({
    super.key,
    required this.title,
    required this.description,
    required this.negativeLabel,
    required this.positiveLabel,
    this.onNegativePressed,
    this.onPositivePressed,
  });

  final String title;
  final String description;
  final String negativeLabel;
  final String positiveLabel;
  final VoidCallback? onNegativePressed;
  final VoidCallback? onPositivePressed;

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required String description,
    required String negativeLabel,
    required String positiveLabel,
    VoidCallback? onNegativePressed,
    VoidCallback? onPositivePressed,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Close modal',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return _AnimatedCalendarOverlay(
          animation: curved,
          child: DsCalendarDecisionModal(
            title: title,
            description: description,
            negativeLabel: negativeLabel,
            positiveLabel: positiveLabel,
            onNegativePressed: onNegativePressed,
            onPositivePressed: onPositivePressed,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 310,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppDisplayTextStyles.subtitleBold.copyWith(
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppBodyTextStyles.bodySmall.copyWith(
              color: AppColors.textSupport,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DsButton(
                label: negativeLabel,
                variant: DsButtonVariant.error,
                width: 100,
                onPressed: onNegativePressed ?? () {},
              ),
              const SizedBox(width: 32),
              DsButton(
                label: positiveLabel,
                variant: DsButtonVariant.secondary,
                width: 100,
                onPressed: onPositivePressed ?? () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DsCalendarStatusModal extends StatelessWidget {
  const DsCalendarStatusModal({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 2),
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Close modal',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return _AnimatedCalendarOverlay(
          animation: curved,
          child: _AutoDismissCalendarStatus(
            duration: duration,
            child: DsCalendarStatusModal(
              title: title,
              message: message,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 310,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check_rounded,
              size: 46,
              color: AppColors.background,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppDisplayTextStyles.subtitleBold.copyWith(
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppBodyTextStyles.bodySmall.copyWith(
              color: AppColors.textSupport,
            ),
          ),
        ],
      ),
    );
  }
}

class _AutoDismissCalendarStatus extends StatefulWidget {
  const _AutoDismissCalendarStatus({
    required this.duration,
    required this.child,
  });

  final Duration duration;
  final Widget child;

  @override
  State<_AutoDismissCalendarStatus> createState() =>
      _AutoDismissCalendarStatusState();
}

class _AutoDismissCalendarStatusState
    extends State<_AutoDismissCalendarStatus> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duration, () {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).maybePop();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _AnimatedCalendarOverlay extends StatelessWidget {
  const _AnimatedCalendarOverlay({
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final blur = Tween<double>(begin: 0, end: 12).animate(animation);
    final overlayOpacity = Tween<double>(begin: 0, end: 0.18).animate(
      animation,
    );
    final scale = Tween<double>(begin: 0.96, end: 1).animate(animation);

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: animation,
              builder: (_, __) {
                return BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: blur.value,
                    sigmaY: blur.value,
                  ),
                  child: ColoredBox(
                    color: AppColors.overlay.withValues(
                      alpha: overlayOpacity.value,
                    ),
                  ),
                );
              },
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: scale,
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
