import 'dart:async';

import 'package:chat2date/components/design_system/index.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:chat2date/features/auth/controllers/auth_controller.dart';
import 'package:chat2date/models/user.dart';
import 'package:chat2date/services/backend_otp_service.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OtpPage extends ConsumerStatefulWidget {
  const OtpPage({super.key});
  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final int _length = 6;
  late final List<TextEditingController> _ctls;
  late final List<FocusNode> _nodes;

  String _phone = '';
  bool onLogin = false;
  int _seconds = 60;
  Timer? _timer;
  bool _verifying = false;
  bool _resending = false;

  bool get _canVerify => _code().length == _length;

  @override
  void initState() {
    super.initState();
    _ctls = List.generate(_length, (_) => TextEditingController());
    _nodes = List.generate(_length, (_) => FocusNode());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        _phone = (args['phone'] ?? '') as String;
        onLogin = (args['onLogin'] ?? '') as bool;
      }
      _startTimer();
      if (_nodes.isNotEmpty) _nodes.first.requestFocus();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _ctls) {
      c.dispose();
    }
    for (final f in _nodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _seconds = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() {
        _seconds--;
        if (_seconds <= 0) {
          _seconds = 0;
          t.cancel();
        }
      });
    });
  }

  String _code() => _ctls.map((c) => c.text).join();

  String _cleanError(dynamic e) {
    return e.toString().replaceAll(RegExp(r'^Exception:\s*'), '');
  }

  Future<void> _verify() async {
    final code = _code();
    if (code.length != _length) {
      if (!mounted) return;
      Toast.show(
        context,
        type: ToastType.warning,
        title: 'OTP ไม่ครบ',
        message: 'กรุณากรอก OTP ให้ครบ 6 หลัก',
      );
      return;
    }

    setState(() => _verifying = true);

    try {
      final data = await ref
          .read(backendOtpServiceProvider)
          .validateOtp(code: code, phone: _phone, onLogin: onLogin);

      if (!mounted) return;

      if (data['statusCode'] == 200) {
        final body = data['body'];
        final user = User.fromJson(body['user']);
        final accessToken = body['accessToken'];
        final refreshToken = body['refreshToken'];

        const storage = FlutterSecureStorage();
        if (user.userId.isNotEmpty) {
          await storage.write(key: 'userId', value: user.userId);
        }
        if (user.version != null) {
          await storage.write(key: 'version', value: user.version.toString());
        }
        if (accessToken != null) {
          await storage.write(key: 'access_token', value: accessToken);
        }
        if (refreshToken != null) {
          await storage.write(key: 'refreshToken', value: refreshToken);
        }

        ref.read(userStoreProvider.notifier).setUser(user, accessToken);
        ref.watch(userStoreProvider);
        final authController = ref.read(authControllerProvider);
        final result = authController.determineRoute(user, onLogin);

        if (!mounted) return;
        Toast.dismissCurrent();
        Navigator.pushNamed(
          context,
          result.route!,
          arguments: result.arguments,
        );
      } else {
        Toast.show(
          context,
          type: ToastType.error,
          title: 'ยืนยันไม่สำเร็จ',
          message: 'รหัสไม่ถูกต้อง กรุณาลองใหม่',
        );
      }
    } catch (e) {
      if (!mounted) return;
      Toast.show(
        context,
        type: ToastType.error,
        title: 'ยืนยันไม่สำเร็จ',
        message: _cleanError(e),
      );
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _resend() async {
    if (_seconds > 0 || _resending) return;
    setState(() => _resending = true);
    try {
      await BackendOtpService.sendOtp(_phone, context);
      if (!mounted) return;
      _startTimer();
    } catch (e) {
      if (!mounted) return;
      Toast.show(
        context,
        type: ToastType.error,
        title: 'ส่งใหม่ไม่สำเร็จ',
        message: _cleanError(e),
      );
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  String _maskPhone(String p) {
    if (p.length != 10) return p;
    return '${p.substring(0, 3)}-xxx-xx${p.substring(8)}';
  }

  @override
  Widget build(BuildContext context) {
    final masked = _maskPhone(_phone);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              DsAppSecondaryHeader(
                variant: DsAppSecondaryHeaderVariant.baseText,
                title: 'ยืนยัน',
                onBackTap: () => Navigator.pushNamed(
                  context,
                  '/phone',
                  arguments: {
                    'onLogin': onLogin,
                    'phone': _phone,
                  },
                ),
              ),

              const SizedBox(height: 50),

              // ─── Description ─────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'รหัสยืนยันถูกส่งไปยังเบอร์ $masked',
                      style: const TextStyle(
                        color: Color(0xFF2E3036),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── OTP Field ──────────────────────
                    DsOtpField(
                      label: 'กรอกรหัส OTP',
                      length: _length,
                      autoFocus: true,
                      onCompleted: (_) {
                        if (!_verifying) _verify();
                      },
                      onChanged: (code) => setState(() {
                        for (var i = 0; i < _length; i++) {
                          _ctls[i].text = i < code.length ? code[i] : '';
                        }
                      }),
                    ),

                    const SizedBox(height: 10),

                    // ─── Countdown + Resend ─────────────
                    Row(
                      children: [
                        Text(
                          _seconds > 0
                              ? 'ส่งอีกครั้งได้ภายใน $_seconds วินาที'
                              : 'ไม่ได้รับรหัส?',
                          style: const TextStyle(
                            color: Color(0xFF8F9098),
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: (_seconds == 0 && !_resending)
                              ? _resend
                              : null,
                          child: Text(
                            _resending ? 'กำลังส่ง...' : 'ส่งอีกครั้ง',
                            style: TextStyle(
                              color: (_seconds == 0 && !_resending)
                                  ? AppColors.brandPrimary
                                  : const Color(0xFF8F9098),
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              // ─── Button ─────────────────────────────
              SizedBox(
                width: 231,
                child: DsButton(
                  label: _verifying ? 'กำลังยืนยัน...' : 'ยืนยัน',
                  size: DsButtonSize.md,
                  variant: DsButtonVariant.outlinePrimary,
                  onPressed: (_canVerify && !_verifying) ? _verify : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
