import 'package:chat2date/components/buttons/ds_button.dart';
import 'package:chat2date/components/buttons/ds_icon_button.dart';
import 'package:chat2date/components/calendar/index.dart';
import 'package:chat2date/components/card/card_chat_component.dart';
import 'package:chat2date/components/card/generic_card.dart';
import 'package:chat2date/components/chat/chat_text_component.dart';
import 'package:chat2date/components/chat/content_switcher.dart';
import 'package:chat2date/components/chat/input_chat_component.dart';
import 'package:chat2date/components/chat/spin_date_component.dart';
import 'package:chat2date/components/common/loading_component.dart';
import 'package:chat2date/components/common/modal_component.dart';
import 'package:chat2date/components/inputs/index.dart';
import 'package:chat2date/components/layout/header.dart';
import 'package:chat2date/components/layout/menu_bar.dart';
import 'package:chat2date/components/layout/responsive_container.dart';
import 'package:chat2date/components/status_bar/gps_alert.dart';
// Status Bar components
import 'package:chat2date/components/status_bar/score_row.dart';
import 'package:chat2date/components/status_bar/stacked_progress_bar.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ComponentTestScreen extends StatefulWidget {
  const ComponentTestScreen({super.key});

  @override
  State<ComponentTestScreen> createState() => _ComponentTestScreenState();
}

class _ComponentTestScreenState extends State<ComponentTestScreen> {
  int selectedIndex1 = 1; // เริ่มที่ Section 2
  int selectedIndex2 = 1; // เริ่มที่ Tab 2
  int selectedIndex3 = 1; // เริ่มที่ icon people
  int selectedIndex4 = 0; // เริ่มที่ Name A

  int bottomNavIndex = 0;

