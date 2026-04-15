import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:chat2date/components/design_system/index.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:chat2date/core/theme/tokens/colors/text_colors.dart';
import 'package:chat2date/models/face_scan_args.dart';
import 'package:chat2date/models/user.dart';
import 'package:chat2date/services/ocr_thaiid_service.dart';
import 'package:chat2date/services/user_service.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';


class IdOcrScreen extends ConsumerStatefulWidget {
  const IdOcrScreen({super.key});

  @override
  ConsumerState<IdOcrScreen> createState() => _IdOcrScreenState();
}

class _IdOcrScreenState extends ConsumerState<IdOcrScreen> {
  late final ThaiIdOcrConfig _ocrCfg;
  static const _maxFileBytes = 10 * 1024 * 1024;

  CameraController? _camCtrl;
  bool _cameraReady = false;

  File? _image;
  Uint8List? _cardFace;
  bool _busy = false;

  String? _fullName;
  DateTime? _dob;
  String? _gender;

  ThaiIdOcrResult? _ocrResult;

  final _fmt = DateFormat('dd/MM/yyyy');

  String _cleanError(dynamic e) {
    return e.toString().replaceAll(RegExp(r'^Exception:\s*'), '');
  }

  @override
  void initState() {
    super.initState();
    _ocrCfg = ThaiIdOcrConfig(
      endpoint:
          dotenv.env['THAIID_ENDPOINT_FRONT'] ??
          'https://api.iapp.co.th/v3/store/ekyc/thai-national-id-card/front',
      apiKey: dotenv.env['THAIID_API_KEY'] ?? '',
    );
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      var cameraPermission = await Permission.camera.status;
      if (!cameraPermission.isGranted) {
        cameraPermission = await Permission.camera.request();
      }
      if (!cameraPermission.isGranted) {
        if (mounted) {
          Toast.show(
            context,
            type: ToastType.warning,
            title: 'ไม่ได้รับสิทธิ์กล้อง',
            message: 'กรุณาอนุญาตการใช้กล้องในการตั้งค่า',
          );
        }
        return;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _camCtrl = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _camCtrl!.initialize();
      if (mounted) setState(() => _cameraReady = true);
    } catch (_) {
      // camera not available — user can still pick from gallery
    }
  }

  @override
  void dispose() {
    _camCtrl?.dispose();
    super.dispose();
  }

