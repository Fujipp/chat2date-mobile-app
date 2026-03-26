// lib/screens/auth/id_ocr_screen.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
 
import 'package:chat2date/components/index.dart'; // DsButton / inputs
import 'package:chat2date/models/face_scan_args.dart'; // ใช้ส่ง args ไปหน้า face-scan
import 'package:chat2date/models/user.dart';
import 'package:chat2date/services/ocr_thaiid_service.dart';
import 'package:chat2date/services/user_service.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:chat2date/components/toasts/toast.dart';

 
class IdOcrScreen extends ConsumerStatefulWidget {
  const IdOcrScreen({super.key});
 
  @override
  ConsumerState<IdOcrScreen> createState() => _IdOcrScreenState();
}
 
class _IdOcrScreenState extends ConsumerState<IdOcrScreen> {
  // === CONFIG ===
  late final ThaiIdOcrConfig _ocrCfg;
 
  static const _backIcon = 'assets/icons/ui/icon_arrow-back-circle.svg';
  static const _maxFileBytes = 10 * 1024 * 1024; // 10MB
 
  File? _image;
  Uint8List? _cardFace;
  bool _busy = false;
 
  String? _fullName;
  DateTime? _dob;
  String? _gender;
 
  String? _thFirstName;
  String? _thLastName;
 
  ThaiIdOcrResult? _ocrResult;
 
  final _fmt = DateFormat('dd/MM/yyyy');

  // ใช้ Toast.show จาก components/toasts/toast.dart โดยตรง
 
  @override
  void initState() {
    super.initState();
 
    _ocrCfg = ThaiIdOcrConfig(
      endpoint:
          dotenv.env['THAIID_ENDPOINT_FRONT'] ??
          'https://api.iapp.co.th/v3/store/ekyc/thai-national-id-card/front',
      apiKey: dotenv.env['THAIID_API_KEY'] ?? '',
    );
  }
 
  /// เปิด BottomSheet เลือกแหล่งรูป แล้วเรียก _pick(...)
  Future<void> _chooseSource() async {
    FocusScope.of(context).unfocus();
    final src = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('เลือกจากคลังรูป'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_rounded),
                title: const Text('ถ่ายภาพตอนนี้'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
 
    if (src == null) return;
 
    if (src == ImageSource.gallery) {
      // Android 13+ (API 33)
      var ph = await Permission.photos.request();
      if (!ph.isGranted) {
        // Android 12 -
        ph = await Permission.storage.request();
      }
 
      if (!ph.isGranted) {
        if (!mounted) return;
        Toast.show(
          context,
          type: ToastType.error,
          title: 'ไม่ได้รับสิทธิ์',
          message: 'กรุณาอนุญาตการเข้าถึงคลังรูปหรือกล้องในระบบ',
        );
        return;
      }
    }
 
    await _pick(src);
  }
 
  Future<void> _pick(ImageSource src) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: src,
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
 
    setState(() => _image = f);
 
    // เรียก OCR ต่อเลย
    await _runOcr();
  }
 
  Future<void> _runOcr() async {
    if (_image == null) return;
 
    setState(() => _busy = true);
 
    try {
      // เรียก iApp OCR ตรง ๆ ไม่ต้องใช้ accessToken
      final result = await ThaiIdOcrService.ocr(
        cfg: _ocrCfg,
        imageFile: _image!,
      );
 
      // ถ้า OCR ไม่คืนรูปใบหน้ามา ให้ fallback เป็น bytes ของรูปทั้งใบ
      final fallbackBytes = await _image!.readAsBytes();
      final faceBytes = result.cardFaceBytes ?? fallbackBytes;
      final base64Card = base64Encode(faceBytes);
 
      // เก็บ base64 ของรูปหน้าไว้ใน userStore (ใช้ที่อื่นต่อได้)
      ref.read(userStoreProvider.notifier).setCardFaceBytes(base64Card);
 
      setState(() {
        _ocrResult = result;
        _fullName = result.fullName;
        _dob = result.birthDate;
        _gender = result.gender;
        _cardFace = faceBytes;
 
        _thFirstName = result.thFname;
        _thLastName = result.thLname;
      });
 
      // if (!mounted) return;
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('สแกนสำเร็จ เติมข้อมูลอัตโนมัติแล้ว')),
      // );
    } catch (e) {
      if (!mounted) return;
      Toast.show(
        context,
        type: ToastType.error,
        title: 'สแกนบัตรไม่สำเร็จ',
        message:
            'กรุณาลองใหม่อีกครั้ง โดยถ่ายให้เห็นบัตรชัดเจน ไม่สะท้อนแสง และอยู่ในกรอบ',
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
        message: 'กรุณาแนบหรือถ่ายรูปบัตร แล้วสแกนก่อนดำเนินการต่อ',
      );
      return;
    }

