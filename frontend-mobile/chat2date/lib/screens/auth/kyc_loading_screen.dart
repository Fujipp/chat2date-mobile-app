// lib/screens/auth/kyc_loading_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chat2date/models/face_scan_args.dart';

class KycLoadingScreen extends StatefulWidget {
  const KycLoadingScreen({super.key});

  @override
  State<KycLoadingScreen> createState() => _KycLoadingScreenState();
}

class _KycLoadingScreenState extends State<KycLoadingScreen> {
  double _percent = 0; // 0..1
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // เดโม่: ไหล 0→100 ใน ~2.5s แล้ว “จำลองยิง API” ที่ปลายทาง
    _timer = Timer.periodic(const Duration(milliseconds: 25), (t) async {
      if (!mounted) return;
      setState(() {
        _percent = (_percent + 0.01).clamp(0.0, 1.0);
      });
      if (_percent >= 1.0) {
        t.cancel();
        // ปรับตรงนี้เป็นเรียก API จริง แล้ว return true/false
        final ok = await _fakeServerDecision();
        if (!mounted) return;
        Navigator.pop<bool>(context, ok); // ส่งผลกลับหน้าเดิม
      }
    });
  }

  Future<bool> _fakeServerDecision() async {
    // TODO: เรียก API จริง (ใช้ FaceScanArgs จาก arguments ได้)
    await Future.delayed(const Duration(milliseconds: 300));
    return true; // demo: ผ่าน
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pct = (_percent * 100).toInt();
    // โครง UI เรียบง่าย: วงกลม + % ตรงกลาง
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: 375,
          height: 812,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 2, color: Color(0x599CABC2)),
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Center(
            child: SizedBox(
              width: 211,
              height: 211,
              child: CustomPaint(
                painter: _CircleLoadingPainter(progress: _percent),
                child: Center(
                  child: Text(
                    '$pct%',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleLoadingPainter extends CustomPainter {
  final double progress;
  _CircleLoadingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2 - 6;

    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..color = const Color(0xFFE2E8F0);

    final prog = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF22C55E);

    final rect = Rect.fromCircle(center: center, radius: r);
    canvas.drawArc(rect, -90 * (3.1415926 / 180), 2 * 3.1415926, false, base);
    canvas.drawArc(
      rect,
      -90 * (3.1415926 / 180),
      (2 * 3.1415926) * progress,
      false,
      prog,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleLoadingPainter old) =>
      old.progress != progress;
}
