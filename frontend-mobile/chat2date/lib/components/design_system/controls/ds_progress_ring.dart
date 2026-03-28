import 'dart:math' as math;

import 'package:chat2date/theme/app_colors.dart';
import 'package:chat2date/theme/tokens/typography/display_text_styles.dart';
import 'package:flutter/material.dart';

class DsProgressRing extends StatelessWidget {
  const DsProgressRing({
    super.key,
    required this.value,
    this.size = 211,
    this.strokeWidth = 9,
    this.duration = const Duration(milliseconds: 450),
  });

  final double value;
  final double size;
  final double strokeWidth;
  final Duration duration;

  Color get _progressColor {
    if (value <= 0.25) {
      return const Color(0xFFFF4141);
    }
    if (value <= 0.5) {
      return const Color(0xFFFFA63B);
    }
    if (value <= 0.75) {
      return const Color(0xFFFFD33D);
    }
    return const Color(0xFF65F232);
  }

  @override
  Widget build(BuildContext context) {
    final double clampedValue = value.clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: clampedValue),
      duration: duration,
      curve: Curves.easeInOutCubic,
      builder: (context, animatedValue, child) {
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _DsProgressRingPainter(
              progress: animatedValue,
              progressColor: _progressColor,
              strokeWidth: strokeWidth,
            ),
            child: Center(
              child: Text(
                '${(animatedValue * 100).round()}%',
                textAlign: TextAlign.center,
                style: AppDisplayTextStyles.h1.copyWith(
                  fontSize: 32,
                  height: 1,
                  letterSpacing: -0.25,
                  color: AppColors.textBlack,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DsProgressRingPainter extends CustomPainter {
  const _DsProgressRingPainter({
    required this.progress,
    required this.progressColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final double radiusInset = strokeWidth / 2;
    final Rect arcRect = rect.deflate(radiusInset);

    final Paint trackPaint = Paint()
      ..color = AppColors.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final Paint progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      arcRect,
      -math.pi / 2,
      math.pi * 2,
      false,
      trackPaint,
    );

    if (progress > 0) {
      canvas.drawArc(
        arcRect,
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DsProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