  Future<void> _captureFromCamera() async {
    if (_camCtrl == null || !_camCtrl!.value.isInitialized || _busy) return;

    try {
      final xFile = await _camCtrl!.takePicture();
      final f = File(xFile.path);
      setState(() {
        _image = f;
        _ocrResult = null;
        _fullName = null;
        _dob = null;
        _gender = null;
        _cardFace = null;
      });
      await _runOcr();
    } catch (e) {
      if (!mounted) return;
      Toast.show(
        context,
        type: ToastType.error,
        title: 'ถ่ายรูปไม่สำเร็จ',
        message: _cleanError(e),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    if (_busy) return;

    var ph = await Permission.photos.request();
    if (!ph.isGranted) ph = await Permission.storage.request();
    if (!ph.isGranted) {
      if (!mounted) return;
      Toast.show(
        context,
        type: ToastType.error,
        title: 'ไม่ได้รับสิทธิ์',
        message: 'กรุณาอนุญาตการเข้าถึงคลังรูปในการตั้งค่า',
      );
      return;
    }

    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 92,
      maxWidth: 2600,
    );
    if (x == null) return;

    final f = File(x.path);
    final size = await f.length();
    if (size > _maxFileBytes) {
      if (!mounted) return;
      Toast.show(
        context,
        type: ToastType.error,
        title: 'ไฟล์ใหญ่เกิน',
        message: 'ขนาดไฟล์ต้องไม่เกิน 10MB กรุณาเลือกรูปใหม่',
      );
      return;
    }

    setState(() {
      _image = f;
      _ocrResult = null;
      _fullName = null;
      _dob = null;
      _gender = null;
      _cardFace = null;
    });
    await _runOcr();
  }

  void _resetCapture() {
    setState(() {
      _image = null;
      _ocrResult = null;
      _fullName = null;
      _dob = null;
      _gender = null;
      _cardFace = null;
    });
  }

  Future<void> _runOcr() async {
    if (_image == null) return;
    setState(() => _busy = true);

    try {
      final result = await ThaiIdOcrService.ocr(
        cfg: _ocrCfg,
        imageFile: _image!,
      );

      final fallbackBytes = await _image!.readAsBytes();
      final faceBytes = result.cardFaceBytes ?? fallbackBytes;
      final base64Card = base64Encode(faceBytes);

      ref.read(userStoreProvider.notifier).setCardFaceBytes(base64Card);

      setState(() {
        _ocrResult = result;
        _fullName = result.fullName;
        _dob = result.birthDate;
        _gender = result.gender;
        _cardFace = faceBytes;
      });
    } catch (e) {
      if (!mounted) return;
      Toast.show(
        context,
        type: ToastType.error,
        title: 'สแกนบัตรไม่สำเร็จ',
        message: 'กรุณาลองใหม่อีกครั้ง โดยถ่ายให้เห็นบัตรชัดเจน ไม่สะท้อนแสง',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submit() async {
    if (_ocrResult == null || _image == null) {
      Toast.show(
        context,
        type: ToastType.warning,
        title: 'ยังไม่ได้สแกน',
        message: 'กรุณาถ่ายรูปบัตรหรือเลือกจากอัลบั้มก่อน',
      );
      return;
    }

    if (_dob == null) {
      Toast.show(
        context,
        type: ToastType.error,
        title: 'ไม่พบวันเกิด',
        message: 'กรุณาสแกนบัตรให้สำเร็จ เพื่อดึงข้อมูลวันเกิด',
      );
      return;
    }

    final age = _calcAge(_dob!);
    if (age < 18) {
      Toast.show(
        context,
        type: ToastType.error,
        title: 'อายุไม่ถึงเกณฑ์',
        message: 'ต้องมีอายุอย่างน้อย 18 ปีจึงจะสามารถใช้งานได้',
      );
      return;
    }

    setState(() => _busy = true);

    try {
      final userStoreNotifier = ref.read(userStoreProvider.notifier);
      User? currentUser = userStoreNotifier.user;
      String? accessToken = userStoreNotifier.accessToken;

      if (currentUser == null || accessToken == null) {
        final storage = const FlutterSecureStorage();
        final userId = await storage.read(key: 'userId');
        accessToken = await storage.read(key: 'accessToken');

        if (userId == null || accessToken == null) {
          throw Exception('กรุณาเข้าสู่ระบบใหม่');
        }

        final userService = ref.read(userServiceProvider);
        currentUser = await userService.getUser(userId);
        userStoreNotifier.setUser(currentUser!, accessToken);
      }

      final sex = (_ocrResult!.gender == 'ชาย')
          ? Sex.male
          : (_ocrResult!.gender == 'หญิง')
              ? Sex.female
              : null;

      final userToUpdate = User(
        userId: currentUser.userId,
        version: currentUser.version ?? 0,
        firstname: _ocrResult!.thFname,
        lastname: _ocrResult!.thLname,
        birthday: _dob,
        sex: sex,
        cardId: _ocrResult!.cardId,
        nickname: currentUser.nickname,
      );

      final userService = ref.read(userServiceProvider);
      final updatedUser = await userService.updateUser(userToUpdate);

      final storage = const FlutterSecureStorage();
      await storage.write(key: 'userId', value: updatedUser.userId);
      await storage.write(key: 'version', value: updatedUser.version.toString());
      await storage.write(key: 'accessToken', value: accessToken);

      final faceBytes = _cardFace ?? await _image!.readAsBytes();

      if (!mounted) return;
      Toast.dismissCurrent();
      Navigator.pushNamed(
        context,
        '/face-scan',
        arguments: FaceScanArgs(
          cardFaceBytes: faceBytes,
          fullName: _fullName!,
          dob: _dob!,
          gender: _gender!,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Toast.show(
        context,
        type: ToastType.error,
        title: 'อัปเดตไม่สำเร็จ',
        message: _cleanError(e),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  int _calcAge(DateTime dob) {
    final now = DateTime.now();
    DateTime d = dob;
    if (d.isAfter(now)) {
      d = DateTime(d.year - 543, d.month, d.day);
    }
    var age = now.year - d.year;
    if (DateTime(now.year, d.month, d.day).isAfter(now)) age--;
    return age.clamp(0, 120);
  }

  Widget _buildPreviewSurface() {
    if (_image != null) {
      return Image.file(_image!, fit: BoxFit.cover);
    }

    if (_cameraReady && _camCtrl != null && _camCtrl!.value.isInitialized) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final frameAspect = constraints.maxWidth / constraints.maxHeight;

          double previewAspect = _camCtrl!.value.aspectRatio;
          if (constraints.maxHeight > constraints.maxWidth) {
            previewAspect = 1 / previewAspect;
          }

          return ClipRect(
            child: Transform.scale(
              scale: previewAspect / frameAspect,
              alignment: Alignment.center,
              child: Center(
                child: AspectRatio(
                  aspectRatio: previewAspect,
                  child: AbsorbPointer(
                    absorbing: true,
                    child: CameraPreview(_camCtrl!),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    return Container(
      color: const Color(0xFFF2F4F7),
      child: const Center(
        child: Icon(
          Icons.camera_alt_rounded,
          size: 48,
          color: Color(0xFF8F9098),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canCapture = _image == null && _cameraReady && !_busy;
    final canConfirm = _ocrResult != null && !_busy;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              // ─── Header ─────────────────────────────
              DsAppSecondaryHeader(
                variant: DsAppSecondaryHeaderVariant.baseText,
                title: 'สแกนบัตรประชาชน',
                onBackTap: _busy
                    ? null
                    : () => Navigator.pushNamedAndRemoveUntil(
                          context, '/login', (route) => false),
              ),

             // ─── Camera Viewfinder (Improved Version) ──────────────────
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
  child: AspectRatio(
    aspectRatio: 1.586, // ID card ratio
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. กล้องหรือรูปที่ถ่ายแล้ว
          _buildPreviewSurface(),

          // 2. Custom Overlay (เจาะรูตรงกลาง)
          // ถ้าถ่ายรูปแล้ว (_image != null) อาจจะซ่อนหรือเปลี่ยนเป็นสีจางลงได้
          if (_image == null)
            Positioned.fill(
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.5), // ความมืดของรอบนอก
                  BlendMode.srcOut,
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        backgroundBlendMode: BlendMode.dstOut,
                      ),
                    ),
                    // ส่วนที่ "เจาะรู" ออก (ต้องมี margin หรือขนาดเล็กกว่า parent เล็กน้อย)
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        margin: const EdgeInsets.all(2), // ให้เห็นเส้นขอบ Border
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 3. Viewfinder border overlay (เส้นขอบ)
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  width: 3,
                  color: _image != null
                      ? AppColors.accept
                      : AppColors.brandPrimary.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),

          // 4. คำแนะนำกลางช่อง (ถ้ายังไม่ได้ถ่าย)
          if (_image == null && !_busy)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.credit_card_rounded, color: Colors.white54, size: 40),
                  SizedBox(height: 8),
                  Text(
                    "วางบัตรให้ตรงกรอบ",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),

          // 5. ปุ่ม Re-take
          if (_image != null && !_busy)
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: _resetCapture,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),

          // 6. Loading overlay
          if (_busy)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    ),
  ),
),

              // ─── Album button ───────────────────────
              GestureDetector(
                onTap: _busy ? null : _pickFromGallery,
                child: Text(
                  'เลือกจากอัลบั้ม',
                  style: TextStyle(
                    color: AppColors.brandPrimary,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ─── OCR Result Fields ──────────────────
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxHeight < 360;
                    final fieldGap = compact ? 6.0 : 10.0;
                    final bottomGap = compact ? 8.0 : 24.0;
                    final labelFontSize = compact ? 14.0 : null;
                    final inputFontSize = compact ? 14.0 : null;
                    final contentPadding = EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: compact ? 9 : 12,
                    );

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Column(
                        children: [
                          DsTextField(
                            label: 'ชื่อ-นามสกุล',
                            controller: TextEditingController(
                              text: _fullName ?? '',
                            ),
                            readOnly: true,
                            enabled: false,
                            labelFontSize: labelFontSize,
                            inputFontSize: inputFontSize,
                            contentPadding: contentPadding,
                            textColor: TextColors.secondary,
                          ),
                          SizedBox(height: fieldGap),
                          DsTextField(
                            label: 'วันเกิด',
                            controller: TextEditingController(
                              text: _dob == null ? '' : _fmt.format(_dob!),
                            ),
                            readOnly: true,
                            enabled: false,
                            labelFontSize: labelFontSize,
                            inputFontSize: inputFontSize,
                            contentPadding: contentPadding,
                            textColor: TextColors.secondary,
                          ),
                          SizedBox(height: fieldGap),
                          DsTextField(
                            label: 'อายุ',
                            controller: TextEditingController(
                              text: _dob == null
                                  ? ''
                                  : _calcAge(_dob!).toString(),
                            ),
                            readOnly: true,
                            enabled: false,
                            labelFontSize: labelFontSize,
                            inputFontSize: inputFontSize,
                            contentPadding: contentPadding,
                            textColor: TextColors.secondary,
                          ),
                          SizedBox(height: fieldGap),
                          DsTextField(
                            label: 'เพศ',
                            controller: TextEditingController(
                              text: _gender ?? '',
                            ),
                            readOnly: true,
                            enabled: false,
                            labelFontSize: labelFontSize,
                            inputFontSize: inputFontSize,
                            contentPadding: contentPadding,
                            textColor: TextColors.secondary,
                          ),
                          const Spacer(),
                          SizedBox(height: bottomGap),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // ─── Submit Button ──────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: SizedBox(
                  width: 231,
                  child: DsButton(
                    label: canConfirm ? 'ยืนยันข้อมูล' : 'ถ่ายรูป',
                    size: DsButtonSize.md,
                    variant: DsButtonVariant.outlinePrimary,
                    onPressed: canConfirm
                        ? _submit
                        : (canCapture ? _captureFromCamera : null),
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
