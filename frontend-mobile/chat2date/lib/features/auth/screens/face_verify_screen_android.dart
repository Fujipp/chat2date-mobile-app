// lib/screens/auth/face_verify_screen_android.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:chat2date/components/design_system/index.dart';
import 'package:chat2date/core/theme/tokens/colors/text_colors.dart';
import 'package:chat2date/models/face_scan_args.dart';
import 'package:chat2date/services/kyc_remote_service.dart';
// import 'package:chat2date/stores/user_store.dart'; // removed: unused
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

enum PoseStep { center, smile, blink, lookLeft, lookRight }

class FaceVerifyScreenAndroid extends ConsumerStatefulWidget {
  const FaceVerifyScreenAndroid({super.key});

  @override
  ConsumerState<FaceVerifyScreenAndroid> createState() =>
      _FaceVerifyScreenAndroidState();
}

class _FaceVerifyScreenAndroidState
    extends ConsumerState<FaceVerifyScreenAndroid>
    with TickerProviderStateMixin {
  CameraController? _cam;
  FaceDetector? _detector;

  final bool _showDebug = false;
  String _debugText = '';

  bool _cameraActive = false;
  bool _started = false;
  bool _navigating = false;
  bool _processingFrame = false;
  Uint8List? _selfieBytesCaptured; // ถ่ายภาพระหว่างทำท่าสุดท้าย (มองตรง)

  static const double _stepSecondsRequired = 1.0;
  static const double _stepDecayFactor = 0.45;
  final List<PoseStep> _sequence = [];
  int _currentIndex = 0;
  double _stepHoldSeconds = 0;

  double _progress = 0.0;
  double _progressTarget = 0.0;

  String _hint = 'แตะปุ่มเพื่อเริ่มสแกน';

  Timer? _tick;
  DateTime? _lastFrameAt;

  double? _smoothYaw;
  double? _smoothPitch;
  static const double _ema = 0.2;

  static const double yawCenterMax = 12;
  static const double yawSideMin = 15;

  static const double eyeOpenMin = 0.4;
  static const double neutralEyeOpenMin = 0.6;

  static const double smileMin = 0.60;
  static const double neutralSmileMax = 0.20;

  static const double blinkEyeClosedMax = 0.30;

  int get _totalSteps => _sequence.length;

  PoseStep get _currentStep =>
      _sequence.isEmpty ? PoseStep.center : _sequence[_currentIndex];

  static const int _minProcessIntervalMs = 70;
  DateTime? _lastProcessAt;
  double? _lastFrameMs;
  double? _lastProcessMs;

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

  void _buildRandomSequence() {
    final pool = <PoseStep>[
      PoseStep.smile,
      PoseStep.blink,
      PoseStep.lookLeft,
      PoseStep.lookRight,
    ]..shuffle(math.Random());

    final actions = pool.take(4).toList();

    _sequence
      ..clear()
      ..add(PoseStep.center)
      ..addAll(actions)
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
      case PoseStep.smile:
        return 'ยิ้มให้กล้องหน่อย 😄';
      case PoseStep.blink:
        return 'ลองหลับตาหนึ่งที (กระพริบตา)';
      case PoseStep.lookRight:
        return 'หันหน้าไปทางซ้ายเล็กน้อย';
      case PoseStep.lookLeft:
        return 'หันหน้าไปทางขวาเล็กน้อย';
    }
  }

  Future<void> _startScan() async {
    if (_started) return;

    setState(() {
      _started = true;
      _hint = 'กำลังเปิดกล้อง...';
    });

    try {
      await _detector?.close();
    } catch (_) {}
    _detector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        performanceMode: FaceDetectorMode.fast,
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
        ResolutionPreset.medium,
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

      final rawYaw = f.headEulerAngleY ?? 0.0;
      final rawPitch = f.headEulerAngleX ?? 0.0;
      final isFront =
          _cam!.description.lensDirection == CameraLensDirection.front;
      final yaw = isFront ? -rawYaw : rawYaw;
      final pitch = rawPitch;

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

        // ตรวจตาเปิดสำหรับบางเงื่อนไข (ใช้แบบ inline ในแต่ละท่า)

      if (_sequence.isEmpty) {
        _buildRandomSequence();
      }

      bool correct = false;
      String hint = _hint;
      bool instantComplete = false;

      switch (_currentStep) {
        case PoseStep.center:
          {
            final nearCenter = y.abs() <= yawCenterMax;
            final neutralEyes =
                (leftEye == null || leftEye >= neutralEyeOpenMin) &&
                (rightEye == null || rightEye >= neutralEyeOpenMin);
            final neutralSmile = smileProb <= neutralSmileMax;

            correct = nearCenter && neutralEyes && neutralSmile;
            hint = correct ? 'ดีมาก… ค้างมองตรงไว้' : 'หันหน้ามองตรงกลางจอ';

            // ✅ ถ่ายภาพระหว่างทำท่าสุดท้ายที่เป็นมองตรง
            final isFinalCenter =
                _totalSteps > 0 &&
                _currentIndex == _totalSteps - 1 &&
                _currentStep == PoseStep.center;
            if (isFinalCenter && correct && _selfieBytesCaptured == null) {
              try {
                // หยุด stream ชั่วคราวเพื่อตั้งกล้องถ่ายภาพ
                if (_cam != null &&
                    _cam!.value.isInitialized &&
                    _cam!.value.isStreamingImages) {
                  await _cam!.stopImageStream();
                  await Future.delayed(const Duration(milliseconds: 80));
                }

                final x = await _cam!.takePicture();
                final file = File(x.path);
                _selfieBytesCaptured = await file.readAsBytes();
                // กลับมาเปิด stream เพื่อตรวจจับต่อให้จบลำดับท่า
                await _cam!.startImageStream(_onFrame);
              } catch (e, s) {
                debugPrint('❌ capture during final center failed: $e\n$s');
              }
            }
            break;
          }
        case PoseStep.smile:
          {
            final nearCenter = y.abs() <= yawCenterMax;
            final smiling = smileProb >= smileMin;
            final eyesOk =
                (leftEye == null || leftEye >= eyeOpenMin) &&
                (rightEye == null || rightEye >= eyeOpenMin);

            correct = nearCenter && smiling && eyesOk;
            // ✅ ยิ้มครั้งเดียวให้ผ่านทันที ไม่ต้องค้าง
            instantComplete = correct;
            hint = correct
                ? 'เยี่ยม! ยิ้มผ่านแล้ว'
                : 'หันหน้าตรงแล้วลองยิ้มให้กล้อง 😄';
            break;
          }
        case PoseStep.blink:
          {
            final nearCenter = y.abs() <= yawCenterMax;
            final eyeClosed =
                (leftEye != null && leftEye <= blinkEyeClosedMax) ||
                (rightEye != null && rightEye <= blinkEyeClosedMax);

            correct = nearCenter && eyeClosed;
            instantComplete = correct;
            hint = correct
                ? 'ดีมาก… ค้างหลับตาไว้สักครู่'
                : 'หันหน้าตรงแล้วลองหลับตาหนึ่งที';
            break;
          }
        case PoseStep.lookRight:
          {
            final eyesOk =
                (leftEye == null || leftEye >= eyeOpenMin) &&
                (rightEye == null || rightEye >= eyeOpenMin);

            // แก้ mapping: หันขวาจริง ๆ (จากที่ลองแล้ว yaw เป็นค่าลบ)
            correct = eyesOk && y <= -yawSideMin;
            hint = correct ? 'ดีมาก… ค้างไว้' : 'หันหน้าไปทางซ้ายเล็กน้อย';
            break;
          }

        case PoseStep.lookLeft:
          {
            final eyesOk =
                (leftEye == null || leftEye >= eyeOpenMin) &&
                (rightEye == null || rightEye >= eyeOpenMin);

            // หันซ้ายจริง ๆ = yaw เป็นค่าบวก
            correct = eyesOk && y >= yawSideMin;
            hint = correct ? 'ดีมาก… ค้างไว้' : 'หันหน้าไปทางขวาเล็กน้อย';
            break;
          }
      }

      if (_currentStep == PoseStep.blink || _currentStep == PoseStep.smile) {
        // ✅ ท่ากระพริบตาและท่ายิ้ม: ถ้าตรงเงื่อนไขครั้งเดียว ให้ผ่านทันที
        if (instantComplete) {
          _stepHoldSeconds = _stepSecondsRequired;
        } else {
          _stepHoldSeconds = 0;
        }
      } else {
        // ท่าอื่นให้ลด progress ลงช้า ๆ แทนการรีทันที
        if (correct) {
          _stepHoldSeconds += dt.clamp(0.0, 0.25);
        } else {
          _stepHoldSeconds = (_stepHoldSeconds -
                  (dt.clamp(0.0, 0.25) * _stepDecayFactor))
              .clamp(0.0, _stepSecondsRequired);
        }
      }

      final stepRatio = (_stepHoldSeconds / _stepSecondsRequired).clamp(
        0.0,
        1.0,
      );

      final total = _totalSteps == 0
          ? 0.0
          : (_currentIndex + stepRatio) / _totalSteps.toDouble();

      _progressTarget = total.clamp(0.0, 1.0);

      if (_stepHoldSeconds >= _stepSecondsRequired && !_navigating) {
        if (_currentIndex < _totalSteps - 1) {
          _currentIndex++;
          _stepHoldSeconds = 0;
          hint = _hintForStep(_currentStep);
        } else {
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
                'STEP=$_currentStep idx=$_currentIndex/${_totalSteps - 1} '
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

    final faceArgs =
        ModalRoute.of(context)?.settings.arguments as FaceScanArgs?;

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
    const int loadingSettleMs = 250;
    final DateTime loadingStartedAt = DateTime.now();

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
      // ใช้ภาพที่ถ่ายระหว่างท่าสุดท้าย ถ้ามี; ไม่เช่นนั้นถ่ายตอนนี้
      final selfieBytes = _selfieBytesCaptured ?? await _captureSelfieBytes();
      debugPrint('[KYC] selfieBytes is null? ${selfieBytes == null}');

      await _teardownCamera();

      if (!mounted) return;

      final Uint8List? idCardFaceBytes = faceArgs?.cardFaceBytes;
      // final userState = ref.read(userStoreProvider); // ไม่ได้ใช้
      // final user = userState['user'] as User?; // ไม่ได้ใช้
      // final cardFaceBytes = userState['cardFaceBytes'] as String?; // ไม่ได้ใช้
      debugPrint('[KYC] idCardFaceBytes is null? ${idCardFaceBytes == null}');

      String? idFaceBase64 = (idCardFaceBytes != null)
          ? base64Encode(idCardFaceBytes)
          : null;

      String? selfieBytes64 = (selfieBytes != null)
          ? base64Encode(selfieBytes)
          : null;

      final kyc = KycRemoteService(ref);
      const bool livenessPass = true;

      if (livenessPass && selfieBytes64 != null && idFaceBase64 != null) {
        final vr = await kyc.verifyFaceBytesVsIdFaceBase64(
          selfieBytes: selfieBytes64,
          idFaceBase64: idFaceBase64,
        );

        raw = vr;

        final bool apiMatched = vr['matched'] ?? false;
        final double apiScore = (vr['score'] as num?)?.toDouble() ?? 0.0;
        // final double apiThreshold =
        //     (vr['threshold'] as num?)?.toDouble() ?? 0.0; // ไม่ได้ใช้

        matched = apiMatched;
        score = apiScore;

        debugPrint(
          '[KYC] RESULT from BE: match=$matched, score=$score, raw=$vr',
        );
      } else {
        debugPrint('[KYC] SKIP verify (missing selfieBytes or idFaceBase64)');
      }

      final elapsedMs = DateTime.now()
          .difference(loadingStartedAt)
          .inMilliseconds;
      if (elapsedMs < loadingMs) {
        await Future.delayed(Duration(milliseconds: loadingMs - elapsedMs));
      }
      await Future.delayed(const Duration(milliseconds: loadingSettleMs));

      if (!mounted) return;

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      final resultArgs = {
        'matched': matched,
        'score': score,
        'raw': raw,
        // Preserve original face args for retry
        'cardFaceBytes': faceArgs?.cardFaceBytes,
        'fullName': faceArgs?.fullName,
        'dob': faceArgs?.dob,
        'gender': faceArgs?.gender,
      };

      if (matched) {
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
      await Future.delayed(const Duration(milliseconds: loadingSettleMs));

      if (!mounted) return;

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      final resultArgs = {
        'matched': false,
        'score': 0.0,
        'raw': {'error': e.toString()},
        // Preserve original face args for retry on error
        'cardFaceBytes': faceArgs?.cardFaceBytes,
        'fullName': faceArgs?.fullName,
        'dob': faceArgs?.dob,
        'gender': faceArgs?.gender,
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

  InputImage _toInputImage(CameraImage image, int rotation) {
    final rotationEnum =
        InputImageRotationValue.fromRawValue(rotation) ??
        InputImageRotation.rotation0deg;

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

  Uint8List _yuv420ToNv21(CameraImage image) {
    final int width = image.width;
    final int height = image.height;

    final int ySize = width * height;
    final int uvSize = width * height ~/ 2;

    final Uint8List nv21 = Uint8List(ySize + uvSize);

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

    final Plane uPlane = image.planes[1];
    final Plane vPlane = image.planes[2];

    final int uvRowStride = uPlane.bytesPerRow;
    final int uvPixelStride = uPlane.bytesPerPixel ?? 1;

    for (int y = 0; y < height ~/ 2; y++) {
      for (int x = 0; x < width ~/ 2; x++) {
        final int uvIndex = y * uvRowStride + x * uvPixelStride;

        nv21[dstIndex++] = vPlane.bytes[uvIndex];
        nv21[dstIndex++] = uPlane.bytes[uvIndex];
      }
    }

    return nv21;
  }

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

    // final isFront =
    //     _cam!.description.lensDirection == CameraLensDirection.front; // ไม่ได้ใช้ใน UI

    return Center(
      child: Transform.scale(
        scale: previewRatio / deviceRatio,
        child: AspectRatio(
          aspectRatio: previewRatio,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity(),
            child: CameraPreview(_cam!),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const ringSize = 260.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(child: _buildFullScreenPreview()),
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _FaceScanMaskPainter(holeDiameter: 236),
              ),
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                    width: ringSize,
                    height: ringSize,
                    child: CustomPaint(
                      painter: _FaceScanRingPainter(
                        progress: _progress,
                        tickCount: 72,
                      ),
                    ),
                  ),
                ),
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
                if (!_started)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 24,
                    child: Center(
                      child: DsButton(
                        width: 231,
                        size: DsButtonSize.md,
                        variant: DsButtonVariant.primary,
                        label: 'เริ่มสแกน',
                        onPressed: _startScan,
                      ),
                    ),
                  ),
                if (_started)
                  Positioned(
                    top: 88,
                    left: 24,
                    right: 24,
                    child: Text(
                      _hint,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: TextColors.secondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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
        ],
      ),
    );
  }
}

class _FaceScanRingPainter extends CustomPainter {
  final double progress;
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

class _FaceScanMaskPainter extends CustomPainter {
  final double holeDiameter;

  const _FaceScanMaskPainter({required this.holeDiameter});

  @override
  void paint(Canvas canvas, Size size) {
    final layerRect = Offset.zero & size;
    canvas.saveLayer(layerRect, Paint());

    canvas.drawRect(
      layerRect,
      Paint()..color = Colors.white,
    );

    canvas.drawCircle(
      size.center(Offset.zero),
      holeDiameter / 2,
      Paint()..blendMode = BlendMode.clear,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FaceScanMaskPainter oldDelegate) =>
      oldDelegate.holeDiameter != holeDiameter;
}
