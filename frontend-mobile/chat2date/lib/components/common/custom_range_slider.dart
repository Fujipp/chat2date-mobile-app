import 'package:flutter/material.dart';

class CustomRangeSlider extends StatelessWidget {
  final RangeValues values;
  final ValueChanged<RangeValues> onChanged;
  final double min;
  final double max;
  final double step; // กำหนดขนาดการกระโดดของค่า (เช่น 1)
  final bool snapToStep; // บังคับปัดค่าให้ตรง step

  const CustomRangeSlider({
    super.key,
    required this.values,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.step = 1.0,
    this.snapToStep = true,
  }) : assert(step > 0, 'step must be > 0');

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 8,
        activeTrackColor: const Color(0xFF6B7280),
        inactiveTrackColor: const Color(0xFFE0E0E0),
        thumbColor: const Color(0xFF6B7280),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayColor: const Color(0xFF6B7280).withOpacity(0.2),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
        trackShape: const RoundedRectSliderTrackShape(),
      ),
      child: RangeSlider(
        values: values,
        min: min,
        max: max,
        // กำหนด divisions เพื่อให้ RangeSlider แสดง tick ตาม step
        divisions: ((max - min) / step).round(),
        onChanged: (r) {
          if (!snapToStep) {
            onChanged(r);
            return;
          }
          double snap(double v) {
            final snapped = (v / step).round() * step;
            // ป้องกันเลยขอบ
            if (snapped < min) return min;
            if (snapped > max) return max;
            return snapped;
          }
          final newStart = snap(r.start);
            final newEnd = snap(r.end);
          onChanged(RangeValues(newStart, newEnd));
        },
      ),
    );
  }
}
