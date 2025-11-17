// lib/screens/auth/face_verify_screen.dart
import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'package:chat2date/config/backend_base.dart';
import 'package:chat2date/models/face_scan_args.dart';
import 'package:chat2date/services/kyc_remote_service.dart';

/// ท่าที่ใช้ใน liveness
enum PoseStep { left, right, down, up, blink }

class FaceVerifyScreen extends StatefulWidget {
  const FaceVerifyScreen({super.key});

  @override
  State<FaceVerifyScreen> createState() => _FaceVerifyScreenState();
}

class _FaceVerifyScreenState extends State<FaceVerifyScreen>
    with TickerProviderStateMixin {
  CameraController? _cam;
  FaceDetector? _detector;

  // debug
  bool _showDebug = false;
  String _debugText = '';

  bool _cameraActive = false;
  bool _started = false; // กดปุ่ม "เริ่มสแกน" แล้วหรือยัง
  bool _navigating = false;

  // ===== Phase 0: จัดหน้าให้อยู่กลางวง 2 วิ =====
  static const double _alignSecondsRequired = 2.0;
  bool _alignPhase = false; // อยู่ช่วง "จัดหน้าให้ตรง"
  bool _alignmentDone = false;
  double _alignSeconds = 0;

  // ===== Phase 1: ทำท่าทีละอย่าง (สุ่ม 5 ท่า) =====
  static const double _stepSecondsRequired = 1.2; // ต้องค้างท่าละ ~1.2 วิ
  final List<PoseStep> _sequence = [];
  int _currentIndex = 0; // index ของท่าปัจจุบันใน sequence
  double _stepHoldSeconds = 0; // เวลาที่อยู่ในท่าปัจจุบันแบบ "ถูกต้อง"

  // progress วงแหวน (0..1)
  double _progress = 0.0;
  double _progressTarget = 0.0; // ให้ Timer ค่อย ๆ ไล่เข้าไปหา

  String _hint = 'แตะปุ่มเพื่อเริ่มสแกน';

  Timer? _tick; // ให้ progress ลื่นขึ้นเรื่อย ๆ
  DateTime? _lastFrameAt;

  // ===== Baseline & Smoothing =====
  double? _pitch0; // baseline pitch ตอนจัดหน้าเสร็จ (ใช้สำหรับก้ม/เงย)
  double? _yaw0; // baseline yaw (เผื่ออยากใช้ภายหลัง)
  double? _smoothYaw;
  double? _smoothPitch;
  static const double _ema = 0.2; // smoothing factor

  // ===== เกณฑ์ท่าทาง =====
  static const double yawCenterMax = 12; // หน้าตรง
  static const double yawLeftMin = 15; // หันซ้าย
  static const double yawRightMin = 15; // หันขวา

  static const double pitchDownDeltaMin = 10; // ก้มจาก baseline ≥ 10°
  static const double pitchUpDeltaMin = 10; // เงยจาก baseline ≥ 10°

  static const double eyeOpenMin = 0.4; // ตาเปิด (ค่อนข้างชัด)
  static const double eyeClosedMax = 0.2; // ตาปิดชัด ๆ (สำหรับ blink)

  int get _totalSteps => _sequence.length;

  PoseStep get _currentStep =>
      _sequence.isEmpty ? PoseStep.left : _sequence[_currentIndex];

  // ---------- lifecycle ----------
  @override
  void dispose() {
    _stopTick();
    _cameraActive = false;
    _teardownCamera();
    super.dispose();
  }

  Future<void> _teardownCamera() async {
    final ctrl = _cam;
    try {
      if (ctrl != null &&
          ctrl.value.isInitialized &&
          ctrl.value.isStreamingImages) {
        await ctrl.stopImageStream();
      }
    } catch (_) {}
    try {
      await _detector?.close();
    } catch (_) {}
    try {
      await ctrl?.dispose();
    } catch (_) {}
    _detector = null;
    _cam = null;
  }

  // ---------- Sequence / Hint ----------
  void _buildRandomSequence() {
    // มีครบ 5 ท่า → สุ่มลำดับใหม่ทุกครั้ง
    final steps = <PoseStep>[
      PoseStep.left,
      PoseStep.right,
      PoseStep.down,
      PoseStep.up,
      PoseStep.blink,
    ];
    steps.shuffle(math.Random());

    _sequence
      ..clear()
      ..addAll(steps);
    _currentIndex = 0;
    _stepHoldSeconds = 0;
    _progressTarget = 0; // เริ่ม 0 → ท่าละ 20% (1/5)
    _hint = _hintForStep(_currentStep);
  }

  String _hintForStep(PoseStep s) {
    switch (s) {
      case PoseStep.left:
        return 'หันหน้าไปทางซ้าย';
      case PoseStep.right:
        return 'หันหน้าไปทางขวา';
      case PoseStep.down:
        return 'ก้มหน้าเล็กน้อย';
      case PoseStep.up:
        return 'เงยหน้าเล็กน้อย';
      case PoseStep.blink:
        return 'กระพริบตา 2 ครั้ง';
    }
  }

  // ---------- Start ----------
  Future<void> _startScan() async {
    if (_started) return;
    setState(() {
      _started = true;
      _hint = 'กำลังเปิดกล้อง...';
    });

    _detector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
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
      _cameraActive = true;

      // Phase 0: เริ่มจากให้ user จัดหน้าให้อยู่กลางวงก่อน
      _alignPhase = true;
      _alignmentDone = false;
      _alignSeconds = 0;

      _sequence.clear();
      _currentIndex = 0;
      _stepHoldSeconds = 0;
      _progress = 0;
      _progressTarget = 0;

      _pitch0 = null;
      _yaw0 = null;
      _smoothYaw = null;
      _smoothPitch = null;

      _hint = 'เล็งใบหน้าให้อยู่กลางวง (อย่าหลับตา)';
    });

    _lastFrameAt = DateTime.now();
    await ctrl.startImageStream(_onFrame);
    _startTick();
  }

  void _startTick() {
    _tick = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted) return;
      setState(() {
        _progress = _lerp(_progress, _progressTarget, 0.20);
      });
    });
  }

  void _stopTick() {
    _tick?.cancel();
    _tick = null;
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  // ---------- per-frame ----------
  Future<void> _onFrame(CameraImage img) async {
    if (!mounted ||
        !_cameraActive ||
        !_started ||
        _cam == null ||
        _detector == null) {
      return;
    }

    final dt = _frameDt();

    try {
      final input = _toInputImage(img, _cam!.description.sensorOrientation);
      final faces = await _detector!.processImage(input);

      if (faces.isEmpty) {
        if (mounted) {
          setState(() {
            _hint = 'หาใบหน้าไม่พบ — ขยับเข้ากล้องอีกนิด';
          });
        }
        // alignment / step ถือว่าหลุด
        if (_alignPhase) _alignSeconds = 0;
        _stepHoldSeconds = 0;
        return;
      }

      final f = faces.first;

      // ML Kit: headEulerAngleY = yaw, headEulerAngleX = pitch
      final rawYaw = f.headEulerAngleY ?? 0.0;
      final rawPitch = f.headEulerAngleX ?? 0.0;
      final isFront =
          _cam!.description.lensDirection == CameraLensDirection.front;
      final yaw = isFront ? -rawYaw : rawYaw;
      final pitch = rawPitch;

      // smoothing
      _smoothYaw = (_smoothYaw == null)
          ? yaw
          : _smoothYaw! + _ema * (yaw - _smoothYaw!);
      _smoothPitch = (_smoothPitch == null)
          ? pitch
          : _smoothPitch! + _ema * (pitch - _smoothPitch!);

      final y = _smoothYaw ?? yaw;
      final p = _smoothPitch ?? pitch;

      final leftEye = f.leftEyeOpenProbability;
      final rightEye = f.rightEyeOpenProbability;

      final eyesOpen = (leftEye == null || rightEye == null)
          ? true
          : (leftEye >= eyeOpenMin && rightEye >= eyeOpenMin);

      // ===== Phase 0: ให้จัดหน้าให้อยู่กลางวง 2 วิ ก่อนเริ่มสุ่มท่า =====
      if (_alignPhase && !_alignmentDone) {
        final centerOk = eyesOpen && y.abs() <= yawCenterMax;

        if (centerOk) {
          _alignSeconds += dt.clamp(0.0, 0.25);
        } else {
          _alignSeconds = 0;
        }

        final alignRatio = (_alignSeconds / _alignSecondsRequired).clamp(
          0.0,
          1.0,
        );

        _progressTarget = 0.0; // ยังไม่เริ่มคิด 5 ท่า → progress จริง = 0

        if (mounted) {
          setState(() {
            _hint = centerOk
                ? 'ค้างไว้... กำลังจัดตำแหน่งใบหน้า (${_alignSeconds.toStringAsFixed(1)}/${_alignSecondsRequired.toStringAsFixed(1)} วินาที)'
                : 'เล็งใบหน้าให้อยู่กลางวง (อย่าหลับตา)';

            if (_showDebug) {
              _debugText =
                  'ALIGN | yaw=${y.toStringAsFixed(1)} pitch=${p.toStringAsFixed(1)} '
                  't=${_alignSeconds.toStringAsFixed(2)} ratio=${alignRatio.toStringAsFixed(2)}';
            }
          });
        }

        if (_alignSeconds >= _alignSecondsRequired) {
          // lock baseline
          _pitch0 = p;
          _yaw0 = y;
          _alignmentDone = true;
          _alignPhase = false;

          // เริ่ม sequence 5 ท่าที่สุ่ม
          _buildRandomSequence();

          if (mounted) {
            setState(() {
              _hint = _hintForStep(_currentStep);
            });
          }
        }

        return;
      }

      // ถ้ายังไม่มี sequence (เผื่อเคสแปลก ๆ) ก็ไม่ต้องไปต่อ
      if (!_alignmentDone || _sequence.isEmpty) {
        return;
      }

      // ===== Phase 1: ทำท่าตาม sequence ทีละท่า =====
      bool correct = false;
      String hint = _hint;

      switch (_currentStep) {
        case PoseStep.left:
          correct = eyesOpen && y <= -yawLeftMin;
          hint = correct ? 'ดีมาก… ค้างไว้' : 'หันหน้าไปทางขวาเล็กน้อย';
          break;

        case PoseStep.right:
          correct = eyesOpen && y >= yawRightMin;
          hint = correct ? 'ดีมาก… ค้างไว้' : 'หันหน้าไปทางซ้ายเล็กน้อย';
          break;

        case PoseStep.down:
          {
            final base = _pitch0 ?? 0.0;
            final delta = p - base;
            final downOk =
                delta >= pitchDownDeltaMin || (-delta) >= pitchDownDeltaMin;
            correct = eyesOpen && downOk;
            hint = correct ? 'ดีมาก… ค้างไว้' : 'ก้มหน้าเล็กน้อย';
            break;
          }

        case PoseStep.up:
          {
            final base = _pitch0 ?? 0.0;
            final delta = p - base;
            final upOk =
                (-delta) >= pitchUpDeltaMin || delta >= pitchUpDeltaMin;
            correct = eyesOpen && upOk;
            hint = correct ? 'ดีมาก… ค้างไว้' : 'เงยหน้าเล็กน้อย';
            break;
          }

        case PoseStep.blink:
          {
            // หลับตาชัด ๆ + หน้าเกือบตรง
            final eyesClosed =
                (leftEye != null &&
                rightEye != null &&
                leftEye < eyeClosedMax &&
                rightEye < eyeClosedMax);

            correct = eyesClosed && y.abs() <= yawCenterMax;
            hint = correct
                ? 'ดีมาก… ค้างไว้'
                : 'กระพริบตาเร็ว ๆ 2 ครั้ง แล้วมองตรง';
            break;
          }
      }

      if (correct) {
        _stepHoldSeconds += dt.clamp(0.0, 0.25);
      } else {
        _stepHoldSeconds = 0;
      }

      final stepRatio = (_stepHoldSeconds / _stepSecondsRequired).clamp(
        0.0,
        1.0,
      );

      // ท่าละ 20% → progressTarget = (index + ratio) / 5
      final total = _totalSteps == 0
          ? 0.0
          : (_currentIndex + stepRatio) / _totalSteps.toDouble();

      _progressTarget = total.clamp(0.0, 1.0);

      if (_stepHoldSeconds >= _stepSecondsRequired && !_navigating) {
        // ท่านี้สำเร็จ → ขยับไปท่าถัดไป หรือครบ 5 ท่าแล้ว
        if (_currentIndex < _totalSteps - 1) {
          _currentIndex++;
          _stepHoldSeconds = 0;
          hint = _hintForStep(_currentStep);
        } else {
          // ครบทั้ง 5 ท่าแล้ว → 100% → ไปโหลด/เรียก backend
          _progressTarget = 1.0;
          hint = 'กำลังตรวจสอบ...';
          _goLoading();
        }
      }

      if (mounted) {
        setState(() {
          _hint = hint;
          if (_showDebug) {
            _debugText =
                'STEP=${_currentStep} idx=$_currentIndex/${_totalSteps - 1} '
                'yaw=${y.toStringAsFixed(1)} pitch=${p.toStringAsFixed(1)} '
                'L=${(leftEye ?? -1).toStringAsFixed(2)} '
                'R=${(rightEye ?? -1).toStringAsFixed(2)} '
                'hold=${_stepHoldSeconds.toStringAsFixed(2)} '
                'progTarget=${_progressTarget.toStringAsFixed(2)}';
          }
        });
      }
    } catch (_) {
      // ignore single-frame errors
    }
  }

  double _frameDt() {
    final now = DateTime.now();
    final dt = (_lastFrameAt == null)
        ? (1 / 30.0)
        : now.difference(_lastFrameAt!).inMilliseconds / 1000.0;
    _lastFrameAt = now;
    return dt;
  }

  // ---------- ไปหน้าโหลด + เรียก backend ----------
  /// จับภาพนิ่งคุณภาพสูงสำหรับส่ง backend (หยุด stream ชั่วคราว)
  Future<Uint8List?> _captureSelfieBytes() async {
    try {
      if (_cam == null || !_cam!.value.isInitialized) return null;

      if (_cam!.value.isStreamingImages) {
        await _cam!.stopImageStream();
      }

      final x = await _cam!.takePicture();
      final file = File(x.path);
      final bytes = await file.readAsBytes();
      return bytes;
    } catch (_) {
      return null;
    }
  }

  Future<void> _goLoading() async {
    if (_navigating) return;
    _navigating = true;

    _stopTick();

    // ให้เวลาแอนิเมชันโหลด 0-100 อย่างน้อยเท่ากับ loadingMs
    const int loadingMs = 3000;
    final DateTime loadingStartedAt = DateTime.now();

    // เปิดหน้าโหลด (ไม่ await) แต่ส่ง ms ไปให้ KycLoading ใช้เป็น duration
    if (mounted) {
      Navigator.pushNamed(
        context,
        '/kyc-loading',
        arguments: {'demo': false, 'ms': loadingMs},
      );
    } else {
      return;
    }

    try {
      // 1) ถ่าย selfie
      final selfieBytes = await _captureSelfieBytes();

      // 2) ปิดกล้อง
      if (mounted) {
        setState(() {
          _cameraActive = false;
          _started = false;
        });
      }
      await _teardownCamera();

      if (!mounted) return;

      // 3) รับ args จากหน้า IdOcrScreen
      final args = ModalRoute.of(context)?.settings.arguments as FaceScanArgs?;
      final Uint8List? idCardFaceBytes = args?.cardFaceBytes;

      // 4) เรียก Backend
      final kyc = KycRemoteService(ApiBase.baseUrl);
      bool matched = false;
      const bool livenessPass = true;

      String? idFaceBase64 = (idCardFaceBytes != null)
          ? base64Encode(idCardFaceBytes)
          : null;

      if (livenessPass && selfieBytes != null && idFaceBase64 != null) {
        final vr = await kyc.verifyFaceBytesVsIdFaceBase64(
          selfieBytes: selfieBytes,
          idFaceBase64: idFaceBase64,
        );
        final score = (vr['score'] ?? 0.0) * 1.0;
        matched = (vr['match'] == true) && score >= 0.80;
      }

      if (!mounted) return;

      // === รอให้ animation บนหน้าโหลดถึง 100% ก่อนค่อย pop ===
      final elapsedMs = DateTime.now()
          .difference(loadingStartedAt)
          .inMilliseconds;
      if (elapsedMs < loadingMs) {
        await Future.delayed(Duration(milliseconds: loadingMs - elapsedMs));
      }

      // 5) ปิดหน้าโหลด แล้วไปผลลัพธ์
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // ปิด /kyc-loading
      }

      if (livenessPass && matched) {
        Navigator.pushReplacementNamed(context, '/kyc-result-success');
      } else {
        Navigator.pushReplacementNamed(context, '/kyc-result-fail');
      }
    } catch (_) {
      if (!mounted) return;

      // error ก็ยังเคารพ minimum loading time เหมือนกัน
      final elapsedMs = DateTime.now()
          .difference(loadingStartedAt)
          .inMilliseconds;
      if (elapsedMs < loadingMs) {
        await Future.delayed(Duration(milliseconds: loadingMs - elapsedMs));
      }

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      Navigator.pushReplacementNamed(context, '/kyc-result-fail');
    } finally {
      _navigating = false;
    }
  }

  // ---------- helpers ----------
  InputImage _toInputImage(CameraImage img, int rotation) {
    final builder = BytesBuilder(copy: false);
    for (final Plane p in img.planes) {
      builder.add(p.bytes);
    }
    final bytes = builder.toBytes();

    final isBgra = img.planes.length == 1;

    final metadata = InputImageMetadata(
      size: Size(img.width.toDouble(), img.height.toDouble()),
      rotation:
          InputImageRotationValue.fromRawValue(rotation) ??
          InputImageRotation.rotation0deg,
      format: isBgra
          ? InputImageFormat.bgra8888
          : (InputImageFormatValue.fromRawValue(img.format.raw) ??
                InputImageFormat.nv21),
      bytesPerRow: img.planes.first.bytesPerRow,
    );
    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  // ---------- UI ----------
  Widget _buildFullScreenPreview() {
    if (!_cameraActive || _cam == null || !_cam!.value.isInitialized) {
      return const SizedBox.shrink();
    }

    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;

    double previewRatio = _cam!.value.aspectRatio;
    if (size.height > size.width) {
      previewRatio = 1 / previewRatio;
    }

    return Center(
      child: Transform.scale(
        // scale ให้เต็มจอแบบไม่ยืดหน้า
        scale: previewRatio / deviceRatio,
        child: AspectRatio(
          aspectRatio: previewRatio,
          child: CameraPreview(_cam!),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // กล้องเต็มจอ
            Positioned.fill(child: _buildFullScreenPreview()),

            // วงแหวน progress
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

            // ไอคอนก่อนเริ่ม
            if (!_started)
              const Center(
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      shape: CircleBorder(
                        side: BorderSide(color: Color(0xFFD8DEE6)),
                      ),
                    ),
                    child: Icon(Icons.tag_faces, color: Color(0xFFD8DEE6)),
                  ),
                ),
              ),

            // ปุ่มเริ่ม
            if (!_started)
              Positioned(
                left: 24,
                right: 24,
                bottom: 24,
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

            // Hint บนสุด
            if (_started)
              Positioned(
                top: 24,
                left: 24,
                right: 24,
                child: Text(
                  _hint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        blurRadius: 6,
                        color: Colors.black54,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),

            // Debug overlay
            if (_started && _showDebug)
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _debugText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      height: 1.2,
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

    const baseColor = Color(0xFFE2E8F0);
    const fillColor = Color(0xFF22C55E);
    const tickWidth = 6.0;
    const strokeJoin = StrokeCap.round;
    const tickIn = 10.0;
    const tickOut = 26.0;
    final tickLen = tickOut - tickIn;

    final basePaint = Paint()
      ..color = baseColor
      ..strokeWidth = tickWidth
      ..strokeCap = strokeJoin;

    final fillPaint = Paint()
      ..color = fillColor
      ..strokeWidth = tickWidth
      ..strokeCap = strokeJoin;

    // เส้นเทาพื้น
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

    // เส้นเขียวเต็ม ๆ
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

    // เส้นเขียวเสี้ยวสุดท้าย
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
