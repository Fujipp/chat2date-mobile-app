// lib/screens/auth/face_verify_screen.dart
import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:chat2date/models/user.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:chat2date/models/face_scan_args.dart';
import 'package:chat2date/services/kyc_remote_service.dart';

/// ท่าที่ใช้ใน liveness
/// - center: มองตรงกลาง
/// - up / down / left / right: ขยับหัวตามทิศทาง
/// - smile: ยิ้มให้กล้อง
enum PoseStep { center, up, down, left, right, smile }

class FaceVerifyScreen extends ConsumerStatefulWidget {
  const FaceVerifyScreen({super.key});

  @override
  ConsumerState<FaceVerifyScreen> createState() => _FaceVerifyScreenState();
}

class _FaceVerifyScreenState extends ConsumerState<FaceVerifyScreen>
    with TickerProviderStateMixin {
  CameraController? _cam;
  FaceDetector? _detector;

  // debug
  bool _showDebug = false; // ถ้าอยากดูค่าพวก yaw/pitch/perf ให้เปิดเป็น true
  String _debugText = '';

  bool _cameraActive = false;
  bool _started = false; // กดปุ่ม "เริ่มสแกน" แล้วหรือยัง
  bool _navigating = false;

  // กัน processImage ซ้อนหลายเฟรม
  bool _processingFrame = false;

  // ===== Sequence =====
  static const double _stepSecondsRequired = 1.0; // ต้องค้างท่าละ ~1 วิ
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
  double? _pitch0; // baseline pitch (ใช้สำหรับก้ม/เงย)
  double? _yaw0; // baseline yaw
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
  static const double smileMin = 0.60; // ยิ้ม (smilingProbability)

  int get _totalSteps => _sequence.length;

  PoseStep get _currentStep =>
      _sequence.isEmpty ? PoseStep.center : _sequence[_currentIndex];

  // ===== Performance metrics =====
  static const int _minProcessIntervalMs = 70; // throttle ~14 fps
  DateTime? _lastProcessAt;
  double? _lastFrameMs;
  double? _lastProcessMs;

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
    // รูปแบบ (ทั้งหมด 6 step):
    // 1) center (มองตรงกลาง)
    // 2-5) สุ่ม 4 ท่าจาก {up, down, left, right, smile}
    // 6) center (กลับมามองตรงเพื่อถ่ายภาพ)
    final pool = <PoseStep>[
      PoseStep.up,
      PoseStep.down,
      PoseStep.left,
      PoseStep.right,
      PoseStep.smile,
    ]..shuffle(math.Random());

    final moves = pool.take(4).toList(); // เลือกมา 4 ท่าที่ไม่ซ้ำกัน

    _sequence
      ..clear()
      ..add(PoseStep.center)
      ..addAll(moves)
      ..add(PoseStep.center);

    _currentIndex = 0;
    _stepHoldSeconds = 0;
    _progressTarget = 0;
    _hint = _hintForStep(_currentStep);
  }

  String _hintForStep(PoseStep s) {
    switch (s) {
      case PoseStep.center:
        return 'หันหน้ามองตรงกลางจอ';
      case PoseStep.up:
        return 'เงยหน้าเล็กน้อย';
      case PoseStep.down:
        return 'ก้มหน้าเล็กน้อย';
      case PoseStep.left:
        return 'หันหน้าไปทางซ้าย';
      case PoseStep.right:
        return 'หันหน้าไปทางขวา';
      case PoseStep.smile:
        return 'ยิ้มให้กล้องหน่อย 😄';
    }
  }

  // ---------- Start ----------
  Future<void> _startScan() async {
    if (_started) return;

    setState(() {
      _started = true;
      _hint = 'กำลังเปิดกล้อง...';
    });

    // สร้าง detector ใหม่ (ปิดของเก่าก่อนถ้ามี)
    try {
      await _detector?.close();
    } catch (_) {}
    _detector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true, // ต้องเปิดเพื่อใช้ smilingProbability
        performanceMode: FaceDetectorMode.fast, // ให้ลื่นหน่อย
        enableContours: false,
        enableLandmarks: false,
        enableTracking: true,
      ),
    );

    await _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cams = await availableCameras();

      if (cams.isEmpty) {
        debugPrint('❌ ไม่พบกล้องใด ๆ ในอุปกรณ์นี้');
        if (mounted) {
          setState(() {
            _hint = 'ไม่พบกล้องในอุปกรณ์นี้';
            _started = false;
          });
        }
        return;
      }

      // พยายามใช้กล้องหน้า แต่ถ้าไม่มีจริง ๆ ให้ fallback เป็นตัวแรก
      CameraDescription selected;
      try {
        selected = cams.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
        );
      } catch (_) {
        selected = cams.first;
        debugPrint('⚠️ ไม่มีกล้องหน้า ใช้กล้องตัวแรกแทน: ${selected.name}');
      }

      final ctrl = CameraController(
        selected,
        ResolutionPreset.medium, // balance ระหว่างคุณภาพกับความลื่น
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      _cam = ctrl;

      await ctrl.initialize();
      if (!mounted) return;

      setState(() {
        _cameraActive = true;

        _sequence.clear();
        _currentIndex = 0;
        _stepHoldSeconds = 0;
        _progress = 0;
        _progressTarget = 0;

        _pitch0 = null;
        _yaw0 = null;
        _smoothYaw = null;
        _smoothPitch = null;

        _hint = 'เล็งใบหน้าให้อยู่ในวงกลม';
      });

      _lastFrameAt = DateTime.now();
      await ctrl.startImageStream(_onFrame);
      _startTick();
    } catch (e, s) {
      debugPrint('❌ initCamera error: $e\n$s');
      if (!mounted) return;
      setState(() {
        _hint = 'เปิดกล้องไม่สำเร็จ';
        _started = false;
        _cameraActive = false;
      });
    }
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
        _navigating ||
        _cam == null ||
        _detector == null) {
      return;
    }

    if (_processingFrame) return;
    _processingFrame = true;

    final dt = _frameDt();
    _lastFrameMs = dt * 1000.0;

    // throttle เฟรมไม่ให้ประมวลผลถี่เกินไป (ช่วย performance)
    final now = DateTime.now();
    if (_lastProcessAt != null &&
        now.difference(_lastProcessAt!).inMilliseconds <
            _minProcessIntervalMs) {
      _processingFrame = false;
      return;
    }
    final frameStart = now;

    try {
      final input = _toInputImage(img, _cam!.description.sensorOrientation);
      final faces = await _detector!.processImage(input);

      if (faces.isEmpty) {
        if (mounted) {
          setState(() {
            _hint = 'หาใบหน้าไม่พบ — ขยับเข้ากล้องอีกนิด';
          });
        }
        _stepHoldSeconds = 0;
        _lastProcessMs = DateTime.now()
            .difference(frameStart)
            .inMilliseconds
            .toDouble();
        _lastProcessAt = DateTime.now();
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
      final smileProb = f.smilingProbability ?? 0.0;

      final eyesOpen = (leftEye == null || rightEye == null)
          ? true
          : (leftEye >= eyeOpenMin && rightEye >= eyeOpenMin);

      // ถ้ายังไม่มี baseline ให้ใช้เฟรมนี้เป็น baseline (ตอนหน้าเกือบตรง + ไม่หลับตา)
      if (_pitch0 == null || _yaw0 == null) {
        final nearCenter = y.abs() <= yawCenterMax;
        if (eyesOpen && nearCenter) {
          _pitch0 = p;
          _yaw0 = y;
        }
      }

      // ถ้ายังไม่มี sequence ให้เริ่มสร้างเลย
      if (_sequence.isEmpty) {
        _buildRandomSequence();
      }

      // ===== Phase: ทำท่าตาม sequence ทีละท่า =====
      bool correct = false;
      String hint = _hint;

      switch (_currentStep) {
        case PoseStep.center:
          // มองตรงกลางจอ: yaw ใกล้ 0, ตาเปิด
          final nearCenter = y.abs() <= yawCenterMax;
          correct = eyesOpen && nearCenter;
          hint = correct ? 'ดีมาก… ค้างไว้' : 'หันหน้ามองตรงกลางจอ';
          break;

        case PoseStep.left:
          // หันหน้าไปทางซ้าย (เรา invert yaw แล้วสำหรับกล้องหน้า)
          correct = eyesOpen && y >= yawLeftMin;
          hint = correct ? 'ดีมาก… ค้างไว้' : 'หันหน้าไปทางซ้ายเล็กน้อย';
          break;

        case PoseStep.right:
          correct = eyesOpen && y <= -yawRightMin;
          hint = correct ? 'ดีมาก… ค้างไว้' : 'หันหน้าไปทางขวาเล็กน้อย';
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

        case PoseStep.smile:
          {
            final nearCenter = y.abs() <= yawCenterMax;
            final smiling = smileProb >= smileMin;
            // ต้องหันหน้าตรง + ยิ้ม
            correct = eyesOpen && nearCenter && smiling;
            hint = correct
                ? 'ดีมาก… ค้างยิ้มไว้เลย'
                : 'หันหน้าตรงแล้วลองยิ้มให้กล้อง 😄';
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

      // progressTarget = (index + ratio) / จำนวน step ทั้งหมด
      final total = _totalSteps == 0
          ? 0.0
          : (_currentIndex + stepRatio) / _totalSteps.toDouble();

      _progressTarget = total.clamp(0.0, 1.0);

      if (_stepHoldSeconds >= _stepSecondsRequired && !_navigating) {
        // ท่านี้สำเร็จ → ขยับไปท่าถัดไป หรือครบ sequence แล้ว
        if (_currentIndex < _totalSteps - 1) {
          _currentIndex++;
          _stepHoldSeconds = 0;
          hint = _hintForStep(_currentStep);
        } else {
          // ครบทุกท่าแล้ว (ตัวสุดท้ายคือ center) → ถ่ายภาพ + ไปโหลด/เรียก backend
          _progressTarget = 1.0;
          hint = 'กำลังตรวจสอบ...';
          _goLoading();
        }
      }

      _lastProcessMs = DateTime.now()
          .difference(frameStart)
          .inMilliseconds
          .toDouble();
      _lastProcessAt = DateTime.now();

      if (mounted) {
        setState(() {
          _hint = hint;
          if (_showDebug) {
            final fps = dt > 0 ? (1.0 / dt) : 0.0;
            _debugText =
                'STEP=${_currentStep} idx=$_currentIndex/${_totalSteps - 1} '
                'yaw=${y.toStringAsFixed(1)} pitch=${p.toStringAsFixed(1)} '
                'L=${(leftEye ?? -1).toStringAsFixed(2)} '
                'R=${(rightEye ?? -1).toStringAsFixed(2)} '
                'smile=${smileProb.toStringAsFixed(2)} '
                'hold=${_stepHoldSeconds.toStringAsFixed(2)} '
                'progTarget=${_progressTarget.toStringAsFixed(2)} '
                'frameMs=${_lastFrameMs?.toStringAsFixed(1)} '
                'procMs=${_lastProcessMs?.toStringAsFixed(1)} '
                'fps=${fps.toStringAsFixed(1)}';
          }
        });
      }
    } catch (e, s) {
      debugPrint('❌ _onFrame error: $e\n$s');
    } finally {
      _processingFrame = false;
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
  Future<Uint8List?> _captureSelfieBytes() async {
    try {
      if (_cam == null || !_cam!.value.isInitialized) return null;

      final x = await _cam!.takePicture();
      final file = File(x.path);
      final bytes = await file.readAsBytes();
      return bytes;
    } catch (e, s) {
      debugPrint('❌ _captureSelfieBytes error: $e\n$s');
      return null;
    }
  }

  Future<void> _goLoading() async {
    if (_navigating) return;
    _navigating = true;

    _stopTick();

    setState(() {
      _cameraActive = false;
      _started = false;
    });

    // เก็บ args จากหน้า IdOcrScreen ตั้งแต่ก่อน push หน้า loading
    final faceArgs =
        ModalRoute.of(context)?.settings.arguments as FaceScanArgs?;

    // หยุด image stream ก่อน (กันชนกับ takePicture)
    try {
      if (_cam != null &&
          _cam!.value.isInitialized &&
          _cam!.value.isStreamingImages) {
        await _cam!.stopImageStream();
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e, s) {
      debugPrint('❌ stopImageStream error: $e\n$s');
    }

    const int loadingMs = 3000;
    final DateTime loadingStartedAt = DateTime.now();

    // เปิดหน้าโหลด
    if (!mounted) return;
    Navigator.pushNamed(
      context,
      '/kyc-loading',
      arguments: {'demo': false, 'ms': loadingMs},
    );

    bool matched = false;
    double score = 0.0;
    Map<String, dynamic>? raw;

    try {
      // 1) ถ่าย selfie
      final selfieBytes = await _captureSelfieBytes();
      debugPrint('[KYC] selfieBytes is null? ${selfieBytes == null}');

      // 2) ปิดกล้องจริง ๆ
      await _teardownCamera();

      if (!mounted) return;

      final Uint8List? idCardFaceBytes = faceArgs?.cardFaceBytes;
      debugPrint('[KYC] idCardFaceBytes is null? ${idCardFaceBytes == null}');

      final userState = ref.read(userStoreProvider);
      final user = userState['user'] as User?;
      final cardFaceBytes = userState['cardFaceBytes'] as String?;

      // String? idFaceBase64 = (cardFaceBytes != null)
      //     ? base64Encode(cardFaceBytes)
      //     : null;
      String? selfieBase64 = (selfieBytes != null)
          ? base64Encode(selfieBytes)
          : null;

      const bool livenessPass = true;
      //final kyc = KycRemoteService(ref as Ref<Object?>);
      print(
        "llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll",
      );
      print(selfieBase64);
      //print(idFaceBase64);
      print(
        "llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll",
      );
      if (livenessPass && selfieBytes != null && cardFaceBytes != null) {
        print("Hellllllllllllllllllllllllllllllllllo");
        final vr = await ref
            .read(kycRemoteServiceProvider)
            .verifyFaceBytesVsIdFaceBase64(
              selfieBase64: selfieBase64,
              idFaceBase64: cardFaceBytes,
            );

        raw = vr;
        score = (vr['score'] ?? 0.0) * 1.0;
        matched = (vr['match'] == true) && score >= 0.80;

        debugPrint(
          '[KYC] RESULT from BE: match=$matched, score=$score, raw=$vr',
        );
      } else {
        debugPrint('[KYC] SKIP verify (missing selfieBytes or idFaceBase64)');
      }

      // ===== รอให้โหลดครบเวลา =====
      final elapsedMs = DateTime.now()
          .difference(loadingStartedAt)
          .inMilliseconds;
      if (elapsedMs < loadingMs) {
        await Future.delayed(Duration(milliseconds: loadingMs - elapsedMs));
      }

      if (!mounted) return;

      if (Navigator.canPop(context)) {
        Navigator.pop(context); // ปิด /kyc-loading
      }

      final resultArgs = {'matched': matched, 'score': score, 'raw': raw};

      if (livenessPass && matched) {
        Navigator.pushReplacementNamed(
          context,
          '/kyc-result-success',
          arguments: resultArgs,
        );
      } else {
        Navigator.pushReplacementNamed(
          context,
          '/kyc-result-fail',
          arguments: resultArgs,
        );
      }
    } catch (e, s) {
      debugPrint('❌ _goLoading error: $e\n$s');

      final elapsedMs = DateTime.now()
          .difference(loadingStartedAt)
          .inMilliseconds;
      if (elapsedMs < loadingMs) {
        await Future.delayed(Duration(milliseconds: loadingMs - elapsedMs));
      }

      if (!mounted) return;

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      final resultArgs = {
        'matched': false,
        'score': 0.0,
        'raw': {'error': e.toString()},
      };

      Navigator.pushReplacementNamed(
        context,
        '/kyc-result-fail',
        arguments: resultArgs,
      );
    } finally {
      _navigating = false;
    }
  }

  // ---------- helpers ----------
  InputImage _toInputImage(CameraImage image, int rotation) {
    final rotationEnum =
        InputImageRotationValue.fromRawValue(rotation) ??
        InputImageRotation.rotation0deg;

    // Android: YUV_420_888 (3 planes) → แปลงเป็น NV21 ให้ ML Kit ใช้ได้
    if (Platform.isAndroid && image.planes.length == 3) {
      final bytes = _yuv420ToNv21(image);

      final metadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotationEnum,
        format: InputImageFormat.nv21,
        bytesPerRow: image.width,
      );

      return InputImage.fromBytes(bytes: bytes, metadata: metadata);
    }

    // iOS / fallback: รวม bytes ตรง ๆ (BGRA8888 หรือรูปแบบเดียวกัน)
    final builder = BytesBuilder();
    for (final Plane plane in image.planes) {
      builder.add(plane.bytes);
    }
    final bytes = builder.toBytes();

    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotationEnum,
      format: InputImageFormat.bgra8888,
      bytesPerRow: image.planes.first.bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  /// แปลง CameraImage (YUV_420_888, 3 planes) → NV21 สำหรับ Android
  Uint8List _yuv420ToNv21(CameraImage image) {
    final int width = image.width;
    final int height = image.height;

    final int ySize = width * height;
    final int uvSize = width * height ~/ 2;

    final Uint8List nv21 = Uint8List(ySize + uvSize);

    // ----- Y plane -----
    final Plane yPlane = image.planes[0];
    int dstIndex = 0;
    for (int y = 0; y < height; y++) {
      final int srcIndex = y * yPlane.bytesPerRow;
      nv21.setRange(
        dstIndex,
        dstIndex + width,
        yPlane.bytes.sublist(srcIndex, srcIndex + width),
      );
      dstIndex += width;
    }

    // ----- UV planes (U + V) → interleave เป็น VU (NV21) -----
    final Plane uPlane = image.planes[1];
    final Plane vPlane = image.planes[2];

    final int uvRowStride = uPlane.bytesPerRow;
    final int uvPixelStride = uPlane.bytesPerPixel ?? 1;

    for (int y = 0; y < height ~/ 2; y++) {
      for (int x = 0; x < width ~/ 2; x++) {
        final int uvIndex = y * uvRowStride + x * uvPixelStride;

        nv21[dstIndex++] = vPlane.bytes[uvIndex]; // V ก่อน
        nv21[dstIndex++] = uPlane.bytes[uvIndex]; // U ตาม (NV21 = VU)
      }
    }

    return nv21;
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

    final isFront =
        _cam!.description.lensDirection == CameraLensDirection.front;

    return Center(
      child: Transform.scale(
        // scale ให้เต็มจอแบบไม่ยืดหน้า
        scale: previewRatio / deviceRatio,
        child: AspectRatio(
          aspectRatio: previewRatio,
          child: Transform(
            alignment: Alignment.center,
            // 🔁 ถ้าเป็นกล้องหน้าให้หมุนแกน Y 180° เพื่อ “แก้” mirror
            transform: isFront
                ? Matrix4.rotationY(math.pi)
                : Matrix4.identity(),
            child: CameraPreview(_cam!),
          ),
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
