import 'package:chat2date/components/common/app_raw_scrollbar.dart';
import 'package:chat2date/components/design_system/organisms/ds_app_secondary_header.dart';
import 'package:chat2date/core/theme/app_assets.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:chat2date/core/theme/tokens/typography/body_text_styles.dart';
import 'package:chat2date/core/theme/tokens/typography/display_text_styles.dart';
import 'package:flutter/material.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  static const String routeName = '/about';

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            DsAppSecondaryHeader(
              variant: DsAppSecondaryHeaderVariant.baseText,
              title: 'เกี่ยวกับเรา',
              onBackTap: () => Navigator.pop(context),
              center: Text(
                'เกี่ยวกับเรา',
                style: AppDisplayTextStyles.h3.copyWith(
                  color: AppColors.textBlack,
                ),
              ),
              trailing: const SizedBox(width: 40, height: 40),
            ),
            Expanded(
              child: AppRawScrollbar(
                controller: _scrollController,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 358),
                      child: Column(
                        children: [
                          const SizedBox(height: 56),
                          Image.asset(
                            AppAssets.logo,
                            width: 250,
                            height: 250,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const FlutterLogo(size: 180),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            'Chat 2 Date',
                            style: AppDisplayTextStyles.h1Bold.copyWith(
                              color: AppColors.textBlack,
                              fontSize: 28,
                              height: 32 / 28,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'เวอร์ชั่น 3.0.1',
                            style: AppDisplayTextStyles.subtitle.copyWith(
                              color: AppColors.textSupport,
                            ),
                          ),
                          const SizedBox(height: 22),
                          const _AboutInfoCard(
                            child: Text(
                              'ชื่อ : แชททูเดต\nหมวดหมู่ : แอปพลิเคชันการหาคู่และการออกเดต',
                              style: TextStyle(
                                color: AppColors.textBlack,
                                fontSize: 14,
                                height: 20 / 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const _AboutInfoCard(
                            child: Text(
                              'ทีมพัฒนา :\nแอปพลิเคชันนี้ถูกสร้างมาเพื่อให้ผู้ใช้สามารถค้นหาคู่ที่เหมาะสมกับตนเอง ผ่านการแชทและเล่นมินิเกมสนุก ๆ โดยรักษาความปลอดภัยและความเป็นส่วนตัว',
                              style: TextStyle(
                                color: AppColors.textBlack,
                                fontSize: 14,
                                height: 20 / 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            '© 2025 Chat 2 Date. All rights reserved.',
                            textAlign: TextAlign.center,
                            style: AppDisplayTextStyles.subtitle.copyWith(
                              color: AppColors.textSupport,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutInfoCard extends StatelessWidget {
  const _AboutInfoCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: DefaultTextStyle(
        style: AppBodyTextStyles.body.copyWith(color: AppColors.textBlack),
        child: child,
      ),
    );
  }
}
