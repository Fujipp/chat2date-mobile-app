import 'package:chat2date/components/design_system/buttons/ds_button.dart';
import 'package:chat2date/components/design_system/controls/ds_level_progress_bar.dart';
import 'package:chat2date/core/theme/app_assets.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:chat2date/core/theme/tokens/typography/body_text_styles.dart';
import 'package:chat2date/core/theme/tokens/typography/display_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      title: 'ยินดีต้อนรับเข้าสู่หน้าแชท',
      description:
          'ระบบความสัมพันธ์จะคำนวณจากการพูดคุย\nสม่ำเสมอ เพื่อปลดล็อกสิ่งใหม่ๆ ไปพร้อมกัน',
      visual: const _FeatureIconFrame(
        assetPath: 'assets/icons/ui/icon_chat.svg',
      ),
    ),
    _FeaturePageData(
      title: 'ส่งข้อความ',
      description:
          'คุณสามารถส่งข้อความหาคู่เดตของคุณได้ตามจุดส่งข้อความที่กำหนดไว้',
      visual: const _FeatureVisualFrame(child: _MessageInputPreview()),
    ),
    _FeaturePageData(
      title: 'สะสมแต้มภารกิจ',
      description:
          'รักษาการคุยต่อเนื่อง และทำภารกิจรายวันเพื่อรับแต้มและอัปเกรดระดับหัวใจ สามารถดูรายละเอียดภารกิจหรือข้อมูลเพิ่มเติมได้ที่ปุ่ม "!" ข้างๆ แถบคะแนน',
      visual: const _FeatureVisualFrame(
        child: SizedBox(
          width: 220,
          child: DsLevelProgressBar(
            level: 1,
            progress: 0.75,
            width: 220,
            barWidth: 165,
          ),
        ),
      ),
    ),
    _FeaturePageData(
      title: 'เกมทายใจ',
      description:
          'เกมนี้สามารถเล่นได้เมื่อคุยกันได้ถึงระดับหนึ่ง เป็นเกมที่ช่วยเสริมสร้างความสัมพันธ์ระหว่างคุณกับคู่เดต โดยการตอบคำถามเกี่ยวกับตัวคุณและคู่เดตของคุณ เพื่อเพิ่มคะแนนความสัมพันธ์',
      visual: const _FeatureIconFrame(
        assetPath: AppAssets.questionIllustration,
      ),
    ),
    _FeaturePageData(
      title: 'วงล้อสุ่ม',
      description:
          'สุ่มสถานที่ท่องเที่ยวนัดเดตสุดพิเศษที่ทั้งคู่จะต้องประทับใจ',
      visual: const _FeatureVisualFrame(child: _SpinHeaderActionPreview()),
    ),
    _FeaturePageData(
      title: 'ปฏิทินนัดเดต',
      description:
          'ตั้งเวลาและจัดการวันที่เดตเพื่อให้คุณและคู่ของคุณมีเวลาในการพบปะกันอย่างมีประสิทธิภาพ',
      visual: const _FeatureVisualFrame(child: _CalendarHeaderActionPreview()),
    ),
    _FeaturePageData(
      title: 'วงล้อสุ่มไม่สามารถใช้งานได้ 7 วัน',
      description:
          'จะต้องรอ 7 วันหลังจากการใช้งานครั้งล่าสุดเพื่อใช้ฟีเจอร์นี้อีกครั้ง',
      visual: const _FeatureVisualFrame(child: _SpinCooldownHeaderPreview()),
    ),
    _FeaturePageData(
      title: 'รายงานปัญหา',
      description:
          'หากพบปัญหาใดๆ สามารถรายงานคู่เดตของคุณได้ทันทีผ่านฟีเจอร์รายงาน',
      visual: const _FeatureIconFrame(assetPath: AppAssets.reportIcon),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 310),
          child: Container(
            width: 310,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'วิธีการใช้งานเบื่องต้น',
                  textAlign: TextAlign.center,
                  style: AppDisplayTextStyles.subtitleBold.copyWith(
                    color: const Color(0xFF1F2024),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 240,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemBuilder: (context, index) =>
                        _FeaturePage(data: _pages[index]),
                  ),
                ),
                const SizedBox(height: 6),
                _FeatureGuideIndicator(
                  total: _pages.length,
                  currentIndex: _currentPage,
                ),
                const SizedBox(height: 18),
                DsButton(
                  label: isLastPage ? 'เริ่มใช้งานเลย' : 'ถัดไป',
                  onPressed: isLastPage
                      ? () => Navigator.of(context).pop()
                      : () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOut,
                        ),
                  size: DsButtonSize.lg,
                  width: 231,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturePageData {
  const _FeaturePageData({
    required this.title,
    required this.description,
    required this.visual,
  });

  final String title;
  final String description;
  final Widget visual;
}

class _FeaturePage extends StatelessWidget {
  const _FeaturePage({required this.data});

  final _FeaturePageData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 155, width: double.infinity, child: data.visual),
        const SizedBox(height: 14),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: AppBodyTextStyles.bodyBold.copyWith(
                    fontSize: 14,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: AppBodyTextStyles.bodySmall.copyWith(
                    color: AppColors.textSupport,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureGuideIndicator extends StatelessWidget {
  const _FeatureGuideIndicator({
    required this.total,
    required this.currentIndex,
  });

  final int total;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 2.5),
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: isActive ? AppColors.textBlack : AppColors.divider,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

class _FeatureVisualFrame extends StatelessWidget {
  const _FeatureVisualFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 155,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: Center(child: child),
      ),
    );
  }
}

class _FeatureIconFrame extends StatelessWidget {
  const _FeatureIconFrame({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return _FeatureVisualFrame(
      child: SvgPicture.asset(
        assetPath,
        width: 52,
        height: 52,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _MessageInputPreview extends StatelessWidget {
  const _MessageInputPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 40,
      padding: const EdgeInsets.only(left: 16, right: 6, top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(71),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'เขียนข้อความ',
          style: AppBodyTextStyles.body.copyWith(
            color: AppColors.textPlaceholder,
          ),
        ),
      ),
    );
  }
}

class _SpinHeaderActionPreview extends StatelessWidget {
  const _SpinHeaderActionPreview();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppAssets.headerSecondaryChat3CenterAction,
      width: 54,
      height: 66,
      fit: BoxFit.contain,
    );
  }
}

class _CalendarHeaderActionPreview extends StatelessWidget {
  const _CalendarHeaderActionPreview();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 60,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            AppAssets.headerSecondaryChat4LeftAction,
            width: 40,
            height: 44,
            fit: BoxFit.contain,
          ),
          Positioned(
            top: 5,
            right: 2,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.brandPrimary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpinCooldownHeaderPreview extends StatelessWidget {
  const _SpinCooldownHeaderPreview();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 25,
      height: 31,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            AppAssets.headerSecondaryChat4CenterAction,
            width: 25,
            height: 25,
          ),
          Positioned(
            top: -2,
            child: SvgPicture.asset(
              AppAssets.headerSecondaryChat4CenterBadge,
              width: 7,
              height: 10,
            ),
          ),
          Positioned(
            top: 6,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: AppColors.divider,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '7',
                textAlign: TextAlign.center,
                style: AppBodyTextStyles.overline.copyWith(
                  color: AppColors.textBlack,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
