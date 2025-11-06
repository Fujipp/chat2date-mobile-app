import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chat2date/components/index.dart'; // มี DsButton / Variant / Size

class HomeLoginPage extends StatelessWidget {
  const HomeLoginPage({super.key});
  static const _logoPath = 'assets/icons/logo_chat2date.svg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AspectRatio(
          aspectRatio: 375 / 812,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 100),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 2, color: Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            child: Stack(
              children: [
                // โลโก้ด้านบน
                Align(
                  alignment: Alignment.topCenter,
                  child: SvgPicture.asset(
                    _logoPath,
                    width: 250,
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                ),

                // กลุ่มปุ่ม (กว้าง 231 สูง 40 ตามดีไซน์)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 231),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: DsButton(
                            label: 'เข้าสู่ระบบด้วยเบอร์โทร',
                            size: DsButtonSize.md, // 231×40, font 16
                            variant: DsButtonVariant
                                .primary, // ฟ้า #5CE1E6 (ตาม scheme ของ Dev)
                            onPressed: () =>
                                Navigator.pushNamed(context, '/phone'),
                          ),
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: DsButton(
                            label: 'ดำเนินการต่อด้วย Google',
                            size: DsButtonSize.md,
                            variant: DsButtonVariant
                                .primary, // ฟ้าชุดเดียวกัน/โทนรอง
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Google Sign-In: TODO'),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Container(
                            width: 160, // ความยาวเส้น (ปรับได้ 140–180)
                            height: 2, // ความหนาเส้น
                            decoration: BoxDecoration(
                              color: Color(0xFFEDEDED), // เทาอ่อน
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: DsButton(
                            label: 'ลงทะเบียน',
                            size: DsButtonSize.md,
                            variant: DsButtonVariant
                                .secondary, // ให้ map เป็นเขียว #C1FF72 ใน schemes
                            onPressed: () =>
                                Navigator.pushNamed(context, '/policy'),
                          ),
                        ),
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
