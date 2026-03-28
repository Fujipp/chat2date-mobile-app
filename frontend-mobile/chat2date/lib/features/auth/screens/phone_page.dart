import 'dart:async';

import 'package:chat2date/components/design_system/index.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:chat2date/services/backend_otp_service.dart';
import 'package:chat2date/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    if (!p.startsWith('0')) p = '0$p';
    return p;
  }

  bool _isValidThaiMobile(String p) {
    return RegExp(r'^(06|08|09)\d{8}$').hasMatch(p);
  }

  String _cleanError(dynamic e) {
    return e.toString().replaceAll(RegExp(r'^Exception:\s*'), '');
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
        message: 'กรุณากรอกเบอร์มือถือให้ถูกต้อง (เช่น 06/08/09 + xxxxxxxx)',
      );
      return;
    }

    setState(() => _loading = true);

    try {
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
          message: 'ไม่สามารถลงทะเบียนเบอร์นี้ได้ เนื่องจากมีเบอร์นี้ในระบบแล้ว',
        );
        return;
      }

      final response = await BackendOtpService.sendOtp(phone, context);

      if (response != "") {
        if (!mounted) return;
        Toast.dismissCurrent();
        Navigator.pushNamed(
          context,
          '/otp',
          arguments: {'phone': phone, 'onLogin': onLogin},
        );
      }
    } catch (e) {
      if (!mounted) return;
      if (e.toString().contains('ACCOUNT_DELETED')) return;

      Toast.show(
        context,
        type: ToastType.error,
        title: 'เกิดปัญหาขัดข้อง',
        message: 'ส่ง OTP ไม่สำเร็จ: ${_cleanError(e)}',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    final bool loginOtp = arguments is bool ? arguments : false;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Center(
            child: Column(
              children: [
                // ─── Header ─────────────────────────────
                DsAppSecondaryHeader(
                  variant: DsAppSecondaryHeaderVariant.baseText,
                  title: loginOtp ? 'เข้าสู่ระบบ' : 'ลงทะเบียน',
                  onBackTap: () {
                    if (loginOtp) {
                      Navigator.pushReplacementNamed(context, '/login');
                    } else {
                      Navigator.pushReplacementNamed(context, '/policy');
                    }
                  },
                ),

                const SizedBox(height: 50),

                // ─── Phone Input ────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: DsTextField(
                    label: 'เบอร์โทรศัพท์',
                    hintText: '+66',
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    onChanged: (v) {
                      if (v.length > 10) {
                        _phoneCtrl.text = v.substring(0, 10);
                        _phoneCtrl.selection = TextSelection.fromPosition(
                          const TextPosition(offset: 10),
                        );
                      }
                      setState(() {});
                    },
                  ),
                ),

                const SizedBox(height: 50),

                // ─── Button ─────────────────────────────
                SizedBox(
                  width: 231,
                  child: DsButton(
                    label: _loading ? 'กำลังส่ง...' : 'ยืนยัน',
                    size: DsButtonSize.md,
                    variant: DsButtonVariant.outlinePrimary,
                    onPressed: (!_loading &&
                            _isValidThaiMobile(
                              _normalizePhone(_phoneCtrl.text),
                            ))
                        ? () => _submit(loginOtp)
                        : null,
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
