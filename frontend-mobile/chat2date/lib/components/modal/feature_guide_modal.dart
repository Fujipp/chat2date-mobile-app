import 'package:chat2date/components/chat/input_chat_component.dart';
import 'package:chat2date/components/status_bar/score_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'package:chat2date/components/buttons/ds_button.dart';

class FeatureGuideModal extends StatefulWidget {
  const FeatureGuideModal({super.key});

  @override
  State<FeatureGuideModal> createState() => _FeatureGuideModalState();
}

class _FeatureGuideModalState extends State<FeatureGuideModal> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final List<_FeaturePageData> _pages = [
    _FeaturePageData(
      // ปรับขนาดไอคอน Chat2Date ให้ใหญ่ขึ้นเฉพาะหน้านี้
      iconSource: SvgPicture.asset(
        'assets/icons/ui/icon_chat2date_full.svg',
        width: 100, // เพิ่มขนาดจาก 60 เป็น 100
        height: 100,
        fit: BoxFit.contain,
      ),
      title: 'ยินดีต้อนรับสู่หน้าแชท',
      description:
          'ระบบความสัมพันธ์จะคำนวณจากการพูดคุยสม่ำเสมอ เพื่อปลดล็อกสิ่งใหม่ๆ ไปพร้อมกัน',
    ),
    _FeaturePageData(
      iconSource: InputChatComponent(
        svgPath: 'assets/icons/ui/icon_more-options.svg',
        svgPathLast: 'assets/icons/ui/icon_send.svg',
        leftIconColor: AppColors.surfaceLight,
        sendIconColor: null,
        sendIconBackgroundColor: null,
        isSendEnabled: false,
      ),
      title: 'ส่งข้อความ',
      description:
          'คุณสามารถส่งข้อความหาคู่เดตของคุณได้ตามจุดส่งข้อความที่กำหนดไว้',
    ),
    _FeaturePageData(
      iconSource: const FittedBox(
        fit: BoxFit.scaleDown,
        child: ScoreRow(
          basePercent: 0.75,
          number: 1,
          barWidth: 120, // ปรับความกว้างให้พอดี
        ),
      ),
      title: 'สะสมแต้มภารกิจ',
      description:
          'รักษาการคุยต่อเนื่อง และทำภารกิจรายวันเพื่อรับแต้มและอัปเกรดระดับหัวใจ สามารถดูรายละเอียดภารกิจหรือข้อมูลเพิ่มเติมได้ที่ปุ่ม "!" ข้างๆ แถบคะแนน',
    ),
    _FeaturePageData(
      iconSource: SvgPicture.asset(
        "assets/images/illustrations/question.svg",
        width: 50,
        height: 50,
      ),
      title: 'เกมทายใจ',
      description:
          'เกมนี้สามารถเล่นได้เมื่อคุยกันได้ถึงระดับหนึ่ง เป็นเกมที่ช่วยเสริมสร้างความสัมพันธ์ระหว่างคุณกับคู่เดต โดยการตอบคำถามเกี่ยวกับตัวคุณและคู่เดตของคุณ เพื่อเพิ่มคะแนนความสัมพันธ์',
    ),
    _FeaturePageData(
      iconSource: SvgPicture.asset(
        'assets/icons/ui/icon_spinwheel.svg',
        width: 50,
        height: 50,
      ),
      title: 'วงล้อสุ่ม',
      description:
          'สุ่มสถานที่ท่องเที่ยวนัดเดตสุดพิเศษที่ทั้งคู่จะต้องประทับใจ',
    ),
    _FeaturePageData(
      iconSource: SvgPicture.asset(
        'assets/icons/ui/icon_calendar.svg',
        width: 50,
        height: 50,
      ),
      title: 'ปฏิทินนัดเดต',
      description:
          'ตั้งเวลาและจัดการวันที่เดตเพื่อให้คุณและคู่ของคุณมีเวลาในการพบปะกันอย่างมีประสิทธิภาพ',
    ),
    _FeaturePageData(
      iconSource: SvgPicture.asset(
        'assets/icons/ui/icon_spinwheel_7.svg',
        width: 50,
        height: 50,
      ),
      title: 'วงล้อสุ่มไม่สามารถใช้งานได้ 7 วัน',
      description:
          'จะต้องรอ 7 วันหลังจากการใช้งานครั้งล่าสุดเพื่อใช้ฟีเจอร์นี้อีกครั้ง',
    ),
    _FeaturePageData(
      iconSource: SvgPicture.asset(
        'assets/icons/ui/icon_report.svg',
        width: 50,
        height: 50,
      ),
      title: 'รายงานปัญหา',
      description:
          'หากพบปัญหาใดๆ สามารถรายงานคู่เดตของคุณได้ทันทีผ่านฟีเจอร์รายงาน',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    bool isLastPage = _currentPage == _pages.length - 1;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          constraints: BoxConstraints(
            // ปรับความสูงให้กระชับขึ้นเพื่อป้องกัน Bottom Overflow
            maxHeight: MediaQuery.of(context).size.height * 0.58,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppColors.neutral900.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 8),

                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemBuilder: (context, index) => _buildPage(_pages[index]),
                  ),
                ),

                const SizedBox(height: 12),
                _buildIndicator(),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: DsButton(
                    label: isLastPage ? "เริ่มใช้งานเลย" : "ถัดไป",
                    onPressed: isLastPage
                        ? () => Navigator.pop(context)
                        : () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                    size: DsButtonSize.lg,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          'GUIDE BOOK',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 2,
            fontWeight: FontWeight.w800,
            color: AppColors.brandPrimary700,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 24,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.brandPrimary200,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildPage(_FeaturePageData data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // เพิ่มความสูงเป็น 110 เพื่อรองรับไอคอนหน้าแรกที่ใหญ่ขึ้น
        SizedBox(
          height: 110,
          child: Center(
            child: data.iconSource is String
                ? SvgPicture.asset(data.iconSource as String, width: 60)
                : data.iconSource as Widget,
          ),
        ),
        const SizedBox(height: 16), // ลดระยะห่างลงเล็กน้อยเพื่อให้สมดุล
        Text(
          data.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18, // ลดขนาดหัวใจหลัก
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            data.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13, // ลดขนาดฟอนต์เนื้อหา
              color: AppColors.textSecondary,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 20 : 8,
          height: 6, // ลดความสูง indicator
          decoration: BoxDecoration(
            color: _currentPage == index
                ? AppColors.brandPrimary
                : AppColors.nonSelected,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}

class _FeaturePageData {
  final dynamic iconSource;
  final String title;
  final String description;
  _FeaturePageData({
    required this.iconSource,
    required this.title,
    required this.description,
  });
}
