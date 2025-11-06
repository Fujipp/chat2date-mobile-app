import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:chat2date/components/index.dart'; // DsButton / inputs
import 'package:chat2date/services/ocr_thaiid_service.dart';
import 'package:chat2date/services/kyc_api.dart';

class IdOcrScreen extends StatefulWidget {
  const IdOcrScreen({super.key});

  @override
  State<IdOcrScreen> createState() => _IdOcrScreenState();
}

class _IdOcrScreenState extends State<IdOcrScreen> {
  // === CONFIG (ใส่ค่าจริงก่อนใช้งาน) ===
  final _ocrCfg = const ThaiIdOcrConfig(
    endpoint: 'https://api.iapp.co.th/thai-national-id-card/v3.5/front',
    apiKey: 'Z0XVt18RSoFlZAkRnhGy9U3u5J8MlrZA', // <- ใส่ key จริง (อย่า commit)
  );
  final _api = const KycApi('http://127.0.0.1:8080');

  static const _backIcon = 'assets/icons/icon_arrow-back-circle.svg';
  static const _maxFileBytes = 10 * 1024 * 1024; // 10MB

  File? _image;
  bool _busy = false;

  // ค่าที่จะโชว์ (disable fields)
  String? _fullName;
  DateTime? _dob;
  String? _gender;

  // รูปแบบวันที่ไทย
  final _fmt = DateFormat('dd/MM/yyyy');

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

    // ขอ permission ตามแหล่งที่เลือก
    if (src == ImageSource.camera) {
      final cam = await Permission.camera.request();
      if (!cam.isGranted) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ไม่ได้รับสิทธิ์กล้อง')));
        return;
      }
    } else {
      // คลังรูป (iOS/Android 13+)
      final ph = await Permission.photos.request();
      if (!ph.isGranted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่ได้รับสิทธิ์เข้าถึงรูปภาพ')),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ไฟล์ใหญ่เกิน 10MB')));
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
      final result = await ThaiIdOcrService.ocr(
        cfg: _ocrCfg,
        imageFile: _image!,
      );
      setState(() {
        _fullName = result.fullName;
        _dob = result.birthDate;
        _gender = result.gender; // ชาย/หญิง/อื่นๆ
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('สแกนสำเร็จ เติมข้อมูลอัตโนมัติแล้ว')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('OCR ล้มเหลว: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submit() async {
    if (_fullName == null || _dob == null || _gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาแนบ/ถ่ายรูปบัตรและสแกนก่อน')),
      );
      return;
    }
    final age = _calcAgeForDisplay(_dob!);

    setState(() => _busy = true);
    try {
      await _api.submitIdentity(
        fullName: _fullName!,
        birthDate: _dob!,
        age: age,
        gender: _gender!,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('บันทึกข้อมูลสำเร็จ')));
      Navigator.pushNamed(context, '/next');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ส่งข้อมูลไม่สำเร็จ: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  int _calcAgeForDisplay(DateTime dob) {
    final now = DateTime.now();
    // ถ้าวันเกิด "อนาคต" ให้ลองแปลงจากปี พ.ศ. -> ค.ศ.
    DateTime d = dob;
    if (d.isAfter(now)) {
      d = DateTime(d.year - 543, d.month, d.day);
    }
    var age = now.year - d.year;
    if (DateTime(now.year, d.month, d.day).isAfter(now)) age--;
    return age.clamp(0, 120);
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = const Color(0x599CABC2);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AspectRatio(
          aspectRatio: 375 / 812,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 2),
                borderRadius: BorderRadius.circular(50),
              ),
            ),

            // ---------- เปลี่ยนจาก Stack/Positioned เป็น Column + Scroll ----------
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ปุ่มกลับมุมซ้ายบน
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

                // เนื้อหาเลื่อนสกอร์ลได้ (เรียง: กรอบรูป -> ฟิลด์ -> ปุ่ม)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: SizedBox(
                            width: 322,
                            height: 220,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: Material(
                                // ใส่ไว้ให้ InkWell มี ripple (optional)
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
                                          Image.file(_image!, fit: BoxFit.cover)
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

                        // ===== ปุ่มยืนยัน (ต่อท้ายฟิลด์เลย) =====
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
                            child: CircularProgressIndicator(strokeWidth: 2.6),
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
