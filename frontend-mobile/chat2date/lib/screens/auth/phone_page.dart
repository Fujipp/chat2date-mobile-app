import 'dart:async';

import 'package:chat2date/components/buttons/index.dart'; // DsButton / enums
import 'package:chat2date/components/toasts/toast.dart';
import 'package:chat2date/services/backend_otp_service.dart';
import 'package:chat2date/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    // ถ้าไม่ขึ้นต้นด้วย 0 ให้เติม 0 ให้อัตโนมัติ
    if (!p.startsWith('0')) {
      p = '0$p';
    }

    return p;
  }

  bool _isValidThaiMobile(String p) {
    // ถ้าขึ้นต้นด้วย 0 → ต้องยาว 10 ตัว เช่น 08xxxxxxxx
    return RegExp(r'^(06|08|09)\d{8}$').hasMatch(p);
  }

  Future<void> _submit(bool onLogin) async {
    if (_loading) return;
    FocusScope.of(context).unfocus();

    final phone = _normalizePhone(_phoneCtrl.text);
    if (!_isValidThaiMobile(phone)) {
      Toast.show(
        context,
        type: ToastType.warning,
        title: 'ข้อมูลไม่ครบ',
        message: 'กรุณากรอกเบอร์มือถือให้ถูกต้อง (เช่น 06/08/09 + xxxxxxxx )',
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // STEP 1 — ตรวจสอบว่าเบอร์มีอยู่หรือไม่
      final isExist = await UserService.checkPhone(phone);

      if (onLogin && !isExist && mounted) {
        Toast.show(
          context,
          type: ToastType.warning,
          title: 'ไม่ถูกต้อง',
          message: 'ไม่สามารถเข้าสู่ระบบได้ เนื่องจากไม่มีเบอร์นี้ในระบบ',
        );
        return;
      }
      if (!onLogin && isExist && mounted) {
        Toast.show(
          context,
          type: ToastType.warning,
          title: 'ไม่ถูกต้อง',
          message:
              'ไม่สามารถลงทะเบียนเบอร์นี้ได้ เนื่องจากมีเบอร์นี้ในระบบแล้ว',
        );
        return;
      }

      // STEP 2 — ส่ง OTP
      final token = await BackendOtpService.sendOtp(phone, context);

      if (!mounted) return;
      Navigator.pushNamed(
        context,
        '/otp',
        arguments: {'token': token, 'phone': phone, 'onLogin': onLogin},
      );
    } catch (e) {
      if (!mounted) return;

      if (e.toString().contains('ACCOUNT_DELETED')) {
        return;
      }
      Toast.show(
        context,
        type: ToastType.error,
        title: 'เกิดปัญหาขัดข้อง',
        message: 'ส่ง OTP ไม่สำเร็จ: ${e.toString()}',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    final bool loginOtp = arguments is bool ? arguments : false;
    // แตะพื้นหลังเพื่อซ่อนคีย์บอร์ด
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
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
                  onPressed: () => {
                    if (loginOtp)
                      {Navigator.pushReplacementNamed(context, '/home')}
                    else
                      {Navigator.pushReplacementNamed(context, '/policy')},
                  },
                  icon: SvgPicture.asset(
                    'assets/icons/icon_arrow-back-circle.svg',
                    width: 32,
                    height: 32,
                  ),
                ),
                const SizedBox(height: 8),

                // หัวข้อ
                Text(
                  loginOtp ? 'เข้าสู่ระบบ' : 'ลงทะเบียน',
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

                // ช่องกรอกเบอร์
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
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      const SizedBox(width: 4),
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
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(loginOtp),
                          keyboardType: TextInputType.phone,
                          textAlignVertical: TextAlignVertical.center,
                          autofillHints: const [AutofillHints.telephoneNumber],
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9+\-\s]'),
                            ),
                          ],
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: '08xxxxxxxx',
                            suffixIcon: (_phoneCtrl.text.isNotEmpty)
                                ? IconButton(
                                    splashRadius: 18,
                                    iconSize: 18,
                                    onPressed: () {
                                      _phoneCtrl.clear();
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.close_rounded),
                                  )
                                : null,
                          ),
                          onChanged: (_) => setState(() {}),
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
                      onPressed:
                          (!_loading &&
                              _isValidThaiMobile(
                                _normalizePhone(_phoneCtrl.text),
                              ))
                          ? () => _submit(loginOtp)
                          : null,
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
