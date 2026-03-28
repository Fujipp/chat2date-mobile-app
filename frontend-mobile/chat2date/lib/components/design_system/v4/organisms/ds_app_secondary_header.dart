import 'package:chat2date/theme/app_assets.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'package:chat2date/theme/tokens/typography/body_text_styles.dart';
import 'package:chat2date/theme/tokens/typography/display_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum DsAppSecondaryHeaderVariant { base, baseText, chat1, chat2, chat3, chat4 }

class DsAppSecondaryHeader extends StatelessWidget {
  const DsAppSecondaryHeader({
    super.key,
    this.variant = DsAppSecondaryHeaderVariant.base,
    this.title = 'Text',
    this.name = 'Name',
    this.avatarImage,
    this.cooldownText = '7',
    this.onBackTap,
    this.onPrimaryActionTap,
    this.onSecondaryActionTap,
    this.onTertiaryActionTap,
  });

  final DsAppSecondaryHeaderVariant variant;
  final String title;
  final String name;
  final ImageProvider<Object>? avatarImage;
  final String cooldownText;
  final VoidCallback? onBackTap;
  final VoidCallback? onPrimaryActionTap;
  final VoidCallback? onSecondaryActionTap;
  final VoidCallback? onTertiaryActionTap;

  bool get _showsCenter => variant != DsAppSecondaryHeaderVariant.base;

  bool get _showsAvatar =>
      variant == DsAppSecondaryHeaderVariant.chat1 ||
      variant == DsAppSecondaryHeaderVariant.chat2 ||
      variant == DsAppSecondaryHeaderVariant.chat3 ||
      variant == DsAppSecondaryHeaderVariant.chat4;

  bool get _showsRightSide =>
      variant == DsAppSecondaryHeaderVariant.chat1 ||
      variant == DsAppSecondaryHeaderVariant.chat2 ||
      variant == DsAppSecondaryHeaderVariant.chat3 ||
      variant == DsAppSecondaryHeaderVariant.chat4;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 85,
      width: double.infinity,
      child: Row(
        children: [
          SizedBox(
            width: variant == DsAppSecondaryHeaderVariant.base ? 79 : 90,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _TapTarget(
                onTap: onBackTap,
                child: SvgPicture.asset(
                  AppAssets.headerSecondaryBack,
                  width: 40,
                  height: 40,
                ),
              ),
            ),
          ),
          if (_showsCenter)
            Expanded(child: Center(child: _buildCenterContent())),
          if (_showsRightSide)
            SizedBox(
              width: 90,
              child: Align(
                alignment: Alignment.centerRight,
                child: _buildActions(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCenterContent() {
    final bool isBaseText = variant == DsAppSecondaryHeaderVariant.baseText;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showsAvatar) ...[_buildAvatar(), const SizedBox(height: 4)],
          Text(
            _showsAvatar ? name : title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: isBaseText
                ? AppDisplayTextStyles.h3.copyWith(
                    color: AppColors.textBlack,
                  )
                : AppBodyTextStyles.body.copyWith(
                    color: AppColors.textBlack,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 50,
      height: 50,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: avatarImage != null
          ? DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(image: avatarImage!, fit: BoxFit.cover),
              ),
            )
          : SvgPicture.asset(
              AppAssets.headerSecondaryAvatar,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
    );
  }

  Widget _buildActions() {
    switch (variant) {
      case DsAppSecondaryHeaderVariant.chat1:
        return _TapTarget(
          onTap: onPrimaryActionTap,
          child: SvgPicture.asset(
            AppAssets.headerSecondaryChat1Actions,
            width: 25,
            height: 27,
          ),
        );
      case DsAppSecondaryHeaderVariant.chat2:
        return _TapTarget(
          onTap: onPrimaryActionTap,
          child: SvgPicture.asset(
            AppAssets.headerSecondaryChat2Actions,
            width: 90,
            height: 33,
          ),
        );
      case DsAppSecondaryHeaderVariant.chat3:
        return _TapTarget(
          onTap: onPrimaryActionTap,
          child: SvgPicture.asset(
            AppAssets.headerSecondaryChat3Actions,
            width: 94.75,
            height: 33,
          ),
        );
      case DsAppSecondaryHeaderVariant.chat4:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TapTarget(
              onTap: onPrimaryActionTap,
              child: SvgPicture.asset(
                AppAssets.headerSecondaryChat4LeftAction,
                width: 19,
                height: 21.11,
              ),
            ),
            const SizedBox(width: 10),
            _TapTarget(
              onTap: onSecondaryActionTap,
              child: SizedBox(
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
                      top: 8,
                      child: Text(
                        cooldownText,
                        textAlign: TextAlign.center,
                        style: AppBodyTextStyles.overline.copyWith(
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            _TapTarget(
              onTap: onTertiaryActionTap,
              child: SvgPicture.asset(
                AppAssets.headerSecondaryChat4RightAction,
                width: 25,
                height: 27,
              ),
            ),
          ],
        );
      case DsAppSecondaryHeaderVariant.base:
      case DsAppSecondaryHeaderVariant.baseText:
        return const SizedBox.shrink();
    }
  }
}

class _TapTarget extends StatelessWidget {
  const _TapTarget({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(padding: const EdgeInsets.all(4), child: child),
    );
  }
}
