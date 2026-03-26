import 'package:flutter/material.dart';
// ลบถ้าไม่ได้ใช้: import 'stacked_progress_bar.dart';
import 'score_row.dart';

class StatusBarExample extends StatelessWidget {
  const StatusBarExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 362,
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFF9747FF)),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ชุดที่ 1: ฐานชมพู 0.27 + เพิ่ม (เหลือง) 0.34
          ScoreRow(
            number: 0, // 0 = ไม่โชว์เลขในหัวใจ
            basePercent: 0.27,
            overlayPercent: 0.34,
            overlayDirection: ChangeDirection.up, // up=เหลือง
            heartSvg: 'assets/icons/ui/HEART_STATUS_BAR.svg',
            rightSvg: 'assets/icons/ui/INFO_STATUS_BAR.svg',
            barWidth: 255,
            barHeight: 10,
            leadingWidth: 25,
            leadingHeight: 22,
            rightIconSize: 20,
          ),
          SizedBox(height: 12),

          // ชุดที่ 2: ฐานชมพู 0.35 (ไม่มีเพิ่ม/ลด)
          ScoreRow(
            number: 0,
            basePercent: 0.35,
            overlayPercent: 0.0,
            overlayDirection: ChangeDirection.none,
            heartSvg: 'assets/icons/ui/HEART_STATUS_BAR.svg',
            rightSvg: 'assets/icons/ui/INFO_STATUS_BAR.svg',
            barWidth: 255,
            barHeight: 10,
            leadingWidth: 25,
            leadingHeight: 22,
            rightIconSize: 20,
          ),
          SizedBox(height: 12),

          // ชุดที่ 3: แสดงเลข 1 ในหัวใจ + ฐานชมพู 0.50
          ScoreRow(
            number: 1,
            basePercent: 0.50,
            overlayPercent: 0.0,
            overlayDirection: ChangeDirection.none,
            heartSvg: 'assets/icons/ui/HEART_STATUS_BAR.svg',
            rightSvg: 'assets/icons/ui/INFO_STATUS_BAR.svg',
            barWidth: 255,
            barHeight: 10,
            leadingWidth: 25,
            leadingHeight: 22,
            rightIconSize: 20,
          ),
          SizedBox(height: 12),

          // ชุดที่ 4: แสดงเลข 2 ในหัวใจ + ฐานชมพู 0.74
          ScoreRow(
            number: 2,
            basePercent: 0.74,
            overlayPercent: 0.0,
            overlayDirection: ChangeDirection.none,
            heartSvg: 'assets/icons/ui/HEART_STATUS_BAR.svg',
            rightSvg: 'assets/icons/ui/INFO_STATUS_BAR.svg',
            barWidth: 255,
            barHeight: 10,
            leadingWidth: 25,
            leadingHeight: 22,
            rightIconSize: 20,
          ),
          SizedBox(height: 12),

          // ชุดที่ 5: เทียบเคยเป็น gradient → ใช้ level=3 = แถบรุ้งอัตโนมัติ
          ScoreRow(
            number: 3,
            basePercent: 0.60,
            overlayPercent: 0.0,
            overlayDirection: ChangeDirection.none,
            heartSvg: 'assets/icons/ui/HEART_STATUS_BAR.svg',
            rightSvg: 'assets/icons/ui/INFO_STATUS_BAR.svg',
            barWidth: 255,
            barHeight: 10,
            leadingWidth: 25,
            leadingHeight: 22,
            rightIconSize: 20,
          ),
        ],
      ),
    );
  }
}
