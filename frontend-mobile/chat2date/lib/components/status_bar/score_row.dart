import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'stacked_progress_bar.dart';

enum ChangeDirection { up, down, none }

class ScoreRow extends StatelessWidget {
  const ScoreRow({
    super.key,
    // ค่าหลัก
    required this.basePercent, // 0..1 ความยาวฐาน
    this.overlayPercent, // 0..1 ความยาวซ้อนทับ (ใช้เมื่อ level != 3)
    this.overlayDirection = ChangeDirection.none,
    this.number = 0, // เลขบนหัวใจ (0 = ซ่อน)
    // ไฟล์ SVG
    this.heartSvg = 'assets/icons/HEART_STATUS_BAR.svg',
    this.rightSvg = 'assets/icons/INFO_STATUS_BAR.svg',
    // ขนาด
    this.barWidth = 255,
    this.barHeight = 10,
    this.leadingWidth = 25,
    this.leadingHeight = 22,
    this.rightIconSize = 20,
    this.showRightIcon = true,
    this.onRightIconTap,
  });

  final double basePercent;
  final double? overlayPercent;
  final ChangeDirection overlayDirection;
  final int number;

  final String heartSvg;
  final String rightSvg;

  final double barWidth;
  final double barHeight;
  final double leadingWidth;
  final double leadingHeight;
  final double rightIconSize;
  final bool showRightIcon;
  final VoidCallback? onRightIconTap;

  // Gradient สีรุ้ง
  static const LinearGradient _rainbow = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFC8A2E7), // ม่วงอ่อน
      Color(0xFF9FBBFF), // ฟ้า
      Color(0xFFA7EAF2), // ฟ้าน้ำทะเล
      Color(0xFFB7E4C7), // เขียวมิ้นต์
      Color(0xFFFFF1A8), // เหลืองอ่อน
      Color(0xFFFFD1A6), // ส้มพีช
      Color(0xFFFFB3B3), // ชมพู
    ],
  );

  @override
  Widget build(BuildContext context) {
    const pink = Color(0xFFFF8FB3);
    const yellow = Color(0xFFFFD166);
    const red = Color(0xFFFF5A5A);

    final bool isLevelMax = number == 3 && basePercent == 1;
    final double base = basePercent.clamp(0, 1);

    // === สร้าง segments ของ “หลอด” ===
    final List<ProgressSegment> segments = [];
    if (isLevelMax) {
      // หลอดสายรุ้ง ตามความยาว basePercent
      segments.add(ProgressSegment(percent: base, gradient: _rainbow));
      // ไม่ใช้ overlay เมื่อเป็น level 3
    } else {
      // ฐานชมพู
      segments.add(ProgressSegment(percent: base, color: pink));
      // ซ้อนทับเหลือง/แดง เมื่อกำหนด overlay
      if (overlayPercent != null && overlayPercent! > 0) {
        segments.add(
          ProgressSegment(
            percent: overlayPercent!.clamp(0, 1),
            color: overlayDirection == ChangeDirection.up
                ? yellow
                : (overlayDirection == ChangeDirection.down ? red : null),
          ),
        );
      }
    }

    // === สร้างหัวใจ ===
    Widget _buildHeart() {
      if (isLevelMax) {
        // หัวใจเป็นรุ้ง และซ่อนตัวเลข
        return SizedBox(
          width: leadingWidth,
          height: leadingHeight,
          child: ShaderMask(
            shaderCallback: (Rect bounds) => _rainbow.createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: SvgPicture.asset(
              heartSvg,
              width: leadingWidth,
              height: leadingHeight,
              // ให้ path รับสีจาก ShaderMask
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        );
      }
      // หัวใจปกติ + เลขถ้า number != 0
      return SizedBox(
        width: leadingWidth,
        height: leadingHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              heartSvg,
              width: leadingWidth,
              height: leadingHeight,
            ),
            if (number != 0)
              Text(
                '$number',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // หัวใจ (รุ้งเมื่อ level 3)
        _buildHeart(),

        // หลอด (รุ้งเมื่อ level 3)
        StackedProgressBar(
          segments: segments,
          width: barWidth,
          height: barHeight,
        ),

        // ไอคอนขวา
        if (showRightIcon)
          GestureDetector(
            onTap: onRightIconTap, // เรียกฟังก์ชันเมื่อกด
            behavior:
                HitTestBehavior.opaque, // ช่วยให้กดง่ายขึ้นแม้พื้นที่โปร่งใส
            child: SvgPicture.asset(
              rightSvg,
              width: rightIconSize,
              height: rightIconSize,
            ),
          ),
      ],
    );
  }
}
