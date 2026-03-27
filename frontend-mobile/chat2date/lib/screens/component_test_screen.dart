import 'package:chat2date/components/buttons/index.dart';
import 'package:chat2date/components/calendar/index.dart';
import 'package:chat2date/components/card/card_chat_component.dart';
import 'package:chat2date/components/card/generic_card.dart';
import 'package:chat2date/components/card/preference_card.dart';
import 'package:chat2date/components/chat/chat_text_component.dart';
import 'package:chat2date/components/chat/content_switcher.dart';
import 'package:chat2date/components/chat/input_chat_component.dart';
import 'package:chat2date/components/chat/spin_date_component.dart';
import 'package:chat2date/components/common/custom_range_slider.dart';
import 'package:chat2date/components/common/image_upload_grid.dart';
import 'package:chat2date/components/common/loading_component.dart';
import 'package:chat2date/components/common/modal_component.dart';
import 'package:chat2date/components/design_system/v4/controls/index.dart';
import 'package:chat2date/components/inputs/index.dart';
import 'package:chat2date/components/layout/header.dart';
import 'package:chat2date/components/layout/menu_bar.dart';
import 'package:chat2date/components/layout/responsive_container.dart';
// Status Bar components
import 'package:chat2date/components/status_bar/score_row.dart';
import 'package:chat2date/components/toasts/toast.dart';
import 'package:chat2date/theme/app_assets.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  int _v4SegmentedIndex = 0;
  double _v4SliderValue = 50;
  DsUserSelectorValue _v4UserSelectorValue = DsUserSelectorValue.single;

  // final int _counter = 0;

  String _otp = '';
  bool _submitting = false;
  RangeValues _selectedRange = const RangeValues(18, 100);
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController(text: '88-888-8888');
  final _nextCtrl = TextEditingController();
  final _addCtrl = TextEditingController();
  final _selectCtrl = TextEditingController();
  final _searchCtrl = TextEditingController(text: 'Text');
  final _messageCtrl = TextEditingController(text: 'Text');
  final _bioCtrl = TextEditingController(text: 'Text');
  final _levelCtrl = TextEditingController(text: '1'); // 0..3
  final _percentCtrl = TextEditingController(text: '60');
  String? _selectedRelationship = 'dating';

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/discovery');
        break;
      case 1:
        Navigator.pushNamed(context, '/chat');
        break;
      case 2:
        Navigator.pushNamed(context, '/profile');
        break;
      case 3:
        Navigator.pushNamed(context, '/settings');
        break;
    }
  }

  // ถ้าหน้าเป็น Stateless ให้แปลงเป็น Stateful ก่อนนะครับ

  Future<void> _verifyCode(String code) async {
    if (code.length != 6) return; // กันเคสเผลอกดก่อนครบ
    setState(() => _submitting = true);
    try {
      // TODO: เรียก API ตรวจสอบ OTP ของ Dev ตรงนี้
      // ตัวอย่างชั่วคราว:
      // await Future.delayed(const Duration(milliseconds: 600));
      debugPrint('Submit OTP: $code');
      // success handling...
    } catch (e, st) {
      debugPrint('Verify OTP error: $e\n$st');
      if (!mounted) return;
      Toast.show(
        context,
        type: ToastType.error,
        title: 'ผิดพลาด',
        message: 'ยืนยันรหัสล้มเหลว กรุณาลองอีกครั้ง',
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

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
          const SizedBox(height: 16),

          const Text(
            'V4 Controls',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          DsSegmentedSwitcher(
            items: const ['Section 1', 'Section 2'],
            selectedIndex: _v4SegmentedIndex,
            onChanged: (value) => setState(() => _v4SegmentedIndex = value),
          ),
          const SizedBox(height: 12),
          DsUserSelector(
            value: _v4UserSelectorValue,
            onChanged: (value) => setState(() => _v4UserSelectorValue = value),
          ),
          const SizedBox(height: 12),
          DsSlider(
            value: _v4SliderValue,
            onChanged: (value) => setState(() => _v4SliderValue = value),
          ),
          const SizedBox(height: 24),

          Toast(
            type: ToastType.info,
            title: 'Title',
            message: 'Description. Lorem ipsum dolor sit amet.',
            onClose: () {},
          ),
          Toast(
            type: ToastType.success,
            title: 'Title',
            message: 'Description. Lorem ipsum dolor sit amet.',
          ),
          Toast(
            type: ToastType.warning,
            title: 'Title',
            message: 'Description. Lorem ipsum dolor sit amet.',
          ),
          Toast(
            type: ToastType.error,
            title: 'Title',
            message: 'Description. Lorem ipsum dolor sit amet.',
          ),
          const SizedBox(height: 12),
          const Text(
            'Toast (Real Usage)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              DsButton(
                label: 'Show Info Toast (10s)',
                variant: DsButtonVariant.primary,
                onPressed: () => _showOverlayToast(
                  ToastType.info,
                  'ข้อมูล',
                  'ตัวอย่าง Toast แบบ overlay ปิดเองใน 10 วินาที',
                ),
              ),
              DsButton(
                label: 'Show Success Toast',
                variant: DsButtonVariant.secondary,
                onPressed: () => _showOverlayToast(
                  ToastType.success,
                  'สำเร็จ',
                  'บันทึกข้อมูลเรียบร้อย',
                ),
              ),
              DsButton(
                label: 'Show Warning Toast',
                variant: DsButtonVariant.outlinePrimary,
                onPressed: () => _showOverlayToast(
                  ToastType.warning,
                  'คำเตือน',
                  'โปรดตรวจสอบข้อมูลให้ถูกต้อง',
                ),
              ),
              DsButton(
                label: 'Show Error Toast',
                variant: DsButtonVariant.error,
                onPressed: () => _showOverlayToast(
                  ToastType.error,
                  'ผิดพลาด',
                  'เกิดข้อผิดพลาดในการบันทึกข้อมูล',
                ),
              ),
            ],
          ),
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
            leftIconPath: 'assets/icons/ui/icon_chat2date_full.svg',
            rightIconPath: 'assets/icons/ui/icon_menu.svg',
            iconColor: Color(0xFF5ce1e6),
            onBack: () {},
            onSettings: () {},
          ),
          SizedBox(height: 16),
          ChatToDateHeaderGradient(
            leftIconPath: 'assets/icons/ui/icon_chat2date_full.svg',
            rightIconPath: 'assets/icons/ui/icon_menu.svg',
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

          // const GpsMapAlert(),
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
            svgPath: 'assets/icons/ui/icon_done.svg',
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
            svgPath: 'assets/icons/ui/icon_warning.svg',
            heightSvg: 78,
            widthSvg: 77,
            topic: 'ติดคูลดาวน์การหาสถานที่เดต 7 วัน',
            description: 'สามารถกดที่          เพื่อดูข้อมูลเพิ่มเติมได้',
            spaceBottom: 15,
            spaceTop: 15,
          ),

          const SizedBox(height: 12),

          ModalComponent(
            svgPath: 'assets/icons/ui/icon_banning.svg',
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
            svgPath: 'assets/icons/ui/icon_good-ending.svg',
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
            svgPath: 'assets/icons/ui/icon_one-sided.svg',
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
            svgPath: 'assets/icons/ui/icon_bad-ending.svg',
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
            topic: 'ประเมินคู่เดตของคุณ',
            topicTop: true,
            description: 'คุณพึงพอใจกับคู่เดตของคุณหรือไม่',
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
            svgPath: 'assets/icons/ui/icon_star-rating.svg',
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
            svgPath: "assets/icons/ui/icon_seen.svg",
            size: 12,
            isMiddle: false,
          ),

          const SizedBox(height: 12),

          ChatTextComponent(
            text: 'hi kate!',
            svgPath: 'assets/icons/ui/icon_avatar.svg',
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
            svgPath: 'assets/icons/ui/icon_bot.svg',
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
            svgPath: 'assets/icons/ui/icon_bot.svg',
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
            svgPath: 'assets/icons/ui/icon_bot.svg',
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
            svgPath: 'assets/icons/ui/icon_bot.svg',
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
            svgPath: 'assets/icons/ui/icon_bot.svg',
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
            svgPath: 'assets/icons/ui/icon_more-options.svg',
            svgPathLast: 'assets/icons/ui/icon_send.svg',
          ),

          const SizedBox(height: 24),

          const Text(
            "Card chat",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          CardChatComponent(
            svgPath: 'assets/icons/ui/icon_avatar.svg',
            title: 'Sassy',
            subtitle: 'Nuna',
          ),

          const SizedBox(height: 12),

          CardChatComponent(
            svgPath: 'assets/icons/ui/icon_avatar.svg',
            title: 'Sassy',
            subtitle: 'Nuna',
            svgPathEnd: 'assets/icons/ui/icon_unseen-message.svg',
          ),

          const SizedBox(height: 12),

          CardChatComponent(
            svgPath: 'assets/icons/ui/icon_avatar.svg',
            title: 'Sassy',
            subtitle: 'Nuna',
            svgPathEnd: 'assets/icons/ui/icon_new-white.svg',
          ),

          const SizedBox(height: 12),

          CardChatComponent(
            svgPath: 'assets/icons/ui/icon_avatar.svg',
            title: 'Sassy',
            subtitle: 'Nuna',
            svgPathEnd: 'assets/icons/ui/icon_new-white.svg',
            svgPathMiddle: 'assets/icons/ui/icon_new-black.svg',
          ),

          const SizedBox(height: 12),

          CardChatComponent(
            svgPath: 'assets/icons/ui/icon_avatar.svg',
            title: 'Sassy',
            subtitle: 'Nuna',
            colors: [AppColors.backgroundWhite],
          ),

          const SizedBox(height: 24),

          const Text(
            "Inputs",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          const DsSearchBar(),
          const SizedBox(height: 12),

          DsSearchBar(
            controller: _searchCtrl,
            state: DsInputVisualState.typing,
          ),
          const SizedBox(height: 12),

          DsSearchBar(
            controller: _messageCtrl,
            state: DsInputVisualState.filled,
          ),
          const SizedBox(height: 16),

          DsTextField(
            label: 'Title',
            required: true,
            hintText: 'Placeholder',
            controller: _nameCtrl,
          ),
          const SizedBox(height: 12),

          DsTextField(
            label: 'Title',
            hintText: 'Text',
            controller: _messageCtrl,
            state: DsInputVisualState.typing,
          ),
          const SizedBox(height: 12),

          DsTextField(
            label: 'Title',
            hintText: '88-888-8888',
            controller: _phoneCtrl,
            unit: '+66',
            state: DsInputVisualState.filled,
            enabled: false,
          ),
          const SizedBox(height: 12),

          DsTextField(
            label: 'Title',
            hintText: 'Placeholder',
            controller: _addCtrl,
            required: true,
            suffix: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: SvgPicture.asset(
                AppAssets.v4InputSelectMarkerIcon,
                width: 20,
                height: 20,
              ),
            ),
          ),
          const SizedBox(height: 12),

          DsTextField(
            label: 'Title',
            hintText: 'Placeholder',
            controller: _selectCtrl,
            required: true,
            suffix: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: SvgPicture.asset(
                AppAssets.v4InputAddIcon,
                width: 14,
                height: 14,
              ),
            ),
          ),
          const SizedBox(height: 12),

          EditInputField(
            label: 'Text',
            prefixText: '+66',
            placeholder: '88-8888-8888',
            initialValue: '88-8888-8888',
          ),
          const SizedBox(height: 12),

          DsDropdownField<String>(
            label: 'Title',
            required: true,
            value: _selectedRelationship,
            items: const [
              DsDropdownItem(value: 'dating', label: 'Dating'),
              DsDropdownItem(value: 'friend', label: 'Friend'),
              DsDropdownItem(value: 'activity', label: 'Activity'),
            ],
            onChanged: (value) => setState(() => _selectedRelationship = value),
          ),
          const SizedBox(height: 12),

          const DsDropdownField<String>(
            label: 'Title',
            required: true,
            hintText: 'Placeholder',
            items: [
              DsDropdownItem(value: 'a', label: 'Dating'),
              DsDropdownItem(value: 'b', label: 'Friend'),
            ],
            state: DsInputVisualState.error,
            supportText: 'Support text',
            showSupportText: true,
          ),
          const SizedBox(height: 12),

          DsTextAreaField(
            label: 'Title',
            hintText: 'Placeholder',
            controller: _bioCtrl,
          ),
          const SizedBox(height: 12),

          const DsTextAreaField(
            label: 'Title',
            state: DsInputVisualState.error,
            supportText: 'Support text',
            showSupportText: true,
          ),
          const SizedBox(height: 16),

          DsOtpField(
            label: 'Text',
            required: true,
            supportText: 'Support text',
            onChanged: (v) => setState(() => _otp = v),
            onCompleted: (v) => _verifyCode(v),
          ),

          const SizedBox(height: 12),
          FilledButton(
            onPressed: (_otp.length == 6 && !_submitting)
                ? () => _verifyCode(_otp)
                : null,
            child: Text(_submitting ? 'Verifying…' : 'Verify'),
          ),

          const SizedBox(height: 24),

          const Text(
            "Calendar Card",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          // === Calendar ===
          CalendarCard(
            initialMonth: DateTime(2026, 1, 1),
            initialTime: const TimeOfDay(hour: 12, minute: 0),
            accentColor: const Color(0xFFFF6B81),
            onClose: (_) => Navigator.of(context).maybePop(),
            onSave: (date, time) {
              Toast.show(
                context,
                type: ToastType.success,
                title: 'บันทึกสำเร็จ',
                message: 'Saved: $date (${time.format(context)})',
              );
            },
          ),

          CalendarCard(
            initialMonth: DateTime(2026, 1, 1),
            initialTime: const TimeOfDay(hour: 12, minute: 0),
            accentColor: const Color(0xFFFF6B81),
            onClose: (_) => Navigator.of(context).maybePop(),
            onTrash: () {
              // TODO: เคลียร์ค่าที่ Dev อยากลบ เช่น วันที่/เวลา/สถานที่
              Toast.show(
                context,
                type: ToastType.info,
                title: 'เคลียร์แล้ว',
                message: 'ลบค่าที่เลือกเรียบร้อย',
                durationSeconds: 6,
              );
            },
            onSave: (date, time) {
              Toast.show(
                context,
                type: ToastType.success,
                title: 'บันทึกสำเร็จ',
                message: 'Saved: $date (${time.format(context)})',
              );
            },
          ),

          // === Status Bars ===
          const SizedBox(height: 24),

          const Text(
            "Status Bars",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // แถวกรอกค่า LEVEL และ %
                Row(
                  children: [
                    // LEVEL 0..3
                    Expanded(
                      child: DsTextField(
                        label: 'Level (0–3)',
                        required: true,
                        controller: _levelCtrl,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // % 0..100
                    Expanded(
                      child: DsTextField(
                        label: 'Percent (0–100)',
                        required: true,
                        controller: _percentCtrl,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // พรีวิวแบบไลฟ์ ตาม LEVEL และ %
                Builder(
                  builder: (context) {
                    // parse + clamp
                    int level = int.tryParse(_levelCtrl.text.trim()) ?? 0;
                    level = level.clamp(0, 3);

                    double pct = double.tryParse(_percentCtrl.text.trim()) ?? 0;
                    pct = (pct.clamp(0, 100)) / 100.0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // บรรทัด preview หลัก (ควบคุมด้วยช่องกรอก)
                        ScoreRow(
                          number: level, // 0 = ไม่โชว์เลขบนหัวใจ
                          basePercent: pct, // 0..1 ความยาวแถบ
                          overlayPercent:
                              0, // ถ้าอยากเด้งเพิ่ม/ลด ค่อยใส่ทีหลัง
                          overlayDirection: ChangeDirection.none,
                          heartSvg: 'assets/icons/ui/HEART_STATUS_BAR.svg',
                          rightSvg: 'assets/icons/ui/INFO_STATUS_BAR.svg',
                          barWidth: 255,
                          barHeight: 10,
                          leadingWidth: 25,
                          leadingHeight: 22,
                          rightIconSize: 20,
                        ),

                        const SizedBox(height: 12),

                        // ตัวอย่าง: เพิ่ม (เหลือง)
                        const ScoreRow(
                          number: 1,
                          basePercent: 0.27,
                          overlayPercent: 0.34,
                          overlayDirection: ChangeDirection.up,
                          heartSvg: 'assets/icons/ui/HEART_STATUS_BAR.svg',
                          rightSvg: 'assets/icons/ui/INFO_STATUS_BAR.svg',
                        ),
                        const SizedBox(height: 12),

                        // ตัวอย่าง: ลด (แดง) และซ่อนเลข (number=0)
                        const ScoreRow(
                          number: 0,
                          basePercent: 0.50,
                          overlayPercent: 0.20,
                          overlayDirection: ChangeDirection.down,
                          heartSvg: 'assets/icons/ui/HEART_STATUS_BAR.svg',
                          rightSvg: 'assets/icons/ui/INFO_STATUS_BAR.svg',
                        ),
                        const SizedBox(height: 12),

                        // ตัวอย่าง: เพิ่มเล็กน้อย
                        const ScoreRow(
                          number: 2,
                          basePercent: 0.74,
                          overlayPercent: 0.10,
                          overlayDirection: ChangeDirection.up,
                          heartSvg: 'assets/icons/ui/HEART_STATUS_BAR.svg',
                          rightSvg: 'assets/icons/ui/INFO_STATUS_BAR.svg',
                        ),
                        const SizedBox(height: 12),

                        // level = 3 → สีรุ้งอัตโนมัติ
                        const ScoreRow(
                          number: 3,
                          basePercent: 0.60,
                          overlayPercent: 0.0,
                          overlayDirection: ChangeDirection.none,
                          heartSvg: 'assets/icons/ui/HEART_STATUS_BAR.svg',
                          rightSvg: 'assets/icons/ui/INFO_STATUS_BAR.svg',
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // === Buttons ===
          const SizedBox(height: 24),

          const Text(
            "Buttons",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DsButton(
                label: 'text',
                onPressed: () {},
                variant: DsButtonVariant.primary,
              ),
              DsButton(
                label: 'text',
                onPressed: () {},
                variant: DsButtonVariant.primary,
                visualOverride: DsButtonVisualState.disabled,
              ),
              DsButton(
                label: 'text',
                onPressed: () {},
                variant: DsButtonVariant.primary,
                visualOverride: DsButtonVisualState.hover,
              ),
              DsButton(
                label: 'text',
                onPressed: () {},
                variant: DsButtonVariant.primary,
                visualOverride: DsButtonVisualState.pressed,
              ),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            'Outline Primary 231x40',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DsButton(
                label: 'text',
                onPressed: () {},
                variant: DsButtonVariant.outlinePrimary,
              ),
              DsButton(
                label: 'text',
                onPressed: () {},
                variant: DsButtonVariant.outlinePrimary,
                visualOverride: DsButtonVisualState.disabled,
              ),
              DsButton(
                label: 'text',
                onPressed: () {},
                variant: DsButtonVariant.outlinePrimary,
                visualOverride: DsButtonVisualState.hover,
              ),
              DsButton(
                label: 'text',
                onPressed: () {},
                variant: DsButtonVariant.outlinePrimary,
                visualOverride: DsButtonVisualState.pressed,
              ),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            'Mini Accept 100x40',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DsButton(
                label: 'text',
                onPressed: () {},
                variant: DsButtonVariant.secondary,
                size: DsButtonSize.sm,
              ),
              DsButton(
                label: 'text',
                onPressed: () {},
                variant: DsButtonVariant.secondary,
                size: DsButtonSize.sm,
                visualOverride: DsButtonVisualState.disabled,
              ),
              DsButton(
                label: 'text',
                onPressed: () {},
                variant: DsButtonVariant.secondary,
                size: DsButtonSize.sm,
                visualOverride: DsButtonVisualState.hover,
              ),
              DsButton(
                label: 'text',
                onPressed: () {},
                variant: DsButtonVariant.secondary,
                size: DsButtonSize.sm,
                visualOverride: DsButtonVisualState.pressed,
              ),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            'Mini Denied 100x40',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DsButton(
                label: 'text',
                onPressed: () {},
                variant: DsButtonVariant.error,
                size: DsButtonSize.sm,
              ),
              DsButton(
                label: 'text',
                onPressed: () {},
                variant: DsButtonVariant.error,
                size: DsButtonSize.sm,
                visualOverride: DsButtonVisualState.disabled,
              ),
              DsButton(
                label: 'text',
                onPressed: () {},
                variant: DsButtonVariant.error,
                size: DsButtonSize.sm,
                visualOverride: DsButtonVisualState.hover,
              ),
              DsButton(
                label: 'text',
                onPressed: () {},
                variant: DsButtonVariant.error,
                size: DsButtonSize.sm,
                visualOverride: DsButtonVisualState.pressed,
              ),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            'Reload / Setting / Exit',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DsButton(
                label: 'text',
                onPressed: () {},
                variant: DsButtonVariant.outlinePrimary,
                leadingSvgAsset: AppAssets.v4RefreshIcon,
                iconSize: 17,
              ),
              const SizedBox(height: 8),
              DsButton(
                label: 'text',
                onPressed: () {},
                variant: DsButtonVariant.outlinePrimary,
                leadingSvgAsset: AppAssets.v4SettingsIcon,
                iconSize: 20,
              ),
              const SizedBox(height: 8),
              DsButton(
                label: 'text',
                onPressed: () {},
                variant: DsButtonVariant.error,
                size: DsButtonSize.lg,
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

          // กล่อง HEART
          Container(
            width: 171,
            height: 100,
            clipBehavior: Clip.antiAlias,
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
                  child: DsSvgSwapButton(
                    assetA: 'assets/icons/ui/heart_normal.svg',
                    assetB: 'assets/icons/ui/heart_active.svg',
                    iconSize: 60, // จาก SVG ปกติ
                    activeIconSize: 77, // จาก SVG active
                    padding: 0,
                    onPressed: () {},
                  ),
                ),
                Positioned(
                  left: 91,
                  top: 20,
                  child: DsSvgSwapButton(
                    assetA: 'assets/icons/ui/heart_normal.svg',
                    assetB: 'assets/icons/ui/heart_active.svg',
                    iconSize: 60,
                    activeIconSize: 77,
                    padding: 0,
                    previewHoverLook: true, // โชว์ภาพแบบ active ตลอด
                    onPressed: null,
                  ),
                ),
              ],
            ),
          ),

          // กล่อง UNLIKE
          Container(
            width: 171,
            height: 100,
            clipBehavior: Clip.antiAlias,
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
                  child: DsSvgSwapButton(
                    assetA: 'assets/icons/ui/unlike_normal.svg',
                    assetB: 'assets/icons/ui/unlike_active.svg',
                    iconSize: 60, // จาก SVG ปกติ
                    activeIconSize: 80, // จาก SVG active
                    padding: 0,
                    onPressed: () {},
                  ),
                ),
                Positioned(
                  left: 91,
                  top: 20,
                  child: DsSvgSwapButton(
                    assetA: 'assets/icons/ui/unlike_normal.svg',
                    assetB: 'assets/icons/ui/unlike_active.svg',
                    iconSize: 60,
                    activeIconSize: 80,
                    padding: 0,
                    previewHoverLook: true,
                    onPressed: null,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),

          const Text('Card Preference'),

          PreferenceCard(
            title: 'สไตล์การท่องเที่ยว',
            backgroundColor: const Color(0xFFD6FFD6),
          ),

          const SizedBox(height: 16),

          const Text('Image Upload Grid'),

          ImageUploadGrid(
            onImagesChanged: (images) {
              print('จำนวนรูปที่เลือก: ${images.length}');
            },
          ),
          CustomRangeSlider(
            values: _selectedRange,
            min: 18,
            max: 100,
            // divisions: 82,
            onChanged: (RangeValues values) {
              setState(() {
                _selectedRange = values;
              });
            },
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 1,
        onTap: _onItemTapped,
      ),
    );
  }

  void _showOverlayToast(ToastType type, String title, String message) {
    final overlay = Overlay.of(context);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: Material(
                color: Colors.transparent,
                child: Toast(
                  type: type,
                  title: title,
                  message: message,
                  durationSeconds: 10,
                  autoDismiss: true,
                  showCountdown: true,
                  onClose: () {
                    entry.remove();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );

    overlay.insert(entry);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _nextCtrl.dispose();
    _addCtrl.dispose();
    _selectCtrl.dispose();
    _levelCtrl.dispose();
    _percentCtrl.dispose();
    super.dispose();
  }
}
