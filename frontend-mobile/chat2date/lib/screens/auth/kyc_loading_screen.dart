// lib/screens/auth/kyc_loading_screen.dart
import 'package:flutter/material.dart';

class KycLoadingScreen extends StatefulWidget {
  const KycLoadingScreen({super.key});

  @override
  State<KycLoadingScreen> createState() => _KycLoadingScreenState();
}

class _KycLoadingScreenState extends State<KycLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _anim;

  // เวลา default (ms) ถ้าไม่ได้ส่ง args มา
  int _durationMs = 3000;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _durationMs),
      lowerBound: 0,
      upperBound: 1,
    );

    // ใช้ curve ให้การวิ่ง 0-100 ดูลื่นขึ้น
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic);

    // อ่าน args หลัง build frame แรก
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        if (args['ms'] is int && (args['ms'] as int) > 0) {
          _durationMs = args['ms'] as int;
          _ctrl.duration = Duration(milliseconds: _durationMs);
        }
      }

      // วิ่งจาก 0 → 1 แค่ครั้งเดียว
      _ctrl
        ..reset()
        ..forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _anim,
            builder: (_, __) {
              final progress = _anim.value.clamp(0.0, 1.0);
              return SizedBox(
                width: 211,
                height: 211,
                child: CustomPaint(
                  painter: _CircleLoadingPainterDeterminate(progress: progress),
                  child: Center(
                    child: Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// วงกลมโหลดแบบ determinate: ฐานเทาเต็มวง + ส่วนเขียวเติมตาม progress 0–360°
class _CircleLoadingPainterDeterminate extends CustomPainter {
  final double progress; // 0..1

  _CircleLoadingPainterDeterminate({required this.progress});

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

    // วาดวงฐานสีเทาเต็มวง
    canvas.drawArc(rect, _deg(-90), _deg(360), false, base);

    // วาดส่วนเขียวเติมตาม progress (0–360°)
    final sweep = _deg(360 * progress.clamp(0.0, 1.0));
    if (sweep > 0) {
      canvas.drawArc(rect, _deg(-90), sweep, false, prog);
    }
  }

  double _deg(double d) => d * 3.141592653589793 / 180.0;

  @override
  bool shouldRepaint(covariant _CircleLoadingPainterDeterminate old) =>
      old.progress != progress;
}
