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
  final int indexSelected;
  final VoidCallback? onCloseModal;
  final VoidCallback? onRefreshSpin;
  final Function(String)? onSpinComplete;

  const SpinDateComponent({
    super.key,
    required this.prizes,
    this.indexMode = 1,
    this.indexSelected = 1,
    this.firstPersonName = "jack",
    this.secondPersonName = "susie",
    this.onCloseModal,
    this.onRefreshSpin,
    this.onSpinComplete,
  });

  @override
  State<SpinDateComponent> createState() => _SpinDateComponentState();
}

class _SpinDateComponentState extends State<SpinDateComponent>
    with SingleTickerProviderStateMixin {
  RangeValues selectedRange = const RangeValues(1.0, 20.0);
  late int indexing;
  late int selectedIndex;
  late String? firstName;
  late String? secondName;

  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentRotation = 0.0;

  @override
  void initState() {
    super.initState();
    indexing = widget.indexMode;
    firstName = widget.firstPersonName;
    secondName = widget.secondPersonName;
    selectedIndex = widget.indexSelected;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _animation = Tween<double>(begin: 0.0, end: 0.0).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _calculateResult();
      }
    });
  }

  void _spinWheel() {
    if (_controller.isAnimating || widget.prizes.isEmpty) return;
    double randomRounds = 10 + Random().nextInt(11).toDouble();

    double randomAngle = Random().nextDouble() * 2 * pi;

    double targetRotation =
        _currentRotation + (randomRounds * 2 * pi) + randomAngle;

    setState(() {
      _animation = Tween<double>(begin: _currentRotation, end: targetRotation)
          .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
          );
    });
    _currentRotation = targetRotation;

    _controller.forward(from: 0.0);
  }

  void _calculateResult() {
    String _resultLabel = "";
    if (widget.prizes.isEmpty) return;
    double finalAngle = _currentRotation % (2 * pi);
    double sectorAngle = (2 * pi) / widget.prizes.length;
    int index = (((1.5 * pi - finalAngle) % (2 * pi)) / sectorAngle).floor();
    if (index < 0) index += widget.prizes.length;
    setState(() {
      _resultLabel = widget.prizes[index]['label'];
    });
    widget.onSpinComplete?.call(widget.prizes[index]['label']);
  }

  void _resetToInitialState() {
    if (_controller.isAnimating) return;

    setState(() {
      _currentRotation = 0.0;

      _animation = Tween<double>(begin: 0.0, end: 0.0).animate(_controller);

      selectedRange = const RangeValues(1.0, 20.0);
    });

    _controller.stop();
    _controller.value = 0.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
      width: 333,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          if (indexing == 0)
            NameSwitcher(
              items: [firstName!, secondName!],
              selectedIndex: selectedIndex,
              onChanged: (index) {
                if (_controller.isAnimating) return; // ห้ามเปลี่ยนถ้ากำลังหมุน
                setState(() => selectedIndex = index);
              },
            ),
          const SizedBox(height: 20),

          SizedBox(
            width: 232,
            height: 232,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(232, 232),
                      painter: _InlineWheelPainter(
                        widget.prizes,
                        _animation.value,
                      ),
                    );
                  },
                ),
                CustomPaint(
                  size: const Size(232, 232),
                  painter: _StaticNeedlePainter(),
                ),
                GestureDetector(
                  onTap: _spinWheel,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildBottomUI(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () {
            if (_controller.isAnimating) return; // ห้ามกดขณะหมุน

            _resetToInitialState(); // เรียกฟังก์ชันรีเซ็ตทุกอย่างกลับค่าตั้งต้น

            if (widget.onRefreshSpin != null) {
              widget.onRefreshSpin!();
            }
          },
          child: SvgPicture.asset("assets/icons/icon_refresh.svg", width: 31),
        ),
        const Text(
          'SPIN TO CHOOSE',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        InkWell(
          onTap: () {
            if (_controller.isAnimating) return; // ห้ามปิด Modal
            widget.onCloseModal?.call();
          },
          child: SvgPicture.asset("assets/icons/icon_close.svg", width: 31),
        ),
      ],
    );
  }

  Widget _buildBottomUI() {
    return Column(
      children: [
        SizedBox(
          width: 308,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${selectedRange.start.round()} กม.',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    '${selectedRange.end.round()} กม.',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              RangeSlider(
                values: selectedRange,
                min: 1.0,
                max: 20.0,
                activeColor: AppColors.neutral600,
                inactiveColor: AppColors.neutral300,
                onChanged: (v) {
                  if (_controller.isAnimating)
                    return; // ห้ามเลื่อนระยะทางขณะหมุน
                  setState(() => selectedRange = v);
                },
              ),
            ],
          ),
        ),
        const Text('หมายเหตุ', style: TextStyle(fontSize: 12)),
        const SizedBox(height: 5),
        Text(
          indexing == 0
              ? 'ระบบจะอิงตำแหน่งจุดกึ่งกลางคนหนึ่งที่เลือก \nแล้วใช้ระยะทางที่กำหนดเป็นรัศมีรอบ ๆ จุดกึ่งกลางนั้น \nเพื่อค้นหาสถานที่ที่อยู่ใกล้ ๆ'
              : 'ระบบจะหาตำแหน่งกึ่งกลางระหว่างผู้ใช้งานทั้งสองคน \nแล้วใช้ระยะทางที่กำหนดเป็นรัศมีรอบ ๆ จุดกึ่งกลางนั้น \nเพื่อค้นหาสถานที่ที่อยู่ใกล้ ๆ',
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 15),
        IconSwitcher(
          selectedIndex: indexing,
          onChanged: (index) {
            if (_controller.isAnimating) return; // ห้ามเปลี่ยนถ้ากำลังหมุน
            setState(() => indexing = index);
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

// --- Painter สำหรับวงล้อ ---
class _InlineWheelPainter extends CustomPainter {
  final List<Map<String, dynamic>> prizes;
  final double rotationAngle;
  _InlineWheelPainter(this.prizes, this.rotationAngle);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sweepAngle = (2 * pi) / prizes.length;
    final colors = [AppColors.brandSecondary, AppColors.brandPrimary];

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-center.dx, -center.dy);
    for (int i = 0; i < prizes.length; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sweepAngle,
        sweepAngle + 0.01,
        true,
        Paint()..color = colors[i % 2],
      );
    }
    canvas.restore();

    for (int i = 0; i < prizes.length; i++) {
      // 1. คำนวณมุมกึ่งกลางของช่องปัจจุบัน (รวมมุมหมุนของวงล้อ)
      final double currentAngle =
          (i * sweepAngle + sweepAngle / 2) + rotationAngle;

      canvas.save(); // บันทึกสถานะ Canvas ก่อนหมุนเฉพาะจุด

      // 2. ย้ายจุด Zero (0,0) ของ Canvas ไปที่ตำแหน่งที่จะวางข้อความ
      // ใช้ระยะประมาณ 60-70% ของรัศมีจากจุดศูนย์กลาง
      final double textDistance = radius * 0.65;
      final double x = center.dx + textDistance * cos(currentAngle);
      final double y = center.dy + textDistance * sin(currentAngle);

      canvas.translate(x, y);

      // 3. หมุน Canvas ให้ข้อความตั้งฉากกับเส้นรัศมี (ชี้เข้าหาจุดศูนย์กลาง)
      // หากต้องการให้ตัวอักษร "นอน" ตามแนวช่อง ให้ใช้ currentAngle
      // หากต้องการให้หัวข้อความชี้เข้าหาจุดศูนย์กลางพอดี อาจต้อง + pi/2 หรือ - pi/2 ตามความเหมาะสม
      canvas.rotate(currentAngle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: prizes[i]['label'],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '...',
        textAlign: TextAlign.center,
      )..layout(maxWidth: radius * 0.7); // จำกัดความยาวไม่ให้เลยขอบวงล้อ

      // 4. วาดข้อความ (จัดให้อยู่กึ่งกลางจุดที่ translate มา)
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );

      canvas.restore(); // คืนค่า Canvas กลับไปสถานะปกติเพื่อเตรียมวาดช่องถัดไป
    }

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.neutral600
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );
  }

  @override
  bool shouldRepaint(covariant _InlineWheelPainter old) =>
      old.rotationAngle != rotationAngle;
}

class _StaticNeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final needleLength = radius * 0.35;

    final needlePath = Path()
      ..moveTo(center.dx, center.dy - needleLength) // ปลายเข็ม (ชี้ขึ้นบน)
      ..lineTo(center.dx - 9, center.dy) // ฐานซ้าย (กว้างขึ้นเล็กน้อยตามรูป)
      ..lineTo(center.dx + 9, center.dy) // ฐานขวา
      ..close();

    canvas.drawPath(
      needlePath,
      Paint()
        ..color = Colors.black38
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    canvas.drawPath(
      needlePath,
      Paint()
        ..color = Colors.white
        ..isAntiAlias = true,
    );

    canvas.drawCircle(
      center,
      15,
      Paint()
        ..color = AppColors.neutral600
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}
