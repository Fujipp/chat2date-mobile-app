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
  DateTime? _startedAt; // จับเวลาเริ่มสแกนไว้ทำ fallback

  // เปิดดูค่า debug ได้โดยตั้งเป็น true
  bool _showDebug = false;
  String _debugText = '';

  bool _cameraActive = false; // render preview/ประมวลผลเฟรมเฉพาะตอน true
  bool _started = false; // ยังไม่เริ่ม → แสดงแค่ปุ่ม + วงกลมเปล่า
  bool _busy = false; // ล็อค per-frame
  bool _navigating = false; // กันไปหน้า Loading ซ้ำ
  PoseStep _step = PoseStep.center;

  // ===== เกณฑ์ท่าทาง (องศา) =====
  static const double yawCenterMax = 12;
  static const double yawLeftMin = 14;
  static const double yawRightMin = 14;

  // ใช้ “delta จาก baseline” แทนการผูกกับทิศของอุปกรณ์
  static const double pitchDownDeltaMin = 10; // ต้องก้มลงจาก baseline ≥ 10°
  static const double pitchUpDeltaMin = 10; // ต้องเงยขึ้นจาก baseline ≥ 10°

  static const double eyeOpenMin = 0.25;

  // อยู่ท่าที่ถูกจะค่อย ๆ เติม progress
  static const double secondsPerStep = 0.8;
  double _stepAccumSeconds = 0; // เวลาอยู่ถูกท่า (ของ step ปัจจุบัน)
  double _progress = 0; // 0..1 วงแหวนเขียวรวม

  String _hint = 'แตะปุ่มเพื่อเริ่มสแกน';

  Timer? _tick; // ตัวจับเวลาให้ progress ลื่นขึ้น
  DateTime? _lastTick;

  // จับเวลาเฟรมจริง เพื่อกันเครื่องที่ fps ตก/พุ่ง
  DateTime? _lastFrameAt;

  // ===== กันค้าง / rollback =====
  static const double stuckThreshold = 3.0; // วินาทีที่ถือว่า “ค้าง” ในสเต็ป
  double _stuckSeconds = 0;
  DateTime? _stepEnteredAt;
  int _rollbackCount = 0;
  static const int rollbackLimit = 3; // ค้างแล้วถอย 3 ครั้ง → รี flow ใหม่

  // ===== Baseline & Smoothing =====
  double? _pitch0; // baseline pitch ตอนจบ CENTER
  double? _yaw0; // baseline yaw
  double? _smoothYaw;
  double? _smoothPitch;
  static const double _ema = 0.2; // smoothing factor

  // ---------- lifecycle ----------
  @override
  void dispose() {
    _stopTick();
    _cameraActive = false;
    _teardownCamera();
    super.dispose();
  }

  // ปิด stream → ปิด detector → dispose controller → เคลียร์ตัวแปร
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

  // ---------- Start ----------
  Future<void> _startScan() async {
    if (_started) return;
    setState(() {
      _started = true;
      _hint = 'กำลังเปิดกล้อง...';
      _startedAt = DateTime.now();
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
      _cameraActive = true; // เปิดให้ preview/อ่านเฟรมได้แล้ว
      _hint = 'มองตรงไว้สักครู่...';
      _step = PoseStep.center;
      _progress = 0;
      _stepAccumSeconds = 0;
      _stepEnteredAt = DateTime.now();
      _stuckSeconds = 0;
      _rollbackCount = 0;

      _pitch0 = null;
      _yaw0 = null;
      _smoothYaw = null;
      _smoothPitch = null;
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

      if (_navigating) return;

      final elapsed = _startedAt == null
          ? 0.0
          : now.difference(_startedAt!).inMilliseconds / 1000.0;

      // เวลาที่ค้างอยู่ใน "สเต็ปปัจจุบัน"
      final stay = _stepEnteredAt == null
          ? 0.0
          : now.difference(_stepEnteredAt!).inMilliseconds / 1000.0;

      // ===== เงื่อนไขจบแบบ “ไม่ใจร้อน” =====
      final onLastStep = (_step == PoseStep.up);

      // ใช้ progress สูงเฉพาะตอนอยู่สเต็ปสุดท้าย
      final progressHighOnLast = onLastStep && (_progress >= 0.92);

      // ผ่อนเพดาน “ค้างบนสุดท้าย” ให้สูงขึ้นหน่อย
      final upTooLong = onLastStep && stay > 4.5;

      if (upTooLong || progressHighOnLast) {
        _goLoading(); // ไปหน้าโหลด + call backend
        return;
      }

      // จบแบบปกติ: “กำลังจะจบสเต็ปสุดท้ายจริง ๆ”
      final aboutToFinishLast =
          (finished == 4 &&
          _step != PoseStep.done &&
          _stepAccumSeconds >= secondsPerStep * 0.75);

      // กัน edge case: ถ้าอยู่สเต็ปสุดท้ายและนิ่งนานมาก ๆ
      final stuckOnLast =
          (finished == 4 && !_navigating) &&
          (_progress >= 0.95 || elapsed > 18.0);

      if (_step == PoseStep.done ||
          finished >= 5 ||
          stuckOnLast ||
          _progress >= 0.985 ||
          aboutToFinishLast ||
          elapsed > 30.0) {
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
    if (!mounted ||
        !_cameraActive ||
        _busy ||
        !_started ||
        _cam == null ||
        _detector == null) {
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
        _accumulateStuck(false, 1 / 30.0);
        return;
      }

      final f = faces.first;

      // ML Kit: headEulerAngleY = yaw (ซ้าย/ขวา), headEulerAngleX = pitch (ก้ม/เงย)
      // กล้องหน้า: yaw ต้องกลับข้างให้ทิศถูกกับผู้ใช้
      final rawYaw = f.headEulerAngleY ?? 0.0;
      final rawPitch = f.headEulerAngleX ?? 0.0;
      final isFront =
          _cam!.description.lensDirection == CameraLensDirection.front;
      final yaw = isFront ? -rawYaw : rawYaw;
      final pitch = rawPitch;

      // ===== Smoothing (EMA) =====
      _smoothYaw = (_smoothYaw == null)
          ? yaw
          : _smoothYaw! + _ema * (yaw - _smoothYaw!);
      _smoothPitch = (_smoothPitch == null)
          ? pitch
          : _smoothPitch! + _ema * (pitch - _smoothPitch!);

      final leftEye = f.leftEyeOpenProbability;
      final rightEye = f.rightEyeOpenProbability;
      final eyesOpen = (leftEye == null || rightEye == null)
          ? true
          : (leftEye >= eyeOpenMin && rightEye >= eyeOpenMin);

      // เช็คว่าท่าปัจจุบัน “ถูกต้อง” ไหม
      bool correct = false;
      String hint = _hint;

      final y = _smoothYaw ?? yaw;
      final p = _smoothPitch ?? pitch;

      switch (_step) {
        case PoseStep.center:
          // เกณฑ์ CENTER: ตาเปิด + yaw ใกล้ศูนย์
          correct = eyesOpen && y.abs() <= yawCenterMax;
          hint = correct ? 'ดีมาก… ค้างไว้' : 'เล็งหน้าให้ตรง (อย่าหลับตา)';

          // ตั้ง baseline เมื่อนิ่งพอ
          if (correct) {
            _stepAccumSeconds += _frameDt();
            if (_stepAccumSeconds >= secondsPerStep / 2 && _pitch0 == null) {
              _pitch0 = p;
              _yaw0 = y;
            }
          } else {
            _stepAccumSeconds = 0;
          }
          break;

        case PoseStep.left:
          correct = eyesOpen && y <= -yawLeftMin;
          hint = correct ? 'ดีมาก… ค้างไว้' : 'หันหน้าไปทางขวา';
          break;

        case PoseStep.right:
          correct = eyesOpen && y >= yawRightMin;
          hint = correct ? 'ดีมาก… ค้างไว้' : 'หันหน้าไปทางซ้าย';
          break;

        case PoseStep.down:
          {
            // ใช้ delta จาก baseline เพื่อลดความต่างข้ามรุ่นเครื่อง
            final base = _pitch0 ?? 0.0;
            final delta = p - base; // ก้ม = ค่าอาจเพิ่ม/ลด ขึ้นกับดีไวซ์
            final downOk =
                delta >= pitchDownDeltaMin || (-delta) >= pitchDownDeltaMin;
            correct = eyesOpen && downOk;
            hint = correct ? 'ดีมาก… ค้างไว้' : 'ก้มหน้าเล็กน้อย';
            break;
          }

        case PoseStep.up:
          {
            final base = _pitch0 ?? 0.0;
            final delta = p - base; // เงย = ค่าอาจลด/เพิ่ม ขึ้นกับดีไวซ์
            final upOk =
                (-delta) >= pitchUpDeltaMin || delta >= pitchUpDeltaMin;
            correct = eyesOpen && upOk;
            hint = correct ? 'ดีมาก… ค้างไว้' : 'เงยหน้าเล็กน้อย';
            break;
          }

        case PoseStep.done:
          correct = true;
          hint = 'กำลังตรวจสอบ…';
          break;
      }

      // ===== ตรวจ “ค้าง” / เดินหน้า =====
      final dt = _frameDt();

      _accumulateStuck(correct, dt);
      if (_stuckSeconds >= stuckThreshold) {
        _rollbackStep();
        if (mounted) {
          setState(() => _hint = 'ลองใหม่อีกครั้ง — ย้อนสเต็ปก่อนหน้า');
        }
        return; // จบเฟรมนี้
      }

      if (_step == PoseStep.center) {
        // CENTER ถูก: advance เมื่อครบเวลาที่กำหนด + เก็บ baseline แน่นอน
        if (correct && _stepAccumSeconds >= secondsPerStep) {
          _pitch0 ??= p;
          _yaw0 ??= y;
          _stepAccumSeconds = 0;
          _advanceStep();
        }
      } else {
        if (correct && _step != PoseStep.done) {
          _stepAccumSeconds += dt.clamp(0.0, 0.1);
          if (_stepAccumSeconds >= secondsPerStep) {
            _stepAccumSeconds = 0;
            _advanceStep();
          }
        } else {
          if (_step != PoseStep.done) _stepAccumSeconds = 0;
        }
      }

      // อัปเดตข้อความ debug
      if (mounted) {
        setState(() {
          _hint = hint;
          _debugText =
              'yaw=${y.toStringAsFixed(1)}  pitch=${p.toStringAsFixed(1)}  '
              'L=${(leftEye ?? -1).toStringAsFixed(2)}  '
              'R=${(rightEye ?? -1).toStringAsFixed(2)}  '
              'step=$_step  t=${_stepAccumSeconds.toStringAsFixed(2)}  '
              'stuck=${_stuckSeconds.toStringAsFixed(2)}  '
              'p0=${_pitch0?.toStringAsFixed(1) ?? "-"}';
        });
      }
    } catch (_) {
      // ignore single-frame errors
    } finally {
      _busy = false;
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

  // ===== Helper: นับเวลาค้างในสเต็ปปัจจุบัน =====
  void _accumulateStuck(bool correct, double dt) {
    if (_step == PoseStep.done) {
      _stuckSeconds = 0;
      return;
    }
    _stepEnteredAt ??= DateTime.now();

    if (correct) {
      _stuckSeconds = 0; // เข้าเงื่อนไข ไม่ถือว่าค้าง
    } else {
      _stuckSeconds += dt.clamp(0.0, 0.2);
    }
  }

  // ===== Helper: หา step ก่อนหน้า และ rollback =====
  PoseStep _prevStep(PoseStep s) {
    switch (s) {
      case PoseStep.center:
        return PoseStep.center; // สุดทาง
      case PoseStep.left:
        return PoseStep.center;
      case PoseStep.right:
        return PoseStep.left;
      case PoseStep.down:
        return PoseStep.right;
      case PoseStep.up:
        return PoseStep.down;
      case PoseStep.done:
        return PoseStep.up;
    }
  }

  void _rollbackStep() {
    if (!mounted) return;
    _rollbackCount++;
    // รีใหม่ทั้ง flow ถ้าค้างซ้ำหลายครั้ง
    if (_rollbackCount >= rollbackLimit) {
      setState(() {
        _step = PoseStep.center;
        _stepEnteredAt = DateTime.now();
        _stepAccumSeconds = 0;
        _stuckSeconds = 0;
        _progress = 0;
        _hint = 'เริ่มใหม่อีกครั้ง — เล็งหน้าให้ตรง';
        _pitch0 = null;
        _yaw0 = null;
      });
      _rollbackCount = 0;
      return;
    }

    // ย้อนหนึ่งสเต็ป
    final back = _prevStep(_step);
    setState(() {
      _step = back;
      _stepEnteredAt = DateTime.now();
      _stepAccumSeconds = 0;
      _stuckSeconds = 0;
      switch (_step) {
        case PoseStep.center:
          _hint = 'เล็งหน้าให้ตรง (อย่าหลับตา)';
          break;
        case PoseStep.left:
          _hint = 'หันหน้าไปทางซ้าย';
          break;
        case PoseStep.right:
          _hint = 'หันหน้าไปทางขวา';
          break;
        case PoseStep.down:
          _hint = 'ก้มหน้าเล็กน้อย';
          break;
        case PoseStep.up:
          _hint = 'เงยหน้าเล็กน้อย';
          break;
        case PoseStep.done:
          _hint = 'กำลังตรวจสอบ…';
          break;
      }
    });
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
          _hint = 'ก้มหน้าเล็กน้อย';
          break;
        case PoseStep.down:
          _step = PoseStep.up;
          _hint = 'เงยหน้าเล็กน้อย';
          break;
        case PoseStep.up:
          _step = PoseStep.done;
          _hint = 'กำลังตรวจสอบ…';
          break;
        case PoseStep.done:
          break;
      }
      // รีตัววัดค้างทุกครั้งที่ขยับสเต็ป
      _stepEnteredAt = DateTime.now();
      _stuckSeconds = 0;
      _rollbackCount = 0; // เดินหน้าสำเร็จ ล้างตัวนับถอย
    });

    if (_step == PoseStep.done) {
      _goLoading();
    }
  }

  /// จับภาพนิ่งคุณภาพสูงสำหรับส่ง backend (หยุด stream ชั่วคราว)
  Future<Uint8List?> _captureSelfieBytes() async {
    try {
      if (_cam == null || !_cam!.value.isInitialized) return null;

      // ต้องหยุด stream ก่อนถึงจะถ่ายภาพนิ่งได้
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

    // เปิดหน้าโหลด (push) — รอจนกลับมา
    if (mounted) {
      await Navigator.pushNamed(context, '/kyc-loading');
    } else {
      return;
    }

    try {
      // 1) ถ่าย selfie
      final selfieBytes = await _captureSelfieBytes();

      // 2) ปิดกล้อง/หยุด tick
      _stopTick();
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

      // 4) เตรียมเรียก Backend
      final kyc = KycRemoteService(ApiBase.baseUrl);
      bool matched = false;

      // liveness สำเร็จเพราะเรามาถึงขั้น PoseStep.done แล้ว
      final bool livenessPass = true;

      // Backend ของ Dev ตอนนี้รับ: bytes (selfie) vs base64 (idFace)
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

      // 5) ปิดหน้าโหลด แล้วไปผลลัพธ์
      if (!mounted) return;
      Navigator.pop(context); // ปิด /kyc-loading

      if (!mounted) return;
      if (livenessPass && matched) {
        Navigator.pushReplacementNamed(context, '/kyc-result-success');
      } else {
        Navigator.pushReplacementNamed(context, '/kyc-result-fail');
      }
    } catch (_) {
      if (!mounted) return;
      // ปิดหน้าโหลด แล้วไป fail
      Navigator.pop(context);
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

    // iOS มักเป็น 1 plane = BGRA8888 / Android = YUV (หลาย plane)
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
              if (_cameraActive && _cam != null && _cam!.value.isInitialized)
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

              // วงแหวนสถานะ
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

              // ไอคอนเริ่ม (ก่อนเริ่มสแกน)
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

              // ปุ่มเริ่ม
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

              // Hint บนสุด
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

              // Debug overlay (เปิดได้ด้วย _showDebug = true)
              if (_started && _showDebug)
                Positioned(
                  top: 16,
                  left: 12,
                  right: 12,
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
