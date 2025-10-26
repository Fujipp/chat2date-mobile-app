import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

/// ฟังก์ชันเลือกสีโทนอ่อนตามเปอร์เซ็นต์
Color getProgressColor(double percent) {
  if (percent <= 0.25) {
    // แดงเข้ม → แดงอ่อน
    double t = percent / 0.25; // 0.0 - 1.0
    return Color.lerp(const Color(0xFFFF0000), const Color(0xFFFF6B6B), t)!;
  } else if (percent <= 0.5) {
    // แดงอ่อน → ส้ม
    double t = (percent - 0.25) / 0.25;
    return Color.lerp(const Color(0xFFFF6B6B), const Color(0xFFFFD166), t)!;
  } else if (percent <= 0.75) {
    // ส้ม → เขียวอ่อน
    double t = (percent - 0.5) / 0.25;
    return Color.lerp(const Color(0xFFFFD166), const Color(0xFF98FB98), t)!;
  } else {
    // เขียวอ่อน → เขียวเข้ม
    double t = (percent - 0.75) / 0.25;
    return Color.lerp(const Color(0xFF98FB98), const Color(0xFF32CD32), t)!;
  }
}

/// Circular Loading Component
class CircularLoading extends StatelessWidget {
  final double percent; // 0.0 - 1.0

  const CircularLoading({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 211,
      height: 213,
      child: CircularPercentIndicator(
        radius: 100,
        lineWidth: 10,
        percent: percent,
        center: Text(
          '${(percent * 100).toInt()}%',
          style: const TextStyle(fontSize: 32),
        ),
        progressColor: getProgressColor(percent),
        backgroundColor: Colors.grey.shade200,
        circularStrokeCap: CircularStrokeCap.round,
        animation: true,
      ),
    );
  }
}

/// Linear Loading Component
class LinearLoading extends StatelessWidget {
  final double percent;

  const LinearLoading({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    return LinearPercentIndicator(
      lineHeight: 25.0,
      percent: percent,
      center: Text(
        '${(percent * 100).toInt()}%',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.grey.shade200,
      progressColor: getProgressColor(percent),
      linearStrokeCap: LinearStrokeCap.roundAll,
      animation: true,
    );
  }
}
