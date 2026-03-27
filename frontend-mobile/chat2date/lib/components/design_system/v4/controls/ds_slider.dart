import 'package:chat2date/theme/app_colors.dart';
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

    canvas.drawShadow(
      Path()..addOval(Rect.fromCircle(center: center, radius: _radius)),
      Colors.black.withValues(alpha: 0.15),
      6,
      true,
    );

    final outerPaint = Paint()..color = Colors.white;
    final innerPaint = Paint()..color = AppColors.brandPrimary;

    canvas.drawCircle(center, _radius, outerPaint);
    canvas.drawCircle(center, 5, innerPaint);
  }
}
