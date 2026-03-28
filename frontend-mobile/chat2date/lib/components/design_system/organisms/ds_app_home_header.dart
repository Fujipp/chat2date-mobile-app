import 'package:chat2date/theme/app_assets.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'package:chat2date/theme/tokens/typography/body_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DsAppHomeHeader extends StatelessWidget {
  const DsAppHomeHeader({
    super.key,
    this.title = 'Chat To Date',
    this.onActionTap,
    this.onBrandTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  final String title;
  final VoidCallback? onActionTap;
  final VoidCallback? onBrandTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: double.infinity,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: AppColors.background),
        child: Padding(
          padding: padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: onBrandTap,
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      AppAssets.headerHomeBrandmark,
                      width: 24.11,
                      height: 24.11,
                      fit: BoxFit.contain,
                      theme: const SvgTheme(currentColor: AppColors.surface),
                    ),
                    const SizedBox(width: 2.9),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppBodyTextStyles.captionBold.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.surface,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onActionTap,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: SvgPicture.asset(
                    AppAssets.headerHomeControls,
                    width: 16,
                    height: 16,
                    fit: BoxFit.contain,
                    theme: const SvgTheme(currentColor: AppColors.surface),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
