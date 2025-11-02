import 'dart:math';

import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chat2date/components/chat/content_switcher.dart';

class SpinDateComponent extends StatefulWidget {
  final List<Map<String, dynamic>> prizes;
  final int indexMode;
  final String? firstPersonName;
  final String? secondPersonName;
  final int     indexSelected;

  const SpinDateComponent({
    super.key,
    required this.prizes,
    this.indexMode = 1,
    this.indexSelected = 1,
    this.firstPersonName = "jack",
    this.secondPersonName = "susie",
  });

  @override
  State<SpinDateComponent> createState() => _SpinDateComponentState();
}

class _SpinDateComponentState extends State<SpinDateComponent> {
  RangeValues selectedRange = const RangeValues(1, 1900);
  late int indexing;
  late int selectedIndex;
  late String? firstName;
  late String? secondName;

  @override
  void initState() {
    super.initState();
    // กำหนดค่าเริ่มต้นจาก widget
    indexing = widget.indexMode;
    firstName = widget.firstPersonName;
    secondName = widget.secondPersonName;
    selectedIndex = widget.indexSelected;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
      //height: indexing == 0 ? 539.51 : 600.51,
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
                "assets/icons/icon_refresh.svg",
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
              SvgPicture.asset("assets/icons/icon_close.svg", width: 21, height: 21),
            ],
          ),
          const SizedBox(height: 20),
          if (indexing == 0)
            NameSwitcher(
            items: [firstName!, secondName!],
            selectedIndex: selectedIndex,
            onChanged: (index) => setState(() => selectedIndex = index),
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
                indexing == 0
                    ? 'ระบบจะหาตำแหน่งกึ่งกลางระหว่างผู้ใช้งานทั้งสองคน\n'
                          'แล้วใช้ระยะทางที่กำหนดเป็นรัศมีรอบ ๆ จุดกึ่งกลางนั้น\n'
                          'เพื่อค้นหาสถานที่ที่อยู่ใกล้ ๆ\n'
                    : 'ระบบจะอิงตำแหน่งจุดกึ่งกลางคนหนึ่งที่เลือก\n'
                          'แล้วใช้ระยะทางที่กำหนดเป็นรัศมีรอบ ๆ จุดกึ่งกลางนั้น\n'
                          'เพื่อค้นหาสถานที่ที่อยู่ใกล้ ๆ\n',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),

          const SizedBox(height: 15),
          IconSwitcher(
            selectedIndex: indexing,
            onChanged: (index) => setState(() => indexing = index),
          ),
          const SizedBox(height: 12),
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

    final colors = [AppColors.brandSecondary, AppColors.brandPrimary];

    for (int i = 0; i < prizes.length; i++) {
      paint.color = colors[i % 2]; // สลับสีทุกช่อง

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sweepAngle,
        sweepAngle,
        true,
        paint,
      );

      // วาดข้อความ
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

      final angle = i * sweepAngle + sweepAngle / 2;
      final textRadius = radius * 0.6;
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

    final needleLength = radius * 0.3; // เดิมยาวเกือบ radius ตอนนี้แค่ 30%
    final needlePath = Path()
      ..moveTo(center.dx, center.dy - needleLength)
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

    canvas.drawCircle(center, 16, Paint()..color = AppColors.neutral600);
  }

  @override
  bool shouldRepaint(covariant _InlineWheelPainter oldDelegate) {
    return oldDelegate.prizes != prizes;
  }
}
