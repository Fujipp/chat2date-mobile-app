import 'dart:ui';

import 'package:chat2date/components/design_system/buttons/index.dart';
import 'package:chat2date/components/design_system/inputs/index.dart';
import 'package:chat2date/core/theme/app_assets.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:chat2date/core/theme/tokens/typography/body_text_styles.dart';
import 'package:chat2date/core/theme/tokens/typography/display_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum DsActionModalDecoration { none, unlock }

class DsActionModal extends StatelessWidget {
  const DsActionModal({
    super.key,
    required this.title,
    this.description,
    this.topVisual,
    this.content,
    this.actions,
    this.width = 310,
    this.minHeight,
    this.decoration = DsActionModalDecoration.none,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    this.titleStyle,
  });

  final String title;
  final String? description;
  final Widget? topVisual;
  final Widget? content;
  final Widget? actions;
  final double width;
  final double? minHeight;
  final DsActionModalDecoration decoration;
  final EdgeInsets padding;
  final TextStyle? titleStyle;

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Close modal',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: ColoredBox(
                  color: AppColors.overlay.withValues(alpha: 0.18),
                ),
              ),
            ),
            Center(child: child),
          ],
        ),
      ),
      transitionBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (topVisual != null) topVisual!,
        if (topVisual != null) const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style:
              titleStyle ??
              AppDisplayTextStyles.subtitleBold.copyWith(
                color: AppColors.textBlack,
              ),
        ),
        if (description != null) ...[
          const SizedBox(height: 6),
          Text(
            description!,
            textAlign: TextAlign.center,
            style: AppBodyTextStyles.bodySmall.copyWith(
              color: AppColors.textSupport,
            ),
          ),
        ],
        if (content != null) ...[
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: Align(alignment: Alignment.center, child: content!),
          ),
        ],
        if (actions != null) ...[
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: Align(alignment: Alignment.center, child: actions!),
          ),
        ],
      ],
    );

    return Container(
      width: width,
      height: minHeight,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (decoration == DsActionModalDecoration.unlock) ...[
              Positioned(
                left: -40.5,
                top: -52.5,
                child: Container(
                  width: 119,
                  height: 117,
                  decoration: const BoxDecoration(
                    color: AppColors.brandPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: -18,
                top: -34.5,
                child: Container(
                  width: 83,
                  height: 82,
                  decoration: const BoxDecoration(
                    color: AppColors.brandPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
            Padding(
              padding: padding,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                        minWidth: constraints.maxWidth,
                      ),
                      child: Center(child: body),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DsModalInfoBox extends StatelessWidget {
  const DsModalInfoBox({
    super.key,
    this.heading,
    this.headingColor = AppColors.error,
    required this.lines,
  });

  final String? heading;
  final Color headingColor;
  final List<String> lines;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (heading != null)
            Text(
              heading!,
              style: AppBodyTextStyles.overline.copyWith(color: headingColor),
            ),
          if (heading != null) const SizedBox(height: 5),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                line,
                style: AppBodyTextStyles.overline.copyWith(
                  color: AppColors.textSupport,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DsChoiceModal extends StatelessWidget {
  const DsChoiceModal({
    super.key,
    required this.title,
    required this.description,
    required this.negativeLabel,
    required this.positiveLabel,
    this.onNegativePressed,
    this.onPositivePressed,
    this.negativeEnabled = true,
    this.positiveEnabled = true,
    this.topVisual,
    this.minHeight = 190,
  });

  final String title;
  final String description;
  final String negativeLabel;
  final String positiveLabel;
  final VoidCallback? onNegativePressed;
  final VoidCallback? onPositivePressed;
  final bool negativeEnabled;
  final bool positiveEnabled;
  final Widget? topVisual;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return DsActionModal(
      title: title,
      description: description,
      topVisual: topVisual,
      minHeight: minHeight,
      actions: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DsButton(
            label: negativeLabel,
            variant: DsButtonVariant.error,
            width: 100,
            size: DsButtonSize.xs,
            onPressed: negativeEnabled ? onNegativePressed ?? () {} : null,
          ),
          const SizedBox(width: 32),
          DsButton(
            label: positiveLabel,
            variant: DsButtonVariant.secondary,
            width: 100,
            size: DsButtonSize.xs,
            onPressed: positiveEnabled ? onPositivePressed ?? () {} : null,
          ),
        ],
      ),
    );
  }
}

class DsAvatarDecisionModal extends StatelessWidget {
  const DsAvatarDecisionModal({
    super.key,
    required this.title,
    required this.name,
    required this.description,
    required this.warningLines,
    required this.negativeLabel,
    required this.positiveLabel,
    this.avatar,
    this.avatarImage,
    this.onNegativePressed,
    this.onPositivePressed,
  });

  final String title;
  final String name;
  final String description;
  final List<String> warningLines;
  final String negativeLabel;
  final String positiveLabel;
  final Widget? avatar;
  final ImageProvider? avatarImage;
  final VoidCallback? onNegativePressed;
  final VoidCallback? onPositivePressed;

  @override
  Widget build(BuildContext context) {
    return DsActionModal(
      title: title,
      minHeight: 440,
      content: Column(
        children: [
          SizedBox(
            width: 100,
            child: Column(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: ClipOval(
                    child: avatarImage != null
                        ? Image(
                            image: avatarImage!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : avatar ??
                              SvgPicture.asset(
                                AppAssets.headerSecondaryAvatar,
                                fit: BoxFit.contain,
                              ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: AppBodyTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppBodyTextStyles.body.copyWith(
              color: AppColors.textSupport,
            ),
          ),
          const SizedBox(height: 10),
          DsModalInfoBox(heading: 'คำเตือน :', lines: warningLines),
        ],
      ),
      actions: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DsButton(
            label: negativeLabel,
            variant: DsButtonVariant.error,
            width: 100,
            onPressed: onNegativePressed ?? () {},
          ),
          const SizedBox(width: 32),
          DsButton(
            label: positiveLabel,
            variant: DsButtonVariant.secondary,
            width: 100,
            onPressed: onPositivePressed ?? () {},
          ),
        ],
      ),
    );
  }
}

class DsStarRating extends StatelessWidget {
  const DsStarRating({
    super.key,
    required this.value,
    required this.onChanged,
    this.count = 5,
    this.size = 35,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int count;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      children: List.generate(count, (index) {
        final itemValue = index + 1;
        final isActive = itemValue <= value;
        return GestureDetector(
          onTap: () => onChanged(itemValue),
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              Icons.star_rounded,
              size: size,
              color: isActive ? AppColors.warningIcon : const Color(0xFFD4D6DD),
            ),
          ),
        );
      }),
    );
  }
}

class DsRateAppModal extends StatelessWidget {
  const DsRateAppModal({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    required this.controller,
    this.onClose,
    this.onSubmit,
  });

  final int rating;
  final ValueChanged<int> onRatingChanged;
  final TextEditingController controller;
  final VoidCallback? onClose;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return DsActionModal(
      title: 'ให้คะแนนแอปเรา',
      minHeight: 320,
      content: Column(
        children: [
          DsStarRating(value: rating, onChanged: onRatingChanged),
          const SizedBox(height: 10),
          DsTextAreaField(
            label: 'อธิบายเพิ่มเติม',
            controller: controller,
            hintText: 'Placeholder',
            minLines: 3,
            maxLines: 3,
          ),
        ],
      ),
      actions: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DsButton(
            label: 'ปิด',
            variant: DsButtonVariant.error,
            width: 100,
            onPressed: onClose ?? () {},
          ),
          const SizedBox(width: 32),
          DsButton(
            label: 'ส่ง',
            variant: DsButtonVariant.secondary,
            width: 100,
            onPressed: onSubmit ?? () {},
          ),
        ],
      ),
    );
  }
}

class DsGuideBookPageData {
  const DsGuideBookPageData({
    required this.image,
    required this.title,
    required this.description,
  });

  final Widget image;
  final String title;
  final String description;
}

class DsGuideBookModal extends StatefulWidget {
  const DsGuideBookModal({super.key, required this.pages, this.onClose});

  final List<DsGuideBookPageData> pages;
  final VoidCallback? onClose;

  @override
  State<DsGuideBookModal> createState() => _DsGuideBookModalState();
}

class _DsGuideBookModalState extends State<DsGuideBookModal> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = widget.pages;
    final current = pages[_currentIndex];
    final isLast = _currentIndex == pages.length - 1;

    return DsActionModal(
      title: 'วิธีการใช้งานเบื้องต้น',
      minHeight: 380,
      content: Column(
        children: [
          SizedBox(
            width: 270,
            height: 155,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (_, index) => pages[index].image,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: current.title,
                  style: AppBodyTextStyles.bodySmallBold.copyWith(
                    color: AppColors.textSupport,
                  ),
                ),
                TextSpan(
                  text: '\n${current.description}',
                  style: AppBodyTextStyles.bodySmall.copyWith(
                    color: AppColors.textSupport,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: index == _currentIndex ? 11 : 5,
                height: 5,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: index == _currentIndex
                      ? AppColors.textBlack
                      : AppColors.divider,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: DsButton(
        label: isLast ? 'ปิด' : 'ถัดไป',
        variant: DsButtonVariant.primary,
        width: 231,
        onPressed: () {
          if (isLast) {
            widget.onClose?.call();
            return;
          }
          _pageController.nextPage(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
          );
        },
      ),
    );
  }
}

class DsDeleteAccountModal extends StatelessWidget {
  const DsDeleteAccountModal({
    super.key,
    required this.controller,
    this.onCancel,
    this.onConfirm,
  });

  final TextEditingController controller;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  bool get _canConfirm => controller.text.trim() == 'ลบบัญชี';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (_, __, ___) {
        return DsActionModal(
          minHeight: 380,
          topVisual: SizedBox(
            width: 78,
            height: 78,
            child: SvgPicture.asset(AppAssets.warningIcon, fit: BoxFit.contain),
          ),
          title: 'ลบบัญชีของคุณ',
          content: Column(
            children: [
              const DsModalInfoBox(
                heading: 'ข้อมูลสำคัญ',
                lines: [
                  '• บัญชีจะถูกระงับชั่วคราว',
                  '• สามารถกู้คืนได้ภายใน 30 วัน',
                  '• หลังจาก 30 วัน จะลบบัญชีถาวร',
                ],
              ),
              const SizedBox(height: 10),
              DsTextField(
                label: 'พิมพ์ “ลบบัญชี” เพื่อยืนยันการลบบัญชี',
                controller: controller,
                hintText: 'พิมพ์คำว่า “ลบบัญชี”',
              ),
            ],
          ),
          actions: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DsButton(
                label: 'ยกเลิก',
                variant: DsButtonVariant.error,
                width: 100,
                onPressed: onCancel ?? () {},
              ),
              const SizedBox(width: 32),
              DsButton(
                label: 'ยืนยัน',
                variant: DsButtonVariant.secondary,
                width: 100,
                onPressed: _canConfirm ? onConfirm ?? () {} : null,
              ),
            ],
          ),
        );
      },
    );
  }
}
