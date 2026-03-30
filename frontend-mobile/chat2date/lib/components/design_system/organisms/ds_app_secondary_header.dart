import 'package:chat2date/core/theme/app_assets.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:chat2date/core/theme/tokens/typography/body_text_styles.dart';
import 'package:chat2date/core/theme/tokens/typography/display_text_styles.dart';
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
    this.leading,
    this.center,
    this.trailing,
    this.cooldownText = '7',
    this.showCalendarAction = true,
    this.showCalendarUnreadDot = false,
    this.onBackTap,
    this.onCalendarActionTap,
    this.onPrimaryActionTap,
    this.onSecondaryActionTap,
    this.onTertiaryActionTap,
    this.backgroundColor = Colors.white,
    this.showBottomBorder = false,
    this.bottomBorderColor = const Color(0x260F172A),
    this.bottomBorderWidth = 1,
    this.bottomBorderSpacing = 8,
  });

  final DsAppSecondaryHeaderVariant variant;
  final String title;
  final String name;
  final ImageProvider<Object>? avatarImage;
  final Widget? leading;
  final Widget? center;
  final Widget? trailing;
  final String cooldownText;
  final bool showCalendarAction;
  final bool showCalendarUnreadDot;
  final VoidCallback? onBackTap;
  final VoidCallback? onCalendarActionTap;
  final VoidCallback? onPrimaryActionTap;
  final VoidCallback? onSecondaryActionTap;
  final VoidCallback? onTertiaryActionTap;
  final Color backgroundColor;
  final bool showBottomBorder;
  final Color bottomBorderColor;
  final double bottomBorderWidth;
  final double bottomBorderSpacing;

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
    final double leadingWidth =
        variant == DsAppSecondaryHeaderVariant.base ? 79 : 90;
    final double trailingWidth =
        variant == DsAppSecondaryHeaderVariant.base ? 0 : 102;
    final double screenWidth = MediaQuery.sizeOf(context).width;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 85,
          width: double.infinity,
          color: backgroundColor,
          child: Row(
            children: [
              SizedBox(
                width: leadingWidth,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: leading ?? _buildBackButton(),
                ),
              ),
              if (_showsCenter)
                Expanded(child: Center(child: _buildCenterContent())),
              if (trailingWidth > 0)
                SizedBox(
                  width: trailingWidth,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: trailing ?? _buildActions(),
                  ),
                ),
            ],
          ),
        ),
        if (showBottomBorder) ...[
          SizedBox(
            height: bottomBorderWidth,
            child: OverflowBox(
              minWidth: screenWidth,
              maxWidth: screenWidth,
              minHeight: bottomBorderWidth,
              maxHeight: bottomBorderWidth,
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: screenWidth,
                height: bottomBorderWidth,
                child: ColoredBox(
                  color: bottomBorderColor,
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          SizedBox(height: bottomBorderSpacing),
        ],
      ],
    );
  }

  Widget _buildCenterContent() {
    if (center != null) {
      return center!;
    }

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

  Widget _buildBackButton() {
    return _TapTarget(
      onTap: onBackTap,
      child: SvgPicture.asset(
        AppAssets.headerSecondaryBack,
        width: 40,
        height: 40,
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
    if (!_showsRightSide) {
      return const SizedBox.shrink();
    }

    final int cooldownValue = int.tryParse(cooldownText)?.clamp(1, 9) ?? 7;

    switch (variant) {
      case DsAppSecondaryHeaderVariant.chat1:
        return _buildActionSlots(
          right: _buildReportAction(onTap: onPrimaryActionTap),
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
        return _buildActionSlots(
          left: showCalendarAction ? _buildCalendarAction() : null,
          middle: _TapTarget(
            onTap: onSecondaryActionTap,
            padding: EdgeInsets.zero,
            child: SizedBox(
              width: 28,
              height: 28,
              child: Center(
                child: SvgPicture.asset(
                  AppAssets.headerSecondaryChat3CenterAction,
                  width: 28,
                  height: 28,
                ),
              ),
            ),
          ),
          right: _buildReportAction(),
        );
      case DsAppSecondaryHeaderVariant.chat4:
        return _buildActionSlots(
          left: showCalendarAction ? _buildCalendarAction() : null,
          middle: _TapTarget(
            onTap: onSecondaryActionTap,
            padding: EdgeInsets.zero,
            child: SizedBox(
              width: 28,
              height: 31,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    AppAssets.headerSecondaryChat4CenterAction,
                    width: 28,
                    height: 28,
                  ),
                  Positioned(
                    top: 6,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$cooldownValue',
                        textAlign: TextAlign.center,
                        style: AppBodyTextStyles.overline.copyWith(
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -2,
                    child: SvgPicture.asset(
                      AppAssets.headerSecondaryChat4CenterBadge,
                      width: 7,
                      height: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          right: _buildReportAction(),
        );
      case DsAppSecondaryHeaderVariant.base:
      case DsAppSecondaryHeaderVariant.baseText:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCalendarAction() {
    final icon = SizedBox(
      width: 28,
      height: 28,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: SvgPicture.asset(
                AppAssets.headerSecondaryChat4LeftAction,
                width: 28,
                height: 28,
              ),
            ),
          ),
          if (showCalendarUnreadDot)
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.4),
                ),
              ),
            ),
        ],
      ),
    );

    return _TapTarget(
      onTap: onCalendarActionTap ?? onPrimaryActionTap,
      padding: EdgeInsets.zero,
      child: icon,
    );
  }

  Widget _buildReportAction({VoidCallback? onTap}) {
    return _TapTarget(
      onTap: onTap ?? onTertiaryActionTap,
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: 28,
        height: 28,
        child: Center(
          child: SvgPicture.asset(
            AppAssets.reportIcon,
            width: 28,
            height: 28,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildActionSlots({
    Widget? left,
    Widget? middle,
    Widget? right,
  }) {
    return SizedBox(
      width: 102,
      height: 31,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: left == null ? null : Center(child: left),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 28,
            height: 31,
            child: middle == null ? null : Center(child: middle),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 28,
            height: 28,
            child: right == null ? null : Center(child: right),
          ),
        ],
      ),
    );
  }
}

class _TapTarget extends StatefulWidget {
  const _TapTarget({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(4),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  State<_TapTarget> createState() => _TapTargetState();
}

class _TapTargetState extends State<_TapTarget> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: widget.onTap != null
            ? (_) => setState(() => _pressed = true)
            : null,
        onTapUp: widget.onTap != null
            ? (_) => setState(() => _pressed = false)
            : null,
        onTapCancel: widget.onTap != null
            ? () => setState(() => _pressed = false)
            : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedSlide(
          offset: _pressed ? const Offset(0, -0.08) : Offset.zero,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: Padding(padding: widget.padding, child: widget.child),
        ),
      ),
    );
  }
}
