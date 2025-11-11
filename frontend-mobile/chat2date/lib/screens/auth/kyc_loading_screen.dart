import 'package:flutter/material.dart';

class KycLoadingScreen extends StatefulWidget {
  const KycLoadingScreen({super.key});

  @override
  State<KycLoadingScreen> createState() => _KycLoadingScreenState();
}

class _KycLoadingScreenState extends State<KycLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _demoAutoClose = false; // ใช้เฉพาะโหมดเดโม
  Duration _demoDelay = const Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0,
      upperBound: 1,
    )..repeat();

    // อ่าน arguments (ถ้ามี) เพื่อเปิดโหมดเดโม auto-close
    // ตัวอย่าง: Navigator.pushNamed(context, '/kyc-loading', arguments: {'demo': true, 'ms': 2500})
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        _demoAutoClose = (args['demo'] == true);
        if (args['ms'] is int && (args['ms'] as int) > 0) {
          _demoDelay = Duration(milliseconds: args['ms'] as int);
        }
        if (_demoAutoClose) {
          Future.delayed(_demoDelay, () {
            if (!mounted) return;
            Navigator.pop<bool>(context, true);
          });
        }
      }
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
            animation: _ctrl,
            builder: (_, __) {
              // ให้ progress วิ่งวนไปเรื่อย ๆ (0..1)
              final progress = _ctrl.value;
              return SizedBox(
                width: 211,
                height: 211,
                child: CustomPaint(
                  painter: _CircleLoadingPainterIndeterminate(
                    progress: progress,
                  ),
                  child: Center(
                    child: Text(
                      // โชว์ตัวเลขแบบ aesthetic (แค่เดโม)
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

/// วงกลมโหลดแบบ indeterminate: วาดฐานเทาเต็มวง + ส่วนเขียววิ่งโค้งเป็นสไลซ์
class _CircleLoadingPainterIndeterminate extends CustomPainter {
  final double progress; // 0..1
  _CircleLoadingPainterIndeterminate({required this.progress});

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

    // วาดสไลซ์เขียววิ่ง: ความยาวโค้ง ~ 90–140 องศา (ปรับเล็กน้อยให้ดูมีชีวิต)
    final sweep = _deg(90 + 50 * (0.5 - (progress - 0.5).abs()) * 2);
    final start = _deg(-90) + _deg(360) * progress;
    canvas.drawArc(rect, start, sweep, false, prog);
  }

  double _deg(double d) => d * 3.141592653589793 / 180.0;

  @override
  bool shouldRepaint(covariant _CircleLoadingPainterIndeterminate old) =>
      old.progress != progress;
}
