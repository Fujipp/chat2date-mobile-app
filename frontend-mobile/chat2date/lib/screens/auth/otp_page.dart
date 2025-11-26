import 'dart:async';
import 'package:chat2date/controllers/auth_controller.dart';
import 'package:chat2date/models/user.dart';
import 'package:chat2date/services/user_service.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chat2date/components/buttons/index.dart'; // DsButton / enums
import 'package:chat2date/services/backend_otp_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  String _token = '';
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
        _token = (args['token'] ?? '') as String;
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
    for (final c in _ctls) c.dispose();
    for (final f in _nodes) f.dispose();
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

  void _onChanged(int index, String value) {
    // รองรับ paste หลายหลัก
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '').split('');
      for (var i = 0; i < _length && i < digits.length; i++) {
        _ctls[i].text = digits[i];
      }
      final target = (digits.length >= _length) ? _length - 1 : digits.length;
      if (target < _nodes.length) _nodes[target].requestFocus();
      setState(() {});
      return;
    }

    // พิมพ์ทีละหลัก: เดินหน้า/ถอยหลังอัตโนมัติ
    if (value.isNotEmpty && index < _length - 1) {
      _nodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _nodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  // รองรับ Backspace เคลื่อนโฟกัสกลับช่องก่อนหน้าเมื่อเป็นค่าว่าง
  KeyEventResult _onKey(FocusNode node, KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_ctls[index].text.isEmpty && index > 0) {
        _nodes[index - 1].requestFocus();
        _ctls[index - 1].clear();
        setState(() {});
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  Future<void> _verify() async {
    final code = _code();
    if (code.length != _length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอก OTP ให้ครบ 6 หลัก')),
      );
      return;
    }
    setState(() => _verifying = true);
    try {
      final isExist = await UserService.checkPhone(_phone);
      if (onLogin && !isExist) {
        throw Exception('ไม่สามารถเข้าสู่ระบบได้ เนื่องจากไม่มีเบอร์นี้ในระบบ');
      }
      if (!onLogin && isExist) {
        throw Exception(
          'ไม่สามารถลงทะเบียนเบอร์นี้ได้ เนื่องจากมีเบอร์นี้ในระบบแล้ว',
        );
      }

      final data = await ref.read(backendOtpServiceProvider).validateOtp(token: _token, code: code, phone: _phone, onLogin: onLogin);
      if (!mounted) return;
      if (data['statusCode'] == 200) {
        final user = User.fromJson(data['body']['user']);
        final accessToken = data['body']['accessToken'];
        ref.read(userStoreProvider.notifier).setUser(user, accessToken);
        ref.watch(userStoreProvider);
        final authController = ref.read(authControllerProvider);
        final result = authController.determineRoute(user, onLogin);
        Navigator.pushNamed(context, result.route, arguments: result.arguments);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('รหัสไม่ถูกต้อง กรุณาลองใหม่')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ยืนยันไม่สำเร็จ: $e')));
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _resend() async {
    if (_seconds > 0 || _resending) return;
    setState(() => _resending = true);
    try {
      final newToken = await BackendOtpService.sendOtp(_phone);
      if (!mounted) return;
      _token = newToken;
      _startTimer();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ส่ง OTP ใหม่แล้ว')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ส่งใหม่ไม่สำเร็จ: $e')));
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  String _maskPhone(String p) {
    if (p.length != 10) return p;
    return '${p.substring(0, 3)}-xxx-xx${p.substring(8)}'; // 081-xxx-xx89
  }

  @override
  Widget build(BuildContext context) {
    final masked = _maskPhone(_phone);

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
                // ปุ่มย้อนกลับ -> /phone
                IconButton(
                  splashRadius: 26,
                  onPressed: () => {
                    Navigator.pushNamed(context, '/phone', arguments: onLogin),
                  },
                  icon: SvgPicture.asset(
                    'assets/icons/icon_arrow-back-circle.svg',
                    width: 32,
                    height: 32,
                  ),
                ),
                const SizedBox(height: 8),

                // หัวข้อ
                const Text(
                  'OTP',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 12),

                // คำอธิบาย/เบอร์
                Text(
                  'รหัสยืนยันถูกส่งไปยังเบอร์ $masked',
                  style: const TextStyle(
                    color: Color(0xFF2E3036),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),

                // ช่อง OTP 6 ช่อง
                SizedBox(
                  width: 290,
                  height: 48,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_length, (i) {
                      return Padding(
                        padding: EdgeInsets.only(
                          right: i == _length - 1 ? 0 : 10,
                        ),
                        child: SizedBox(
                          width: 40,
                          height: 44,
                          child: Focus(
                            onKeyEvent: (node, e) => _onKey(node, e, i),
                            child: TextField(
                              controller: _ctls[i],
                              focusNode: _nodes[i],
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              keyboardType: TextInputType.number,
                              textInputAction: i == _length - 1
                                  ? TextInputAction.done
                                  : TextInputAction.next,
                              autofillHints: const [AutofillHints.oneTimeCode],
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    width: 1.2,
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    width: 1.2,
                                    color: Color(0xFF5CE1E6),
                                  ),
                                ),
                              ),
                              onChanged: (v) => _onChanged(i, v),
                              onSubmitted: (_) {
                                if (i == _length - 1 &&
                                    _canVerify &&
                                    !_verifying) {
                                  _verify();
                                }
                              },
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 10),

                // นับถอยหลัง + ส่งอีกครั้ง
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
                        height: 1.4,
                        letterSpacing: 0.15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: (_seconds == 0 && !_resending)
                          ? _resend
                          : null,
                      child: Text(_resending ? 'กำลังส่ง...' : 'ส่งอีกครั้ง'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ปุ่มยืนยัน (เปิดเฉพาะเมื่อครบ 6 หลัก)
                Center(
                  child: SizedBox(
                    width: 231,
                    height: 40,
                    child: DsButton(
                      label: _verifying ? 'กำลังยืนยัน...' : 'ยืนยัน',
                      size: DsButtonSize.md,
                      variant: DsButtonVariant.primary,
                      onPressed: (_canVerify && !_verifying) ? _verify : null,
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
