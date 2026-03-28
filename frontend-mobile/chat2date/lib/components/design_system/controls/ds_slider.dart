import 'package:chat2date/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DsSlider extends StatelessWidget {
  const DsSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.width = 300,
    this.min = 0,
    this.max = 100,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final double width;
  final double min;
  final double max;

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(min, max);

    return SizedBox(
      width: width,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 8,
          activeTrackColor: AppColors.brandPrimary,
          inactiveTrackColor: AppColors.divider,
          overlayShape: SliderComponentShape.noOverlay,
          thumbShape: const _DsSliderThumbShape(),
          trackShape: const RoundedRectSliderTrackShape(),
        ),
        child: Slider(
          value: clampedValue,
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _DsSliderThumbShape extends SliderComponentShape {
  const _DsSliderThumbShape();

  static const double _radius = 10;
  static const double _innerRadius = 4.5;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size.fromRadius(_radius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final activeT = Curves.easeOut.transform(activationAnimation.value);

    final outerPaint = Paint()
      ..color = Color.lerp(
            AppColors.background,
            AppColors.brandPrimary,
            activeT,
          ) ??
          AppColors.background;
    final innerPaint = Paint()
      ..color = Color.lerp(
            AppColors.brandPrimary,
            AppColors.background,
            activeT,
          ) ??
          AppColors.brandPrimary;

    canvas.drawCircle(center, _radius, outerPaint);
    canvas.drawCircle(center, _innerRadius, innerPaint);
  }
}
