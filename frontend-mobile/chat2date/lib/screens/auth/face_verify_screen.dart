// lib/screens/auth/face_verify_screen.dart
import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'package:chat2date/models/face_scan_args.dart';

/// ขั้นตอนที่ต้องทำให้ครบ เพื่อกัน spoof ให้มีการ “ขยับจริง”
enum PoseStep { center, left, right, down, up, done }

class FaceVerifyScreen extends StatefulWidget {
  const FaceVerifyScreen({super.key});

  @override
  State<FaceVerifyScreen> createState() => _FaceVerifyScreenState();
}

class _FaceVerifyScreenState extends State<FaceVerifyScreen>
    with TickerProviderStateMixin {
  CameraController? _cam;
  FaceDetector? _detector;

  bool _started = false; // ยังไม่เริ่ม → แสดงแค่ปุ่ม + วงกลมเปล่า
  bool _busy = false; // ล็อค per-frame
  bool _navigating = false; // กันไปหน้า Loading ซ้ำ
  PoseStep _step = PoseStep.center;

  // เกณฑ์ท่าทาง (องศา)
  static const double yawCenterMax = 10; // ผ่อนปรนขึ้นเล็กน้อย
  static const double yawLeftMin = 15; // หันซ้าย
  static const double yawRightMin = 15; // หันขวา
  static const double pitchDownMin = 12; // ก้ม
  static const double pitchUpMin = 12; // เงย
  static const double eyeOpenMin = 0.25;

  // อยู่ท่าที่ถูกจะค่อย ๆ เติม progress
  static const double secondsPerStep = 1.0; // ต่อสเต็ป
  double _stepAccumSeconds = 0; // เวลาอยู่ถูกท่า (ของ step ปัจจุบัน)
  double _progress = 0; // 0..1 วงแหวนเขียวรวม

  String _hint = 'แตะปุ่มเพื่อเริ่มสแกน';

  Timer? _tick; // ตัวจับเวลาให้ progress ลื่นขึ้น
  DateTime? _lastTick;

  // จับเวลาเฟรมจริง เพื่อกันเครื่องที่ fps ตก/พุ่ง
  DateTime? _lastFrameAt;

  @override
  void dispose() {
    _stopTick();
    _detector?.close();
    _cam?.dispose();
    super.dispose();
  }

  // ---------- Start / Stop ----------
  Future<void> _startScan() async {
    if (_started) return;
    setState(() {
      _started = true;
      _hint = 'กำลังเปิดกล้อง...';
    });

    _detector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true, // ตาเปิด/ยิ้ม
        performanceMode: FaceDetectorMode.accurate,
        enableContours: false,
        enableLandmarks: false,
        enableTracking: true,
      ),
    );

    final cams = await availableCameras();
    final front = cams.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cams.first,
    );

    final ctrl = CameraController(
      front,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    _cam = ctrl;
    await ctrl.initialize();

    if (!mounted) return;
    setState(() {
      _hint = 'มองตรงไว้สักครู่...';
      _step = PoseStep.center;
      _progress = 0;
      _stepAccumSeconds = 0;
    });

    _lastFrameAt = DateTime.now();
    await ctrl.startImageStream(_onFrame);
    _startTick();
  }

  void _startTick() {
    _lastTick = DateTime.now();
    _tick = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final now = DateTime.now();
      _lastTick = now;

      // progress = (stepIndexFinished + stepAccum/secondsPerStep) / 5
      final finished = _finishedCount();
      final partial = (_step == PoseStep.done)
          ? 0.0
          : (_stepAccumSeconds / secondsPerStep).clamp(0.0, 1.0);

      final total = (finished + partial) / 5.0;

      if (mounted) {
        setState(() {
          _progress = _lerp(_progress, total, 0.25); // smooth
        });
      }

      // Fallback กันเคสเฟรมดับ/เงื่อนไขผ่านแล้วแต่ไม่ได้ _advanceStep
      if (!_navigating && (_finishedCount() >= 5 || _progress >= 0.999)) {
        _goLoading();
      }
    });
  }

  void _stopTick() {
    _tick?.cancel();
    _tick = null;
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  int _finishedCount() {
    switch (_step) {
      case PoseStep.center:
        return 0;
      case PoseStep.left:
        return 1;
      case PoseStep.right:
        return 2;
      case PoseStep.down:
        return 3;
      case PoseStep.up:
        return 4;
      case PoseStep.done:
        return 5;
    }
  }

  // ---------- per-frame ----------
  Future<void> _onFrame(CameraImage img) async {
    if (!mounted || _busy || !_started || _cam == null || _detector == null) {
      return;
    }
    _busy = true;
    try {
      final input = _toInputImage(img, _cam!.description.sensorOrientation);
      final faces = await _detector!.processImage(input);

      if (faces.isEmpty) {
        if (mounted) {
          setState(() => _hint = 'หาใบหน้าไม่พบ — ขยับเข้ากล้องอีกนิด');
        }
        _stepAccumSeconds = 0;
        return;
      }

      final f = faces.first;

      // === ปรับ yaw สำหรับกล้องหน้าให้ตรงกับการรับรู้ของผู้ใช้ ===
      final rawYaw = f.headEulerAngleY ?? 0.0; // ซ้าย/ขวา (กล้อง)
      final rawPitch = f.headEulerAngleX ?? 0.0; // ก้ม/เงย
      final isFront =
          _cam!.description.lensDirection == CameraLensDirection.front;
      final yaw = isFront ? -rawYaw : rawYaw; // กลับข้างสำหรับ selfie
      final pitch = rawPitch; // คงเดิม (ค่ามาตรฐาน: เงยเป็นค่าลบ)

      final leftEye = f.leftEyeOpenProbability;
      final rightEye = f.rightEyeOpenProbability;
      final eyesOpen = (leftEye == null || rightEye == null)
          ? true
          : (leftEye >= eyeOpenMin && rightEye >= eyeOpenMin);

      // เช็คว่าท่าปัจจุบัน “ถูกต้อง” ไหม
      bool correct = false;
      String hint = _hint;

      switch (_step) {
        case PoseStep.center:
          correct = eyesOpen && yaw.abs() <= yawCenterMax;
          hint = correct ? 'ดีมาก… ค้างไว้' : 'เล็งหน้าให้ตรง (อย่าหลับตา)';
          break;
        case PoseStep.left:
          correct = eyesOpen && yaw <= -yawLeftMin;
          hint = correct ? 'ดีมาก… ค้างไว้' : 'หันหน้าไปทางขวา';
          break;
        case PoseStep.right:
          correct = eyesOpen && yaw >= yawRightMin;
          hint = correct ? 'ดีมาก… ค้างไว้' : 'หันหน้าไปทางซ้าย';
          break;
        case PoseStep.down:
          correct = eyesOpen && pitch >= pitchDownMin;
          hint = correct ? 'ดีมาก… ค้างไว้' : 'เงยหน้าเล็กน้อย';
          break;
        case PoseStep.up:
          correct = eyesOpen && pitch <= -pitchUpMin;
          hint = correct ? 'ดีมาก… ค้างไว้' : 'ก้มหน้าเล็กน้อย';
          break;
        case PoseStep.done:
          correct = true;
          hint = 'เรียบร้อย';
          break;
      }

      // ใช้ delta time จริง ๆ จากเฟรมก่อนหน้า
      final now = DateTime.now();
      final dt = (_lastFrameAt == null)
          ? (1 / 30.0)
          : now.difference(_lastFrameAt!).inMilliseconds / 1000.0;
      _lastFrameAt = now;

      if (correct && _step != PoseStep.done) {
        _stepAccumSeconds += dt.clamp(0.0, 0.1); // กัน spike
        if (_stepAccumSeconds >= secondsPerStep) {
          _stepAccumSeconds = 0;
          _advanceStep();
        }
      } else {
        if (_step != PoseStep.done) _stepAccumSeconds = 0;
      }

      if (mounted) {
        setState(() => _hint = hint);
      }
    } catch (_) {
      // ignore single-frame errors
    } finally {
      _busy = false;
    }
  }

  void _advanceStep() {
    if (!mounted) return;
    setState(() {
      switch (_step) {
        case PoseStep.center:
          _step = PoseStep.left;
          _hint = 'หันหน้าไปทางซ้าย';
          break;
        case PoseStep.left:
          _step = PoseStep.right;
          _hint = 'หันหน้าไปทางขวา';
          break;
        case PoseStep.right:
          _step = PoseStep.down;
          _hint = 'ก้มหน้าเล็กน้อย'; // แก้ให้ตรงกับเงื่อนไข down
          break;
        case PoseStep.down:
          _step = PoseStep.up;
          _hint = 'เงยหน้าเล็กน้อย'; // แก้ให้ตรงกับเงื่อนไข up
          break;
        case PoseStep.up:
          _step = PoseStep.done;
          _hint = 'กำลังตรวจสอบ…';
          break;
        case PoseStep.done:
          break;
      }
    });

    if (_step == PoseStep.done) {
      _goLoading();
    }
  }

  Future<void> _goLoading() async {
    if (_navigating) return;
    _navigating = true;

    _stopTick();
    try {
      await _cam?.stopImageStream();
    } catch (_) {}
    if (!mounted) return;

    final args = ModalRoute.of(context)?.settings.arguments as FaceScanArgs?;
    final ok = await Navigator.pushNamed<bool>(
      context,
      '/kyc-loading',
      arguments: args,
    );

    if (!mounted) return;
    if (ok == true) {
      Navigator.pushReplacementNamed(context, '/kyc-result-success');
    } else {
      Navigator.pushReplacementNamed(context, '/kyc-result-fail');
    }
  }

  // ---------- helpers ----------
  InputImage _toInputImage(CameraImage img, int rotation) {
    final builder = BytesBuilder(copy: false);
    for (final Plane p in img.planes) {
      builder.add(p.bytes);
    }
    final bytes = builder.toBytes();

    final metadata = InputImageMetadata(
      size: Size(img.width.toDouble(), img.height.toDouble()),
      rotation:
          InputImageRotationValue.fromRawValue(rotation) ??
          InputImageRotation.rotation0deg,
      format:
          InputImageFormatValue.fromRawValue(img.format.raw) ??
          InputImageFormat.nv21,
      bytesPerRow: img.planes.first.bytesPerRow,
    );
    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
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
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              if (_started && _cam?.value.isInitialized == true)
                Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _cam!.value.previewSize!.height,
                      height: _cam!.value.previewSize!.width,
                      child: CameraPreview(_cam!),
                    ),
                  ),
                ),

              Center(
                child: SizedBox(
                  width: 260,
                  height: 260,
                  child: CustomPaint(
                    painter: _FaceScanRingPainter(
                      progress: _progress,
                      tickCount: 72,
                    ),
                  ),
                ),
              ),

              if (!_started)
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD8DEE6)),
                    ),
                    child: const Icon(
                      Icons.tag_faces,
                      color: Color(0xFFD8DEE6),
                    ),
                  ),
                ),

              if (!_started)
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 36,
                  child: SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: _startScan,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF5CE1E6),
                      ),
                      child: const Text(
                        'เริ่มสแกน',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),

              if (_started)
                Positioned(
                  top: 96,
                  left: 24,
                  right: 24,
                  child: Text(
                    _hint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== Painter: วงกลมวางหน้า (ขีดเทา + ขีดเขียวตาม progress) =====
class _FaceScanRingPainter extends CustomPainter {
  final double progress; // 0..1
  final int tickCount;

  _FaceScanRingPainter({required this.progress, this.tickCount = 72});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2;
    final outerR = radius;
    final innerR = outerR - 16;

    const baseColor = Color(0xFFE2E8F0); // เทาพื้น
    const fillColor = Color(0xFF22C55E); // เขียว
    const tickWidth = 6.0;
    const tickCap = StrokeCap.round;
    const tickIn = 10.0;
    const tickOut = 26.0;
    final tickLen = tickOut - tickIn;

    final basePaint = Paint()
      ..color = baseColor
      ..strokeWidth = tickWidth
      ..strokeCap = tickCap;

    final fillPaint = Paint()
      ..color = fillColor
      ..strokeWidth = tickWidth
      ..strokeCap = tickCap;

    for (int i = 0; i < tickCount; i++) {
      final t = i / tickCount;
      final ang = (t * 360.0 - 90) * math.pi / 180.0;
      final p1 = Offset(
        center.dx + (innerR + tickIn) * math.cos(ang),
        center.dy + (innerR + tickIn) * math.sin(ang),
      );
      final p2 = Offset(
        center.dx + (innerR + tickOut) * math.cos(ang),
        center.dy + (innerR + tickOut) * math.sin(ang),
      );
      canvas.drawLine(p1, p2, basePaint);
    }

    final filled = (progress.clamp(0.0, 1.0) * tickCount);
    final fullTicks = filled.floor();
    final frac = filled - fullTicks;

    for (int i = 0; i < fullTicks; i++) {
      final t = i / tickCount;
      final ang = (t * 360.0 - 90) * math.pi / 180.0;
      final p1 = Offset(
        center.dx + (innerR + tickIn) * math.cos(ang),
        center.dy + (innerR + tickIn) * math.sin(ang),
      );
      final p2 = Offset(
        center.dx + (innerR + tickOut) * math.cos(ang),
        center.dy + (innerR + tickOut) * math.sin(ang),
      );
      canvas.drawLine(p1, p2, fillPaint);
    }

    if (frac > 0 && fullTicks < tickCount) {
      final i = fullTicks;
      final t = i / tickCount;
      final ang = (t * 360.0 - 90) * math.pi / 180.0;

      final p1 = Offset(
        center.dx + (innerR + tickIn) * math.cos(ang),
        center.dy + (innerR + tickIn) * math.sin(ang),
      );
      final pPartial = Offset(
        center.dx + (innerR + tickIn + tickLen * frac) * math.cos(ang),
        center.dy + (innerR + tickIn + tickLen * frac) * math.sin(ang),
      );
      canvas.drawLine(p1, pPartial, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FaceScanRingPainter old) =>
      old.progress != progress || old.tickCount != tickCount;
}
