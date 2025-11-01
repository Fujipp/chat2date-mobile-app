// main.dart
import 'package:chat2date/components/chat/chat_text_component.dart';
import 'package:chat2date/components/common/modal_component.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'package:chat2date/theme/app_theme.dart'; // <— เพิ่ม
import 'package:flutter/material.dart';
//import 'components/chat/partner_text_top_component.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: buildLightTheme(), // <— ใช้ธีมส่วนกลางที่กำหนด font ไว้
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: const Column(
          spacing: 15,
          // เรียกใช้ component ของเรา
          // child: SpinDateModeComponent(
          //   mode: 'single',
          //   prizes: [
          //     {'label': 'Café', 'color': const Color(0xFF81C784)},
          //     {'label': 'Restaurant', 'color': const Color(0xFF64B5F6)},
          //     {'label': 'Park', 'color': const Color(0xFFFFB74D)},
          //     {'label': 'Cinema', 'color': const Color(0xFFE57373)},
          //     {'label': 'Shopping Mall', 'color': const Color(0xFFBA68C8)},
          //     {'label': 'Museum', 'color': const Color(0xFF4DB6AC)},
          //     {'label': 'Beach', 'color': const Color(0xFF9575CD)},
          //     {'label': 'Random', 'color': const Color(0xFFA1887F)},
          //   ],
          // ),
          children: [
            ModalComponent(
              icon: Icons.check_circle,
              colorIcon: Colors.green,
              heightSvg: 78,
              widthSvg: 77,
              topic: 'บันทึกเสร็จสิ้น',
              description:
                  'วันที่และเวลาออกเดตคือ 7 มกราคม 2569 เวลา 9.32 น.\n'
                  'อควาเรียมบางแสน เราจะแจ้งเตือนอีกทีก่อนวันเดต 1 วัน',
              spaceBottom: 15,
              spaceTop: 15,
            ),
            ModalComponent(
              icon: Icons.warning,
              colorIcon: Colors.yellow,
              heightSvg: 78,
              widthSvg: 77,
              topic: 'ติดคูลดาวน์การหาสถานที่เดต 7 วัน',
              description: 'สามารถกดที่          เพื่อดูข้อมูลเพิ่มเติมได้',
              spaceBottom: 15,
              spaceTop: 15,
            ),
            ModalComponent(
              icon: Icons.warning,
              colorIcon: Colors.red,
              heightSvg: 68,
              widthSvg: 77,
              topic: 'คุณถูกแบน',
              description:
                  'เนื่องจากคุณโดนรายงาน และตรวจสอบแล้วว่าผิดจริง\n'
                  'ทำให้คะแนนความประพฤติต่ำกว่าเกณฑ์ที่กำหนด\n'
                  'คุณจะไม่สามารถใช้บัญชีนี้ได้อีกต่อไปและไม่สามารถ\n'
                  'สร้างบัญชีใหม่ของคุณได้อีก',
            ),
            ModalComponent(
              svgPath: 'assets/images/good-ending.svg',
              heightSvg: 68,
              widthSvg: 77,
              topic: 'คุณถูกแบน',
              description:
                  'คุณทั้งคู่มีความเห็นตรงกัน\n'
                  'หวังว่าการเดินทางครั้งนี้\n'
                  'จะเป็นก้าวแรกของความสัมพันธ์ที่ดีขึ้นไปอีก',
            ),
            ModalComponent(
              icon: Icons.bolt,
              colorIcon: Colors.yellow,
              heightSvg: 68,
              widthSvg: 77,
              topic: 'มีฝ่ายหนึ่งรู้สึกไม่พอใจกับการเดินทางครั้งนี้',
              description:
                  'คุณต้องการเปิดโอกาสพูดคุยเพื่อทำความเข้าใจและ\n'
                  'ไปต่อกับคู่ของคุณหรือไม่?',
              choice: true,
              firstChoiceText: 'ไม่ต้องการ',
              firstChoiceColor: AppColors.error,
              secondChoiceText: 'ต้องการ',
              secondChoiceColor: AppColors.brandSecondary,
            ),
            ModalComponent(
              icon: Icons.heart_broken,
              colorIcon: Colors.red,
              heightSvg: 68,
              widthSvg: 77,
              topic: 'เสียใจด้วย',
              description:
                  'ต้องการ ยกเลิกการจับคู่ (Unmatch) กับคู่ของคุณหรือไม่?',
              choice: true,
              firstChoiceText: 'ไม่ต้องการ',
              firstChoiceColor: AppColors.error,
              secondChoiceText: 'ต้องการ',
              secondChoiceColor: AppColors.brandSecondary,
            ),
            ModalComponent(
              imagePath: 'https://i.pravatar.cc/150?img=47',
              heightSvg: 68,
              widthSvg: 77,
              imageName: 'Jessy',
              topic: 'ประเมินคู่เดทของคุณ',
              topicTop: true,
              description: 'คุณพึงพอใจกับคู่เดทของคุณหรือไม่',
              choice: true,
              firstChoiceText: 'ไม่พอใจ',
              firstChoiceColor: AppColors.error,
              secondChoiceText: 'พอใจ',
              secondChoiceColor: AppColors.brandSecondary,
              subDescription: true,
              headingSubDescriptionText: 'คำเตือน: ',
              subDescriptionText:
                  'การเลือกจะมีผลต่อความสัมพันธ์คู่ของคุณ\n'
                  'พึงพอใจทั้งคู่ ถือว่าทั้งคู่ประสบความสำเร็จ\n'
                  'ไม่พึงพอใจทั้งคู่ จะมีให้เลือกว่าจะ unmatch หรือไม่\n'
                  'ไม่พอใจฝ่ายใดฝ่ายหนึ่ง จะมีให้เลือกไปต่อหรือพอแค่นี้\n'
                  'หากฝ่ายใดฝ่ายหนึ่งเลือก unmatch หรือ พอแค่นี้ จะจบทันที',
            ),
            ModalComponent(
              spaceTop: 12,
              spaceBottom: 12,
              svgPath: 'assets/icons/star-rating.svg',
              heightSvg: 35,
              widthSvg: 203,
              topic: 'ให้คะแนนแอปเรา',
              topicTop: true,
              choice: true,
              firstChoiceText: 'ปิด',
              firstChoiceColor: AppColors.error,
              secondChoiceText: 'ส่ง',
              secondChoiceColor: AppColors.brandSecondary,
              subDescription: true,
              headingSubDescriptionText: 'อธิบายเพิ่มเติม',
              headingSubDescriptionColor: Colors.black,
              headingSubDescriptionSize: 12,
              headingSubDescriptionWeight: FontWeight.w700,
              placeholder: true,
              placeholderText: 'Placeholderrrr',
            ),
            StatusTextComponent(
              text: 'เวลา 416545631432',
              width: 173,
              height: 49,
            ),
            ChatTextComponent(text: 'tekxt Message'),
            ChatTextComponent(text: 'nion[ionokdvnov[nvfo[nkbfa[bnfk[ m]]]]]'),
            ChatTextComponent(
              text: 'text Message',
              mainAlignmentRow: MainAxisAlignment.end,
            ),
            StatusTextComponent(
              text: 'เห็นแล้ว',
              width: 60,
              height: 10,
              textSize: 12,
              alignment: Alignment.topRight,
              icon: Icons.visibility,
              iconSize: 12,
              iconColor: Colors.amber,
            ),
            ChatTextComponent(
              text: 'nion[ionokdvnov[nvfo[nkbfa[bnfk[ m]]]]]',
              mainAlignmentRow: MainAxisAlignment.start,
              icon: Icons.abc,
              widthSvg: 50,
              heightSvg: 50,
              colorIcon: Colors.green,
              bottomLeftRadius: 0,
              bottomRightRadius: 20,
              color: Color(0xFFF7FAFE),
              colorText: Colors.black,
            ),
            ChatTextComponent(
              text: 'nion[ionokdvnov[nvfo[nkbfa[bnfk[ m]]]]]',
              mainAlignmentRow: MainAxisAlignment.start,
              crossAlignmentRow: CrossAxisAlignment.end,
              svgPath: 'assets/icons/bot.svg',
              widthSvg: 50,
              heightSvg: 50,
              bottomLeftRadius: 0,
              bottomRightRadius: 20,
              color: Color(0xFFFFF2CC),
              colorText: Colors.black,
            ),
            ChatTextComponent(text: "สวัสดีครับ"),

            ChatTextComponent(
              text: "ยอดรวมทั้งหมด: ",
              description: "1,250 บาท",
              color: Colors.orangeAccent,
              colorText: Colors.white,
              colorDescription: Colors.yellowAccent,
              svgPath: 'assets/icons/bot.svg',
              widthSvg: 50,
              heightSvg: 50,
              bottomLeftRadius: 0,
              bottomRightRadius: 20,
              mainAlignmentRow: MainAxisAlignment.start,
              crossAlignmentRow: CrossAxisAlignment.end,
            ),

            ChatTextComponent(
              text: "รายการชำระเงินสำเร็จ",
              color: Colors.green,
              subDescription: "เวลา: 10:35 น.",
              subDescriptionColor: Colors.white70,
              svgPath: 'assets/icons/bot.svg',
              widthSvg: 50,
              heightSvg: 50,
              bottomLeftRadius: 0,
              bottomRightRadius: 20,
              mainAlignmentRow: MainAxisAlignment.start,
              crossAlignmentRow: CrossAxisAlignment.end,
            ),

            ChatTextComponent(
              text: "ข้อความพร้อมไอคอน",
              icon: Icons.chat_bubble_outline,
              colorIcon: Colors.yellow,
              widthSvg: 24,
              heightSvg: 24,
              bottomLeftRadius: 0,
              bottomRightRadius: 20,
              mainAlignmentRow: MainAxisAlignment.start,
              crossAlignmentRow: CrossAxisAlignment.end,
            ),

            ChatTextComponent(
              text: "ข้อความพร้อม SVG",
              svgPath: 'assets/icons/avatar.svg',
              widthSvg: 24,
              heightSvg: 24,
              mainAlignmentRow: MainAxisAlignment.start,
              crossAlignmentRow: CrossAxisAlignment.end,
              bottomLeftRadius: 0,
              bottomRightRadius: 20,
            ),

            ChatTextComponent(
              mainAlignmentRow: MainAxisAlignment.start,
              crossAlignmentRow: CrossAxisAlignment.end,
              color: Colors.yellow,
              text: "คุณต้องการดำเนินการต่อหรือไม่?",
              actionButton: true,
              actionButtonText: "ดำเนินการต่อ",
              subDescription: 'เหลือเวลาเริ่มใหม่ 24 ชั่วโมง',
              svgPath: 'assets/icons/bot.svg',
              widthSvg: 50,
              heightSvg: 50,
              bottomLeftRadius: 0,
              bottomRightRadius: 20,
            ),

            ChatTextComponent(
              mainAlignmentRow: MainAxisAlignment.start,
              crossAlignmentRow: CrossAxisAlignment.end,
              color: Colors.yellow,
              text: "กลับไปเล่นใหม่อีกรอบ",
              choice: true,
              firstChoiceText: "ใช่",
              firstChoiceColor: Colors.green,
              secondChoiceText: "ไม่ใช่",
              secondChoiceColor: Colors.redAccent,
              description:
                  "หมายเหตุ เมื่อกดเริ่มแล้วจะไม่สามารถกลับ\n"
                  "มาเล่นอีกรอบได้ควรคุยหรือรอคู่ของคุณก่อน",
              subDescription: 'เหลือเวลาเริ่มใหม่ 24 ชั่วโมง',
              svgPath: 'assets/icons/bot.svg',
              widthSvg: 50,
              heightSvg: 50,
              bottomLeftRadius: 0,
              bottomRightRadius: 20,
            ),
          ],
        ),
      ),
    );
  }
}
