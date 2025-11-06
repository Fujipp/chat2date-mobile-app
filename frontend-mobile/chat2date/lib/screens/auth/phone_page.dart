import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chat2date/components/buttons/index.dart'; // DsButton / enums
import 'package:chat2date/services/backend_otp_service.dart';

class PhonePage extends StatefulWidget {
  const PhonePage({super.key});

  @override
  State<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends State<PhonePage> {
  final _phoneCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  String _normalizePhone(String raw) {
    var p = raw.replaceAll(RegExp(r'\D'), '');
    if (p.startsWith('66') && p.length >= 11) p = '0${p.substring(2)}';
    return p;
  }

  bool _isValidThaiMobile(String p) {
    return RegExp(r'^(06|08|09)\d{8}$').hasMatch(p);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final phone = _normalizePhone(_phoneCtrl.text);
    if (!_isValidThaiMobile(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอกเบอร์มือถือให้ถูกต้อง (เช่น 08xxxxxxxx)'),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final token = await BackendOtpService.sendOtp(phone);
      if (!mounted) return;
      Navigator.pushNamed(
        context,
        '/otp',
        arguments: {'token': token, 'phone': phone},
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ส่ง OTP ไม่สำเร็จ: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // แตะพื้นหลังเพื่อซ่อนคีย์บอร์ด
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        // ปล่อยให้เลย์เอาต์ขยับตามคีย์บอร์ด (ค่า default = true)
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            // ดันเนื้อหาให้พ้นคีย์บอร์ด
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ปุ่มย้อนกลับ (ไปหน้า /policy)
                IconButton(
                  splashRadius: 26,
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/policy'),
                  icon: SvgPicture.asset(
                    'assets/icons/icon_arrow-back-circle.svg',
                    width: 32,
                    height: 32,
                  ),
                ),

                const SizedBox(height: 8),

                // หัวข้อ
                const Text(
                  'ลงทะเบียน',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 24),

                // Label
                const Text(
                  'เบอร์โทรศัพท์',
                  style: TextStyle(
                    color: Color(0xFF2E3036),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),

                // ช่องกรอกเบอร์ (เรียบ ๆ ไม่มีกรอบนอกหน้า)
                Container(
                  height: 48,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1,
                        color: Color(0xFFE2E8F0),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      const Text(
                        '+66',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9+\-\s]'),
                            ),
                          ],
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: '08xxxxxxxx',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ปุ่มถัดไป
                Center(
                  child: SizedBox(
                    width: 231,
                    height: 40,
                    child: DsButton(
                      label: _loading ? 'กำลังส่ง...' : 'ถัดไป',
                      size: DsButtonSize.md,
                      variant: DsButtonVariant.primary,
                      onPressed: _loading ? null : _submit,
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
