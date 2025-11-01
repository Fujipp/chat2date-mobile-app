import 'dart:async';
import 'dart:math';

import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SpinDateModeComponent extends StatefulWidget {
  final List<Map<String, dynamic>> prizes;
  final String mode; // 'pair' หรือ 'single'

  const SpinDateModeComponent({
    super.key,
    required this.prizes,
    required this.mode,
  });

  @override
  State<SpinDateModeComponent> createState() => _SpinDateModeComponentState();
}

class _SpinDateModeComponentState extends State<SpinDateModeComponent> {
  final StreamController<int> controller = StreamController<int>();
  RangeValues selectedRange = const RangeValues(1, 1900);

  @override
  Widget build(BuildContext context) {
    final bool isPairMode = widget.mode == 'pair';

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
      height: widget.mode == 'pair' ? 539.51 : 600.51,
      width: 333,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SvgPicture.asset(
                "assets/images/refresh.svg",
                width: 31,
                height: 31,
              ),
              const Text(
                'SPIN TO CHOOSE',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SvgPicture.asset(
                "assets/images/close.svg",
                width: 21,
                height: 21,
              ),
            ],
          ),
          if (widget.mode == 'single') const SizedBox(height: 20),
          if (widget.mode == 'single')
            Container(
              height: 41,
              width: 311,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                border: Border.all(color: AppColors.neutral600),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/images/first-user.svg", // เปลี่ยนภาพตามโหมด
                    width: 151,
                    height: 35,
                  ),
                  SvgPicture.asset(
                    "assets/images/second-user.svg", // เปลี่ยนภาพตามโหมด
                    width: 151,
                    height: 35,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          CustomPaint(
            size: const Size(231.82, 224.51),
            painter: _InlineWheelPainter(widget.prizes),
          ),

          const SizedBox(height: 20),

          // Range Slider
          SizedBox(
            width: 308,
            height: 66,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${selectedRange.start.round()} กม.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '${selectedRange.end.round()} กม.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                RangeSlider(
                  values: selectedRange,
                  min: 1,
                  max: 1900,
                  activeColor: AppColors.neutral600,
                  inactiveColor: AppColors.neutral300,
                  onChanged: (RangeValues values) {
                    setState(() {
                      selectedRange = values;
                    });
                  },
                ),
              ],
            ),
          ),

          const Text(
            'Sub-topic',
            style: TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 5),

          // คำอธิบายแต่ละโหมด
          Column(
            children: [
              Text(
                isPairMode
                    ? 'ระบบจะหาตำแหน่งกึ่งกลางระหว่างผู้ใช้งานทั้งสองคน\n'
                          'แล้วใช้ระยะทางที่กำหนดเป็นรัศมีรอบ ๆ จุดกึ่งกลางนั้น\n'
                          'เพื่อค้นหาสถานที่ที่อยู่ใกล้ ๆ\n'
                    : 'ระบบจะใช้ตำแหน่งของผู้ใช้งาน\n'
                          'และค้นหาสถานที่ที่อยู่ในระยะทางที่กำหนด\n'
                          'จากจุดปัจจุบันของคุณ\n',
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                textAlign: TextAlign.center,
              ),
            ],
          ),

          const SizedBox(height: 15),

          Container(
            height: 45,
            width: 109,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
            child: SvgPicture.asset(
              isPairMode
                  ? "assets/images/pair.svg"
                  : "assets/images/single.svg", // เปลี่ยนภาพตามโหมด
              width: 77.27,
              height: 78,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineWheelPainter extends CustomPainter {
  final List<Map<String, dynamic>> prizes;

  _InlineWheelPainter(this.prizes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final sweepAngle = (2 * pi) / prizes.length;

    for (int i = 0; i < prizes.length; i++) {
      paint.color = prizes[i]['color'];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sweepAngle,
        sweepAngle,
        true,
        paint,
      );

      final textSpan = TextSpan(
        text: prizes[i]['label'],
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // หมุน canvas ไปยังมุมของ slice
      final angle = i * sweepAngle + sweepAngle / 2;
      final textRadius = radius * 0.6; // ปรับตำแหน่ง radial
      final dx = center.dx + textRadius * cos(angle);
      final dy = center.dy + textRadius * sin(angle);

      canvas.save();
      canvas.translate(dx, dy);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }

    // ขอบวงล้อ
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppColors.neutral600
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius, borderPaint);

    // เข็ม
    final needlePath = Path()
      ..moveTo(center.dx, center.dy - radius + 8)
      ..lineTo(center.dx - 6, center.dy)
      ..lineTo(center.dx + 6, center.dy)
      ..close();
    canvas.drawPath(needlePath, Paint()..color = Colors.white);
    canvas.drawPath(
      needlePath,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // จุดกลาง
    canvas.drawCircle(center, 16, Paint()..color = AppColors.neutral600);
  }

  @override
  bool shouldRepaint(covariant _InlineWheelPainter oldDelegate) {
    return oldDelegate.prizes != prizes;
  }
}