    // 🔐 เช็คอายุก่อน
  if (_dob == null) {
    Toast.show(
      context,
      type: ToastType.error,
      title: 'ไม่พบวันเกิด',
      message: 'กรุณาสแกนบัตรให้สำเร็จ เพื่อดึงข้อมูลวันเกิดก่อนดำเนินการต่อ',
    );
    return;
  }

  final age = _calcAgeForDisplay(_dob!);
  if (age < 18) {
    Toast.show(
      context,
      type: ToastType.error,
      title: 'อายุไม่ถึงเกณฑ์',
      message: 'ต้องมีอายุอย่างน้อย 18 ปีจึงจะสามารถใช้งานส่วนนี้ได้',
    );
    return; // ❌ ไปต่อไม่ได้
  }
 
    setState(() => _busy = true);
 
    try {
      // 1. อ่านจาก userStore ก่อน
      final userStoreNotifier = ref.read(userStoreProvider.notifier);
      User? currentUser = userStoreNotifier.user;
      String? accessToken = userStoreNotifier.accessToken;
 
      print('📦 Current User from Store: ${currentUser?.toJson()}');
      print('🔑 Access Token: $accessToken');
 
      // 2. ถ้าไม่มีใน store ให้ลองดึงจาก storage (กรณีเปิดแอพใหม่)
      if (currentUser == null || accessToken == null) {
        final storage = const FlutterSecureStorage();
        final userId = await storage.read(key: 'userId');
        accessToken = await storage.read(key: 'accessToken');
 
        print('💾 UserId from Storage: $userId');
        print('💾 Token from Storage: $accessToken');
 
        if (userId == null || accessToken == null) {
          throw Exception('กรุณาเข้าสู่ระบบใหม่');
        }
 
        // ดึงข้อมูล User ล่าสุดจาก API
        final userService = ref.read(userServiceProvider);
        currentUser = await userService.getUser(userId);
 
        print('✅ Fetched User from API: ${currentUser!.toJson()}');
 
        // อัปเดตลง userStore
        userStoreNotifier.setUser(currentUser, accessToken);
      }
 
      // 3. แปลง gender
      final sex = (_ocrResult!.gender == 'ชาย')
          ? Sex.MALE
          : (_ocrResult!.gender == 'หญิง')
          ? Sex.FEMALE
          : null;
 
      // 4. สร้าง User object ใหม่ โดยรวมข้อมูลเดิม + ข้อมูลจาก OCR
      final userToUpdate = User(
        userId: currentUser.userId,
        version: currentUser.version ?? 0, // ใช้ version ล่าสุด
        firstname: _ocrResult!.thFname,
        lastname: _ocrResult!.thLname,
        birthday: _dob,
        sex: sex,
        cardId: _ocrResult!.cardId,
        nickname: currentUser.nickname, // เก็บ nickname เดิมไว้
      );
 
      print('📤 Updating user...');
      print('User to update: ${userToUpdate.toJson()}');
 
      // 5. เรียก API
      final userService = ref.read(userServiceProvider);
      final updatedUser = await userService.updateUser(userToUpdate);
 
      print('✅ User updated: ${updatedUser}');
 
      // 6. อัปเดต userStore และ SecureStorage
      final storage = const FlutterSecureStorage();
      await storage.write(key: 'userId', value: updatedUser.userId);
      await storage.write(
        key: 'version',
        value: updatedUser.version.toString(),
      );
      await storage.write(key: 'accessToken', value: accessToken);
 
      print('✅ Store and Storage updated');
 
      // 7. ส่งต่อรูปหน้าไปหน้า face-scan
      final faceBytes = _cardFace ?? await _image!.readAsBytes();
 
      if (!mounted) return;
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
    } catch (e, stackTrace) {
      print('❌ Submit Error: $e');
      print('Stack trace: $stackTrace');
 
      if (!mounted) return;
      Toast.show(
        context,
        type: ToastType.error,
        title: 'อัปเดตไม่สำเร็จ',
        message: 'เกิดข้อผิดพลาด: ${e.toString()}',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
 
  int _calcAgeForDisplay(DateTime dob) {
    final now = DateTime.now();
    DateTime d = dob;
    if (d.isAfter(now)) {
      d = DateTime(d.year - 543, d.month, d.day); // กันกรณีอินพุตเป็น พ.ศ.
    }
    var age = now.year - d.year;
    if (DateTime(now.year, d.month, d.day).isAfter(now)) age--;
    return age.clamp(0, 120);
  }
 
  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0x599CABC2);
 
    return Scaffold(
      backgroundColor: Colors.white,
      // เอากรอบมือถือออก: ใช้ SafeArea + Center + ConstrainedBox + Padding
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              // ---------- Column + Scroll (เรียง 3 คอมโพเนนต์ต่อกัน) ----------
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ปุ่มกลับไป /home มุมซ้ายบน
                  IconButton(
                    onPressed: _busy
                        ? null
                        : () => Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/home',
                            (route) => false,
                          ),
                    icon: SvgPicture.asset(
                      _backIcon,
                      width: 45,
                      height: 45,
                      fit: BoxFit.contain,
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
 
                  const SizedBox(height: 12),
 
                  // เนื้อหา: กรอบรูป -> ฟิลด์ -> ปุ่มยืนยัน
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ===== กรอบแสดงภาพ =====
                          Center(
                            child: SizedBox(
                              width: 322,
                              height: 220,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _busy ? null : _chooseSource,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 2,
                                          color: borderColor,
                                        ),
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(40),
                                      ),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          if (_image != null)
                                            Image.file(
                                              _image!,
                                              fit: BoxFit.cover,
                                            )
                                          else
                                            const Center(
                                              child: Text(
                                                'แตะเพื่อแนบรูป/ถ่ายบัตรประชาชน',
                                              ),
                                            ),
                                          const Positioned(
                                            bottom: 8,
                                            left: 0,
                                            right: 0,
                                            child: Opacity(
                                              opacity: 0.75,
                                              child: Text(
                                                'แตะเพื่อเลือก: คลังรูป หรือ กล้อง',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF64748B),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
 
                          const SizedBox(height: 24),
 
                          // ===== กลุ่มฟิลด์ (กว้าง 295) =====
                          SizedBox(
                            width: 295,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _DisabledField(
                                  label: 'ชื่อ-นามสกุล',
                                  value: _fullName ?? '',
                                ),
                                const SizedBox(height: 10),
                                _DisabledField(
                                  label: 'วันเกิด',
                                  value: _dob == null ? '' : _fmt.format(_dob!),
                                ),
                                const SizedBox(height: 10),
                                _DisabledField(
                                  label: 'อายุ',
                                  value: _dob == null
                                      ? ''
                                      : _calcAgeForDisplay(_dob!).toString(),
                                ),
                                const SizedBox(height: 10),
                                _DisabledField(
                                  label: 'เพศ',
                                  value: _gender ?? '',
                                ),
                              ],
                            ),
                          ),
 
                          const SizedBox(height: 24),
 
                          // ===== ปุ่มยืนยัน =====
                          SizedBox(
                            width: 231,
                            height: 40,
                            child: DsButton(
                              label: 'ยืนยันข้อมูล',
                              size: DsButtonSize.md,
                              onPressed: _busy ? null : _submit,
                            ),
                          ),
 
                          if (_busy) ...[
                            const SizedBox(height: 12),
                            const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.6,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
 
/// ช่องแสดงผลแบบ disable ตามดีไซน์
class _DisabledField extends StatelessWidget {
  final String label;
  final String value;
  const _DisabledField({required this.label, required this.value});
 
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 295,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF2E3036),
              fontSize: 20,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: ShapeDecoration(
              color: const Color(0xFFF2F4F7),
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1, color: Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              (value.isEmpty ? '-' : value),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 