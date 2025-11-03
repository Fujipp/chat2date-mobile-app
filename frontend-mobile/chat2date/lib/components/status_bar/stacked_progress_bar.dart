import 'package:flutter/material.dart';

class ProgressSegment {
  final double percent; // 0..1
  final Color? color;
  final Gradient? gradient;

  const ProgressSegment({required this.percent, this.color, this.gradient})
    : assert(percent >= 0 && percent <= 1);
}

class StackedProgressBar extends StatelessWidget {
  const StackedProgressBar({
    super.key,
    required this.segments,
    this.height = 10,
    this.backgroundColor = const Color(0xFFE0E0E0), // Light-Divider
    this.borderRadius = const BorderRadius.all(Radius.circular(100)),
    this.width = 255, // <— ขนาดคงที่ตามสเปก
  });

  final List<ProgressSegment> segments;
  final double height;
  final double width;
  final Color backgroundColor;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: backgroundColor)),
            // วาด segment ซ้อนจากซ้าย -> ขวา (ตัวท้ายจะซ้อนทับตัวก่อนหน้า)
            for (final seg in segments)
              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: seg.percent.clamp(0, 1),
                  child: Container(
                    decoration: BoxDecoration(
                      color: seg.color,
                      gradient: seg.gradient,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
