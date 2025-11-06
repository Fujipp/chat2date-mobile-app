import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; // ใช้เช็กไฟล์
import 'package:flutter_svg/flutter_svg.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const _svgPath = 'assets/icons/logo_chat2date.svg';

  late final Future<bool> _logoExists;

  @override
  void initState() {
    super.initState();
    // เช็กว่า SVG อยู่จริง (กันพิมพ์ path ผิด / pubspec ไม่ครอบ)
    _logoExists = _checkSvg(_svgPath);

    // เด้งไปหน้า Home
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  Future<bool> _checkSvg(String path) async {
    try {
      await rootBundle.loadString(path);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AspectRatio(
          aspectRatio: 375 / 812,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 50),
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
                // โลโก้ (มี placeholder และกันกรณีหาไฟล์ไม่เจอ)
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 250,
                    height: 250,
                    child: FutureBuilder<bool>(
                      future: _logoExists,
                      builder: (context, snap) {
                        if (snap.connectionState != ConnectionState.done) {
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        }
                        if (snap.data == true) {
                          return SvgPicture.asset(
                            _svgPath,
                            fit: BoxFit.contain,
                            allowDrawingOutsideViewBox: true,
                            placeholderBuilder: (_) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                        // กรณี SVG ไม่พบ/อ่านไม่ได้: โชว์ FlutterLogo ชั่วคราว
                        return const FlutterLogo(size: 120);
                      },
                    ),
                  ),
                ),

                const Align(
                  alignment: Alignment(0, 0.72),
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.6),
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
