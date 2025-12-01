import 'package:chat2date/components/index.dart'; // DsButton / Variant / Size
import 'package:chat2date/components/toasts/toast.dart';
import 'package:chat2date/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeLoginPage extends ConsumerWidget {
  const HomeLoginPage({super.key});

  // ใช้ PNG แทน SVG
  static const _logoPath = 'assets/images/logo_chat2date_text.png';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // เอากรอบมือถือออก: ไม่ใช้ AspectRatio + Container + ShapeDecoration แล้ว
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 420,
            ), // กันหน้ากว้างเกิน
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  // โลโก้ด้านบน
                  Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 16),
                    child: Image.asset(
                      _logoPath,
                      width: 250,
                      height: 250,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          const FlutterLogo(size: 120),
                    ),
                  ),

                  const Spacer(),

                  // กลุ่มปุ่ม (กว้างไม่เกิน 231 ตามดีไซน์)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 231),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: DsButton(
                            label: 'เข้าสู่ระบบด้วยเบอร์โทร',
                            size: DsButtonSize.md, // 231×40, font 16
                            variant: DsButtonVariant.primary,
                            onPressed: () => Navigator.pushNamed(
                              context,
                              '/phone',
                              arguments: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          child: DsButton(
                            label: 'ดำเนินการต่อด้วย Google',
                            size: DsButtonSize.md,
                            variant: DsButtonVariant.primary,
                            onPressed: () async {
                              try {
                                final authController = ref.read(
                                  authControllerProvider,
                                );
                                final result = await authController
                                    .handleGoogleLogin(
                                      context: context,
                                      onLogin: true,
                                    );

                                // ✅ เช็คว่าเป็น error หรือไม่
                                if (!context.mounted) return;

                                if (result.isError) {
                                  // ถ้าเป็น ACCOUNT_DELETED -> dialog แสดงแล้ว
                                  if (result.errorMessage ==
                                      'ACCOUNT_DELETED') {
                                    return;
                                  }

                                  // Error อื่นๆ
                                  Toast.show(
                                    context,
                                    type: ToastType.error,
                                    title: 'ผิดพลาด',
                                    message:
                                        result.errorMessage ?? 'เกิดข้อผิดพลาด',
                                  );
                                  return;
                                }

                                // ✅ Login สำเร็จ
                                if (result.route != null) {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    result.route!,
                                    arguments: result.arguments,
                                  );
                                }
                              } catch (e) {
                                if (!context.mounted) return;

                                if (e.toString().contains('cancel')) {
                                  return;
                                }

                                Toast.show(
                                  context,
                                  type: ToastType.error,
                                  title: 'ผิดพลาด',
                                  message: e.toString(),
                                );
                              }
                            },
                          ),
                        ),

                        const SizedBox(height: 20),
                        // เส้นคั่น
                        Center(
                          child: Container(
                            width: 160,
                            height: 2,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDEDED),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          child: DsButton(
                            label: 'ลงทะเบียน',
                            size: DsButtonSize.md,
                            variant: DsButtonVariant.secondary,
                            onPressed: () =>
                                Navigator.pushNamed(context, '/policy'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