  final int _counter = 0;

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _nextCtrl = TextEditingController();
  final _addCtrl = TextEditingController();
  final _selectCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Generic Card Test'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Generic Cards
          const Text(
            'Generic_card',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          GenericCard(
            iconType: CardIconType.image,
            //iconBackground: Colors.blue[50],
            title: 'Title',
            subtitle: 'Subtitle',
            actionType: CardActionType.button,
            buttonText: 'Button',
            onTap: () => print('Card tapped'),
            onButtonTap: () => print('Button tapped'),
          ),
          GenericCard(
            iconType: CardIconType.image,
            //iconBackground: Colors.blue[50],
            title: 'Title',
            subtitle: 'Subtitle',
            actionType: CardActionType.chevron,
            onTap: () => print('Card tapped'),
          ),
          GenericCard(
            iconType: CardIconType.image,
            //iconBackground: Colors.blue[50],
            title: 'Title',
            subtitle: 'Subtitle',
            onTap: () => print('Card tapped'),
          ),
          const SizedBox(height: 8),
          GenericCard(
            iconType: CardIconType.avatar,
            //iconBackground: Colors.blue[100],
            icon: Icons.person,
            iconColor: Colors.blue[700],
            title: 'Title',
            subtitle: 'Subtitle',
            actionType: CardActionType.button,
            buttonText: 'Button',
            onButtonTap: () => print('Button tapped'),
          ),
          GenericCard(
            iconType: CardIconType.avatar,
            //iconBackground: Colors.blue[100],
            icon: Icons.person,
            iconColor: Colors.blue[700],
            title: 'Title',
            subtitle: 'Subtitle',
            actionType: CardActionType.chevron,
            onTap: () => print('Card tapped'),
          ),
          GenericCard(
            iconType: CardIconType.avatar,
            icon: Icons.person,
            iconColor: Colors.blue[700],
            title: 'Title',
            subtitle: 'Subtitle',
          ),
          GenericCard(
            iconType: CardIconType.avatar,
            //iconBackground: Colors.grey[800],
            icon: Icons.person,
            iconColor: Colors.white,
            title: 'Title',
            subtitle: 'Subtitle',
          ),
          const SizedBox(height: 8),
          GenericCard(
            iconType: CardIconType.icon,
            icon: Icons.favorite,
            iconColor: Colors.blue,
            //iconBackground: Colors.blue[50],
            title: 'Title',
            subtitle: 'Subtitle',
            actionType: CardActionType.button,
            buttonText: 'Button',
            onButtonTap: () => print('Button tapped'),
          ),
          GenericCard(
            iconType: CardIconType.icon,
            icon: Icons.favorite,
            iconColor: Colors.blue,
            //iconBackground: Colors.blue[50],
            title: 'Title',
            subtitle: 'Subtitle',
            actionType: CardActionType.chevron,
            onTap: () => print('Card tapped'),
          ),
          GenericCard(
            iconType: CardIconType.icon,
            title: 'Title',
            subtitle: 'Subtitle',
          ),
          const SizedBox(height: 8),
          const GenericCard(
            title: 'Title',
            subtitle: 'Subtitle',
            actionType: CardActionType.button,
            buttonText: 'Button',
          ),
          const GenericCard(
            title: 'Title',
            subtitle: 'Subtitle',
            actionType: CardActionType.chevron,
          ),
          const GenericCard(title: 'Title', subtitle: 'Subtitle'),

          // Headers
          const Text(
            'Headers',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Header(
            name: 'John Doe',
            showCalendar: true,
            showSpinwheel: true,
            showFlag: true,
            onBack: () => print('Back pressed'),
          ),
          SizedBox(height: 16),
          Header(
            name: 'เบรโต',
            showCalendar: true,
            showSpinwait: true,
            showFlag: true,
          ),
          SizedBox(height: 16),
          Header(name: 'User 3', showFlag: true),
          SizedBox(height: 16),
          Header(name: 'โมจิกิ', showOptions: true),
          SizedBox(height: 16),
          ChatToDateHeaderWhite(
            leftIconPath: 'assets/icons/icon_chat2date_full.svg',
            rightIconPath: 'assets/icons/icon_menu.svg',
            iconColor: Color(0xFF5ce1e6),
            onBack: () {},
            onSettings: () {},
          ),
          SizedBox(height: 16),
          ChatToDateHeaderGradient(
            leftIconPath: 'assets/icons/icon_chat2date_full.svg',
            rightIconPath: 'assets/icons/icon_menu.svg',
            iconColor: Colors.white,
            onBack: () {},
            onSettings: () {},
          ),

          // Content Switchers
          const Text(
            'Content Switchers',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ContentSwitcher(
            items: const ['Section 1', 'Section 2'],
            selectedIndex: selectedIndex1,
            onChanged: (index) => setState(() => selectedIndex1 = index),
          ),
          const SizedBox(height: 12),

          ContentSwitcher(
            items: const ['Tab 1', 'Tab 2', 'Tab 3', 'Tab 4'],
            selectedIndex: selectedIndex2,
            onChanged: (index) => setState(() => selectedIndex2 = index),
          ),
          const SizedBox(height: 12),

          IconSwitcher(
            selectedIndex: selectedIndex3,
            onChanged: (index) => setState(() => selectedIndex3 = index),
          ),
          const SizedBox(height: 12),

          NameSwitcher(
            items: const ['Name A', 'Name B'],
            selectedIndex: selectedIndex4,
            onChanged: (index) => setState(() => selectedIndex4 = index),
          ),
          const SizedBox(height: 24),

          const Text(
            'GPS Map Alert',

            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          const GpsMapAlert(),

          const SizedBox(height: 24),

          const Text(
            'TagSelection',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          TagSelection(
            items: const ['Style 1', 'Style 2', 'Style 3'],
            initialSelected: [0, 2],
          ),

          const SizedBox(height: 24),

          const Text(
            'TagSelection',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          //Hutch
          ModalComponent(
            svgPath: 'assets/icons/icon_done.svg',
            heightSvg: 78,
            widthSvg: 77,
            topic: 'บันทึกเสร็จสิ้น',
            description:
                'วันที่และเวลาออกเดตคือ 7 มกราคม 2569 เวลา 9.32 น.\n'
                'อควาเรียมบางแสน เราจะแจ้งเตือนอีกทีก่อนวันเดต 1 วัน',
            spaceBottom: 15,
            spaceTop: 15,
          ),

          const SizedBox(height: 12),

          ModalComponent(
            svgPath: 'assets/icons/icon_warning.svg',
            heightSvg: 78,
            widthSvg: 77,
            topic: 'ติดคูลดาวน์การหาสถานที่เดต 7 วัน',
            description: 'สามารถกดที่          เพื่อดูข้อมูลเพิ่มเติมได้',
            spaceBottom: 15,
            spaceTop: 15,
          ),

          const SizedBox(height: 12),

          ModalComponent(
            svgPath: 'assets/icons/icon_banning.svg',
            heightSvg: 68,
            widthSvg: 77,
            topic: 'คุณถูกแบน',
            description:
                'เนื่องจากคุณโดนรายงาน และตรวจสอบแล้วว่าผิดจริง\n'
                'ทำให้คะแนนความประพฤติต่ำกว่าเกณฑ์ที่กำหนด\n'
                'คุณจะไม่สามารถใช้บัญชีนี้ได้อีกต่อไปและไม่สามารถ\n'
                'สร้างบัญชีใหม่ของคุณได้อีก',
          ),

          const SizedBox(height: 12),

          ModalComponent(
            svgPath: 'assets/icons/icon_good-ending.svg',
            heightSvg: 68,
            widthSvg: 77,
            topic: 'คุณถูกแบน',
            description:
                'คุณทั้งคู่มีความเห็นตรงกัน\n'
                'หวังว่าการเดินทางครั้งนี้\n'
                'จะเป็นก้าวแรกของความสัมพันธ์ที่ดีขึ้นไปอีก',
          ),

          const SizedBox(height: 12),

          ModalComponent(
            svgPath: 'assets/icons/icon_one-sided.svg',
            heightSvg: 68,
            widthSvg: 77,
            topic: 'มีฝ่ายหนึ่งรู้สึกไม่พอใจกับการเดินทางครั้งนี้',
            description:
                'คุณต้องการเปิดโอกาสพูดคุยเพื่อทำความเข้าใจและ\n'
                'ไปต่อกับคู่ของคุณหรือไม่?',
            choice: true,
            firstChoiceText: 'ไม่ต้องการ',
            secondChoiceText: 'ต้องการ',
          ),

          const SizedBox(height: 12),

          ModalComponent(
            svgPath: 'assets/icons/icon_bad-ending.svg',
            heightSvg: 68,
            widthSvg: 77,
            topic: 'เสียใจด้วย',
            description:
                'ต้องการ ยกเลิกการจับคู่ (Unmatch) กับคู่ของคุณหรือไม่?',
            choice: true,
            firstChoiceText: 'ไม่ต้องการ',
            secondChoiceText: 'ต้องการ',
          ),

          const SizedBox(height: 12),

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
            secondChoiceText: 'พอใจ',
            subDescription: true,
            headingSubDescriptionText: 'คำเตือน: ',
            subDescriptionText:
                'การเลือกจะมีผลต่อความสัมพันธ์คู่ของคุณ\n'
                'พึงพอใจทั้งคู่ ถือว่าทั้งคู่ประสบความสำเร็จ\n'
                'ไม่พึงพอใจทั้งคู่ จะมีให้เลือกว่าจะ unmatch หรือไม่\n'
                'ไม่พอใจฝ่ายใดฝ่ายหนึ่ง จะมีให้เลือกไปต่อหรือพอแค่นี้\n'
                'หากฝ่ายใดฝ่ายหนึ่งเลือก unmatch หรือ พอแค่นี้ จะจบทันที',
          ),

          const SizedBox(height: 12),

          ModalComponent(
            spaceTop: 12,
            spaceBottom: 12,
            svgPath: 'assets/icons/icon_star-rating.svg',
            heightSvg: 35,
            widthSvg: 203,
            topic: 'ให้คะแนนแอปเรา',
            topicTop: true,
            choice: true,
            firstChoiceText: 'ปิด',
            secondChoiceText: 'ส่ง',
            subDescription: true,
            headingSubDescriptionText: 'อธิบายเพิ่มเติม',
            headingSubDescriptionColor: Colors.black,
            headingSubDescriptionWeight: FontWeight.w700,
            placeholder: true,
            placeholderText: 'Placeholderrrr',
          ),

          const SizedBox(height: 24),

          const Text(
            'Status + chat',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          StatusTextComponent(text: 'วันเสาร์ เวลา 12.30 น.', isMiddle: true),

          const SizedBox(height: 12),

          ChatTextComponent(text: 'tekxt Message', isChatRight: true),

          const SizedBox(height: 12),

          ChatTextComponent(
            text: 'nion[ionokdvnov[nvfo[nkbfa[bnfk[ m]]]]]',
            isChatRight: true,
          ),

          const SizedBox(height: 12),

          ChatTextComponent(text: 'text Message', isChatRight: true),

          const SizedBox(height: 12),

          StatusTextComponent(
            text: 'เห็นแล้ว',
            textSize: 12,
            svgPath: "assets/icons/icon_seen.svg",
            size: 12,
            isMiddle: false,
          ),

          const SizedBox(height: 12),

          ChatTextComponent(
            text: 'hi kate!',
            svgPath: 'assets/icons/icon_avatar.svg',
            bottomLeftRadius: 0,
            bottomRightRadius: 20,
            color: Color(0xFFF7FAFE),
          ),

          const SizedBox(height: 12),

          ChatTextComponent(text: "สวัสดีครับ", isChatRight: true),

          const SizedBox(height: 12),

          ChatTextComponent(
            text: "สำเร็จ!",
            description: "กรุณากรอกวันที่ออกเดตของคุณในปฏิทิน",
            color: AppColors.badgeSecondaryBg,
            colorDescription: AppColors.successText,
            svgPath: 'assets/icons/icon_bot.svg',
            bottomLeftRadius: 0,
            bottomRightRadius: 20,
            isContentMiddle: true,
          ),

          const SizedBox(height: 12),

          ChatTextComponent(
            isContentMiddle: true,
            text: "เสียใจด้วย!",
            color: AppColors.badgeErrorBg,
            subDescription: "คุณทั้ง 2 คนความคิดเห็นไม่ตรงกัน",
            svgPath: 'assets/icons/icon_bot.svg',
            bottomLeftRadius: 0,
            bottomRightRadius: 20,
          ),

          const SizedBox(height: 12),

          ChatTextComponent(
            text: "คุณต้องการดำเนินการต่อหรือไม่?",
            color: AppColors.badgeWarning,
            actionButton: true,
            actionButtonText: "เริ่ม",
            description:
                "หมายเหตุ เมื่อกดเริ่มแล้วจะไม่สามารถกลับ\n"
                "มาเล่นอีกรอบได้ควรคุยหรือรอคู่ของคุณก่อน",
            subDescription: 'เหลือเวลาเริ่มใหม่ 24 ชั่วโมง',
            svgPath: 'assets/icons/icon_bot.svg',
            bottomLeftRadius: 0,
            bottomRightRadius: 20,
          ),

          const SizedBox(height: 12),

          ChatTextComponent(
            text: "คุณต้องการดำเนินการต่อหรือไม่?",
            color: AppColors.badgeWarning,
            actionButton: true,
            actionButtonText: "เริ่ม",
            description:
                "หมายเหตุ เมื่อกดเริ่มแล้วจะไม่สามารถกลับ\n"
                "มาเล่นอีกรอบได้ควรคุยหรือรอคู่ของคุณก่อน",
            subDescription: 'เหลือเวลาเริ่มใหม่ 24 ชั่วโมง',
            svgPath: 'assets/icons/icon_bot.svg',
            bottomLeftRadius: 0,
            bottomRightRadius: 20,
            isDisabled: true,
          ),

          const SizedBox(height: 12),

          ChatTextComponent(
            isContentMiddle: true,
            color: AppColors.badgeWarning,
            text: "สุ่มได้ไปเที่ยวที่ อควาเรียมบางแสน !!!",
            choice: true,
            firstChoiceText: "ไม่ไป",
            secondChoiceText: "ไป",
            description: "คุณอยากไปเที่ยว 'อความเรียมบางแสน' หรือไม่",
            subDescription: 'ตอบแล้ว 0/2',
            svgPath: 'assets/icons/icon_bot.svg',
            bottomLeftRadius: 0,
            bottomRightRadius: 20,
          ),

          const SizedBox(height: 24),

          const Text(
            "Loading",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          CircularLoading(percent: 0.2),
          CircularLoading(percent: 0.5),
          CircularLoading(percent: 0.9),

          const SizedBox(height: 24),

          const Text(
            "Spin",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          SpinDateComponent(
            prizes: [
              {'label': 'Coffee'},
              {'label': 'Pizza'},
              {'label': 'Movie'},
              {'label': 'Book'},
              {'label': 'Gift'},
              {'label': 'Ice-cream'},
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            "Input Chat",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          InputChatComponent(
            svgPath: 'assets/icons/icon_more-options.svg',
            svgPathLast: 'assets/icons/icon_send.svg',
          ),

          const SizedBox(height: 24),

          const Text(
            "Card chat",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          CardChatComponent(
            svgPath: 'assets/icons/icon_avatar.svg',
            title: 'Sassy',
            subtitle: 'Nuna',
          ),

          const SizedBox(height: 12),

          CardChatComponent(
            svgPath: 'assets/icons/icon_avatar.svg',
            title: 'Sassy',
            subtitle: 'Nuna',
            svgPathEnd: 'assets/icons/icon_unseen-message.svg',
          ),

          const SizedBox(height: 12),

          CardChatComponent(
            svgPath: 'assets/icons/icon_avatar.svg',
            title: 'Sassy',
            subtitle: 'Nuna',
            svgPathEnd: 'assets/icons/icon_new-white.svg',
          ),

          const SizedBox(height: 12),

          CardChatComponent(
            svgPath: 'assets/icons/icon_avatar.svg',
            title: 'Sassy',
            subtitle: 'Nuna',
            svgPathEnd: 'assets/icons/icon_new-white.svg',
            svgPathMiddle: 'assets/icons/icon_new-black.svg',
          ),

          const SizedBox(height: 12),

          CardChatComponent(
            svgPath: 'assets/icons/icon_avatar.svg',
            title: 'Sassy',
            subtitle: 'Nuna',
            colors: [AppColors.backgroundWhite],
          ),

          const SizedBox(height: 12),

          //Fuji
          DsTextField(
            label: 'Full name',
            required: true,
            hintText: 'John Appleseed',
            controller: _nameCtrl,
            prefixIcon: Icons.person_rounded,
          ),
          const SizedBox(height: 12),

          DsTextField(
            label: 'Phone',
            hintText: '+66 88-888-8888',
            enabled: false,
            controller: _phoneCtrl,
            prefixIcon: Icons.phone_rounded,
          ),
          const SizedBox(height: 12),

          DsTextField(
            label: 'Next step',
            required: true,
            controller: _nextCtrl,
            suffixIcon: Icons.arrow_forward_rounded,
            onSuffixTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Go next')));
            },
          ),
          const SizedBox(height: 12),

          DsTextField(
            label: 'Add item',
            required: true,
            controller: _addCtrl,
            suffixIcon: Icons.add_rounded,
          ),
          const SizedBox(height: 12),

          DsTextField(
            label: 'Select option',
            required: true,
            controller: _selectCtrl,
            suffixIcon: Icons.keyboard_arrow_down_rounded,
          ),
          const SizedBox(height: 16),

          const DsOtpField(
            label: 'Verification code',
            required: true,
            supportText: 'We’ve sent a 6-digit code to your phone.',
          ),

          const SizedBox(height: 24),

          // === Calendar ===
          CalendarCard(
            initialMonth: DateTime(2026, 1, 1),
            initialTime: const TimeOfDay(hour: 12, minute: 0),
            accentColor: const Color(0xFFFF6B81),
            onClose: () => Navigator.of(context).maybePop(),
            onSave: (date, time) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Saved: $date (${time.format(context)})'),
                ),
              );
            },
          ),

          // === Status Bars ===
          const SizedBox(height: 24),
          Text('Status Bars', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Container(
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
                ScoreRow(
                  heartAsset: 'assets/icons/icon_heart_status.svg',
                  segments: [
                    ProgressSegment(percent: 0.27, color: Color(0xFFFF8FB3)),
                    ProgressSegment(percent: 0.34, color: Color(0xFFFFD166)),
                  ],
                ),
                SizedBox(height: 12),
                ScoreRow(
                  heartAsset: 'assets/icons/icon_heart_status.svg',
                  segments: [
                    ProgressSegment(percent: 0.35, color: Color(0xFFFF8FB3)),
                  ],
                ),
                SizedBox(height: 12),
                ScoreRow(
                  leading: ScoreLeading.number,
                  numberText: '1',
                  segments: [
                    ProgressSegment(percent: 0.50, color: Color(0xFFFF8FB3)),
                  ],
                ),
                SizedBox(height: 12),
                ScoreRow(
                  leading: ScoreLeading.number,
                  numberText: '2',
                  segments: [
                    ProgressSegment(percent: 0.74, color: Color(0xFFFF8FB3)),
                  ],
                ),
                SizedBox(height: 12),
                ScoreRow(
                  leading: ScoreLeading.none,
                  segments: [
                    ProgressSegment(
                      percent: 0.60,
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFFC8A2E7),
                          Color(0xFF9FBBFF),
                          Color(0xFFA7EAF2),
                          Color(0xFFB7E4C7),
                          Color(0xFFFFF1A8),
                          Color(0xFFFFD1A6),
                          Color(0xFFFFB3B3),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // === Buttons ===
          const SizedBox(height: 24),
          Text('Buttons', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              DsButton(
                label: 'Primary',
                onPressed: () {},
                variant: DsButtonVariant.primary,
                size: DsButtonSize.sm,
              ),
              DsButton(
                label: 'Primary (disabled)',
                onPressed: null,
                variant: DsButtonVariant.primary,
              ),
              DsButton(
                label: 'Error',
                onPressed: () {},
                variant: DsButtonVariant.error,
              ),
              DsButton(
                label: 'Error (disabled)',
                onPressed: null,
                variant: DsButtonVariant.error,
              ),
              DsButton(
                label: 'Secondary',
                onPressed: () {},
                variant: DsButtonVariant.secondary,
              ),
              DsButton(
                label: 'Secondary (disabled)',
                onPressed: null,
                variant: DsButtonVariant.secondary,
              ),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            'Accent (Outline / Filled)',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              DsButton(
                label: 'Accent Outline',
                onPressed: () {},
                variant: DsButtonVariant.accentOutline,
              ),
              DsButton(
                label: 'Accent Filled',
                onPressed: () {},
                variant: DsButtonVariant.accentFilled,
              ),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            'Outline Primary',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              DsButton(
                label: 'Outline (SM)',
                onPressed: () {},
                variant: DsButtonVariant.outlinePrimary,
                size: DsButtonSize.sm,
              ),
              DsButton(
                label: 'Outline (MD)',
                onPressed: () {},
                variant: DsButtonVariant.outlinePrimary,
                size: DsButtonSize.md,
              ),
              DsButton(
                label: 'Outline (LG)',
                onPressed: () {},
                variant: DsButtonVariant.outlinePrimary,
                size: DsButtonSize.lg,
              ),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            'With Icons + Full width',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DsButton(
                label: 'Continue',
                onPressed: () {},
                variant: DsButtonVariant.primary,
                leading: const Icon(Icons.play_arrow_rounded, size: 20),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: DsButton(
                  label: 'Next',
                  onPressed: () {},
                  variant: DsButtonVariant.accentFilled,
                  trailing: const Icon(Icons.arrow_forward_rounded, size: 20),
                ),
              ),
            ],
          ),

          // === SVG Icon Buttons (Hover Glow) ===
          const SizedBox(height: 24),
          Text(
            'SVG Icon Buttons (Hover Glow)',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),

          // กล่องเดโม 171x100: หัวใจ (filled) + กากบาท (outline)
          Container(
            width: 171,
            height: 100,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1, color: Color(0xFF8A38F5)),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 20,
                  top: 20,
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: DsIconButton.filled(
                      svgAsset: 'assets/icons/icon_heart_status.svg',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Heart tapped')),
                        );
                      },
                      size: 60,
                      radius: 999,
                      baseBg: const Color(0xFFFF6B81),
                      baseIcon: Colors.white,
                      hoverBg: const Color(0x14FF6B81),
                      hoverIcon: Colors.white,
                      hoverGlow: const [
                        BoxShadow(blurRadius: 16, color: Color(0x33FF6B81)),
                      ],
                      pressedBg: const Color(0x1FFF6B81),
                      pressedIcon: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  left: 91,
                  top: 20,
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: DsIconButton.outline(
                      svgAsset: 'assets/icons/close.svg',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Close tapped')),
                        );
                      },
                      size: 60,
                      radius: 999,
                      baseIcon: const Color(0xFF5CE1E6),
                      baseBorder: const Color(0xFF5CE1E6),
                      hoverBg: const Color(0x145CE1E6),
                      hoverIcon: const Color(0xFF5CE1E6),
                      hoverGlow: const [
                        BoxShadow(blurRadius: 16, color: Color(0x335CE1E6)),
                      ],
                      pressedBg: const Color(0x1F5CE1E6),
                      pressedIcon: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Row(
            children: [
              DsIconButton.filled(
                svgAsset: 'assets/icons/icon_heart_status.svg',
                onPressed: () {},
                size: 60,
                radius: 999,
                baseBg: const Color(0xFFFF6B81),
                baseIcon: Colors.white,
                hoverBg: const Color(0x14FF6B81),
                hoverIcon: Colors.white,
                hoverGlow: const [
                  BoxShadow(blurRadius: 16, color: Color(0x33FF6B81)),
                ],
                pressedBg: const Color(0x1FFF6B81),
                pressedIcon: Colors.white,
              ),
              const SizedBox(width: 12),
              DsIconButton.outline(
                svgAsset: 'assets/icons/close.svg',
                onPressed: () {},
                size: 60,
                radius: 999,
                baseIcon: const Color(0xFF5CE1E6),
                baseBorder: const Color(0xFF5CE1E6),
                hoverBg: const Color(0x145CE1E6),
                hoverIcon: const Color(0xFF5CE1E6),
                hoverGlow: const [
                  BoxShadow(blurRadius: 16, color: Color(0x335CE1E6)),
                ],
                pressedBg: const Color(0x1F5CE1E6),
                pressedIcon: Colors.white,
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }
}
