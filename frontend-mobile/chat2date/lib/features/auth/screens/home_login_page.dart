import 'package:chat2date/components/design_system/index.dart';
import 'package:chat2date/features/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeLoginPage extends ConsumerWidget {
  const HomeLoginPage({super.key});

  static const _logoPath = 'assets/branding/logos/logo_chat2date_default.svg';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ─── Logo ─────────────────────────────────
                SvgPicture.asset(
                  _logoPath,
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                ),

                const Spacer(),

                // ─── Buttons ──────────────────────────────
                SizedBox(
                  width: 231,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ปุ่ม 1: เข้าสู่ระบบด้วยเบอร์โทร (outline)
                      SizedBox(
                        width: 231,
                        child: DsButton(
                          label: 'เข้าสู่ระบบด้วยเบอร์โทร',
                          size: DsButtonSize.md,
                          variant: DsButtonVariant.outlinePrimary,
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/phone',
                            arguments: true,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ปุ่ม 2: ดำเนินการต่อด้วย Google (outline)
                      SizedBox(
                        width: 231,
                        child: DsButton(
                          label: 'ดำเนินการต่อด้วย Google',
                          size: DsButtonSize.md,
                          variant: DsButtonVariant.outlinePrimary,
                          onPressed: () => _handleGoogleLogin(context, ref),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // เส้นคั่น
                      Container(
                        width: 160,
                        height: 2,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDEDED),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ปุ่ม 3: ลงทะเบียน (filled)
                      SizedBox(
                        width: 231,
                        child: DsButton(
                          label: 'ลงทะเบียน',
                          size: DsButtonSize.md,
                          variant: DsButtonVariant.primary,
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/policy',
                            arguments: {'goKyc': false, 'onRegister': true},
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _cleanError(dynamic e) {
    return e.toString().replaceAll(RegExp(r'^Exception:\s*'), '');
  }

  Future<void> _handleGoogleLogin(BuildContext context, WidgetRef ref) async {
    try {
      final authController = ref.read(authControllerProvider);
      final result = await authController.handleGoogleLogin(
        context: context,
        onLogin: true,
      );

      if (!context.mounted) return;

      if (result.isError) {
        if (result.errorMessage == 'ACCOUNT_DELETED') return;
        final errMsg = (result.errorMessage ?? '').toLowerCase();
        if (errMsg.contains('cancel') || errMsg.contains('ยกเลิก')) return;

        Toast.show(
          context,
          type: ToastType.error,
          title: 'ผิดพลาด',
          message: _cleanError(result.errorMessage ?? 'เกิดข้อผิดพลาด'),
        );
        return;
      }

      if (result.route != null) {
        Toast.dismissCurrent();
        Navigator.pushReplacementNamed(
          context,
          result.route!,
          arguments: result.arguments,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      final msg = e.toString().toLowerCase();
      if (msg.contains('cancel') || msg.contains('ยกเลิก')) return;

      Toast.show(
        context,
        type: ToastType.error,
        title: 'ผิดพลาด',
        message: _cleanError(e),
      );
    }
  }
}
