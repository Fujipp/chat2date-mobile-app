import 'package:chat2date/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// Chat Header Variants ตาม Figma:
/// - Chat 1: Back + Avatar + Name + Flag (พื้นฐาน)
/// - Chat 2: Chat 1 + Calendar + Spinwheel + Heart (ไม่มี cooldown)
/// - Chat 3: Chat 2 + Cooldown number on spinwheel (enabled)
/// - Chat 4: Chat 3 แต่ spinwheel disabled (greyed)
enum ChatHeaderVariant {
  /// Chat 1: แค่ปุ่ม Back, Avatar, Name, Flag
  chat1,

  /// Chat 2: + Calendar, Spinwheel, Heart (ไม่มี cooldown number)
  chat2,

  /// Chat 3: + Cooldown number บน spinwheel (enabled, สีสัน)
  chat3,

  /// Chat 4: + Cooldown number บน spinwheel (disabled, สีเทา)
  chat4,
}

class Header extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final bool showCalendar;
  final bool showSpinwheel;
  final bool showSpinwait;
  final bool showFlag;
  final bool showOptions;
  final bool showHeart;
  final bool showAvatar;
  final bool showBorder;
  // Spinwheel cooldown (Chat 3/4)
  final bool showSpinCooldown;
  final int? cooldownDays;
  final bool isSpinCooldownEnabled;
  final bool calendarHasUnreadUpdate;
  // Variant for quick setup
  final ChatHeaderVariant? variant;
  final VoidCallback? onBack;
  final VoidCallback? onCalendar;
  final VoidCallback? onSettings;
  final VoidCallback? onFlag;
  final VoidCallback? onSpinwheel;

  const Header({
    super.key,
    required this.name,
    this.avatarUrl,
    this.showAvatar = true,
    this.showCalendar = false,
    this.showSpinwheel = false,
    this.showSpinwait = false,
    this.showSpinCooldown = false,
    this.cooldownDays,
    this.isSpinCooldownEnabled = true,
    this.calendarHasUnreadUpdate = false,
    this.showOptions = false,
    this.showFlag = false,
    this.showHeart = false,
    this.showBorder = true,
    this.variant,
    this.onBack,
    this.onCalendar,
    this.onSettings,
    this.onFlag,
    this.onSpinwheel,
  });

  /// Factory สร้าง Header จาก ChatHeaderVariant
  /// - Chat 1: Back + Avatar + Name + Report (พื้นฐาน)
  /// - Chat 2: + Calendar + Spinwheel (ไม่มี cooldown number) + Report
  /// - Chat 3: + Calendar + Spinwheel (มี cooldown number, enabled) + Report
  /// - Chat 4: + Calendar + Spinwheel (มี cooldown number, disabled) + Report
  factory Header.fromVariant({
    required ChatHeaderVariant variant,
    required String name,
    String? avatarUrl,
    int? cooldownDays,
    bool showCalendar = true,
    bool showFlag = true,
    bool calendarHasUnreadUpdate = false,
    VoidCallback? onBack,
    VoidCallback? onCalendar,
    VoidCallback? onSpinwheel,
    VoidCallback? onFlag,
    VoidCallback? onSettings,
    bool showBorder = false,
  }) {
    switch (variant) {
      case ChatHeaderVariant.chat1:
        // แค่ Back + Avatar + Name + Report
        return Header(
          name: name,
          avatarUrl: avatarUrl,
          showFlag: showFlag,
          showBorder: showBorder,
          variant: variant,
          calendarHasUnreadUpdate: calendarHasUnreadUpdate,
          onBack: onBack,
          onFlag: onFlag,
        );
      case ChatHeaderVariant.chat2:
        // + Calendar + Spinwheel (ไม่มี cooldown) + Report
        return Header(
          name: name,
          avatarUrl: avatarUrl,
          showCalendar: showCalendar,
          showSpinwheel: true,
          showFlag: showFlag,
          showBorder: showBorder,
          variant: variant,
          calendarHasUnreadUpdate: calendarHasUnreadUpdate,
          onBack: onBack,
          onCalendar: onCalendar,
          onSpinwheel: onSpinwheel,
          onFlag: onFlag,
        );
      case ChatHeaderVariant.chat3:
        // + Calendar + Spinwheel (มี cooldown, enabled) + Report
        return Header(
          name: name,
          avatarUrl: avatarUrl,
          showCalendar: showCalendar,
          showSpinCooldown: true,
          cooldownDays: cooldownDays ?? 7,
          isSpinCooldownEnabled: true,
          showFlag: showFlag,
          showBorder: showBorder,
          variant: variant,
          calendarHasUnreadUpdate: calendarHasUnreadUpdate,
          onBack: onBack,
          onCalendar: onCalendar,
          onSpinwheel: onSpinwheel,
          onFlag: onFlag,
        );
      case ChatHeaderVariant.chat4:
        // + Calendar + Spinwheel (มี cooldown, disabled) + Report
        return Header(
          name: name,
          avatarUrl: avatarUrl,
          showCalendar: showCalendar,
          showSpinCooldown: true,
          cooldownDays: cooldownDays ?? 7,
          isSpinCooldownEnabled: false,
          showFlag: showFlag,
          showBorder: showBorder,
          variant: variant,
          calendarHasUnreadUpdate: calendarHasUnreadUpdate,
          onBack: onBack,
          onCalendar: onCalendar,
          onFlag: onFlag,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ตาม Figma: Bar height 85px, width 310px (จะ scale ตาม screen)
    // Left: 79px (back), Center: 110px (avatar+name), Right: 90px (icons)
    return Container(
      height: 85,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: showBorder
            ? Border(bottom: BorderSide(color: Colors.grey[300]!))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Section - Back button (79px width area, icon 45x45)
          SizedBox(
            width: 79,
            height: 45,
            child: Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: onBack ?? () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(22.5),
                child: SvgPicture.asset(
                  'assets/icons/ui/icon_arrow-back-circle.svg',
                  width: 45,
                  height: 45,
                ),
              ),
            ),
          ),
          // Center Section - Avatar + Name (110px width)
          SizedBox(
            width: 110,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showAvatar)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: avatarUrl != null
                        ? Image.network(avatarUrl!, fit: BoxFit.cover)
                        : const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 32,
                          ),
                  ),
                if (showAvatar) const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                    fontFamily: 'Inter',
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Right Section - Icons (90px width area)
          SizedBox(
            width: 90,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (showCalendar) ...[
                  _CalendarIcon(
                    onTap: onCalendar,
                    showUnreadDot: calendarHasUnreadUpdate,
                  ),
                  const SizedBox(width: 10),
                ],
                if (showSpinwheel) ...[
                  InkWell(
                    onTap: onSpinwheel,
                    child: SvgPicture.asset(
                      'assets/icons/ui/icon_spinwheel.svg',
                      width: 25,
                      height: 25,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                if (showSpinwait) ...[
                  InkWell(
                    onTap: onSpinwheel,
                    child: SvgPicture.asset(
                      'assets/icons/ui/icon_spinwheel_7.svg',
                      width: 25,
                      height: 25,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                if (showSpinCooldown && cooldownDays != null) ...[
                  _CooldownSpinwheelIcon(
                    days: cooldownDays!,
                    enabled: isSpinCooldownEnabled,
                    onTap: isSpinCooldownEnabled ? onSpinwheel : null,
                  ),
                  const SizedBox(width: 10),
                ],
                if (showFlag)
                  InkWell(
                    onTap: onFlag,
                    child: SvgPicture.asset(
                      'assets/icons/ui/icon_report.svg',
                      width: 25,
                      height: 20,
                    ),
                  ),
                if (showHeart) ...[
                  if (showFlag ||
                      showCalendar ||
                      showSpinwheel ||
                      showSpinCooldown)
                    const SizedBox(width: 10),
                  InkWell(
                    onTap: onSettings,
                    child: SvgPicture.asset(
                      'assets/icons/ui/icon_heart_active.svg',
                      width: 25,
                      height: 25,
                    ),
                  ),
                ],
                if (showOptions)
                  InkWell(
                    onTap: onFlag,
                    child: const SizedBox(
                      width: 30,
                      height: 20,
                      child: Icon(
                        Icons.more_horiz,
                        size: 30,
                        color: AppColors.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarIcon extends StatelessWidget {
  final VoidCallback? onTap;
  final bool showUnreadDot;

  const _CalendarIcon({this.onTap, this.showUnreadDot = false});

  @override
  Widget build(BuildContext context) {
    final icon = SizedBox(
      width: 24,
      height: 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/icons/ui/icon_calendar.svg',
                width: 19,
                height: 21,
              ),
            ),
          ),
          if (showUnreadDot)
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
            )
        ],
      ),
    );

    if (onTap == null) {
      return icon;
    }

    return InkWell(onTap: onTap, child: icon);
  }
}

class _CooldownSpinwheelIcon extends StatelessWidget {
  final int days;
  final bool enabled;
  final VoidCallback? onTap;

  const _CooldownSpinwheelIcon({
    required this.days,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // ตาม Figma: width 25, height 31 (รวม cooldown number)
    final Widget icon = SizedBox(
      width: 25,
      height: 31,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Spinwheel icon
          Positioned(
            top: 0,
            child: SvgPicture.asset(
              'assets/icons/ui/icon_spinwheel.svg',
              width: 25,
              height: 25,
              colorFilter: enabled
                  ? null
                  : ColorFilter.mode(AppColors.textMuted, BlendMode.srcIn),
            ),
          ),
          // Cooldown number badge ที่ด้านบน
          Positioned(
            top: 13,
            left: days < 0 ? 10 : 9,
            child: Container(
              width: 7,
              height: 10,
              alignment: Alignment.center,
              child: Text(
                days.toString(),
                style: TextStyle(
                  color: enabled
                      ? const Color(0xFF6B7280)
                      : AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (!enabled || onTap == null) {
      return icon;
    }

    return InkWell(onTap: onTap, child: icon);
  }
}

class ChatToDateHeaderWhite extends StatelessWidget {
  final String leftIconPath;
  final String rightIconPath;
  final Color? iconColor;
  final VoidCallback? onSettings;
  final VoidCallback? onBack;

  const ChatToDateHeaderWhite({
    super.key,
    required this.leftIconPath,
    this.rightIconPath = "",
    this.iconColor,
    this.onSettings,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final Color svgColor = iconColor ?? AppColors.btnPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            child: SizedBox(
              width: 120,
              height: 40,
              child: SvgPicture.asset(
                leftIconPath,
                width: 120,
                height: 40,
                colorFilter: ColorFilter.mode(svgColor, BlendMode.srcIn),
                fit: BoxFit.contain,
              ),
            ),
          ),

          const Spacer(),

          if (rightIconPath.isNotEmpty)
            InkWell(
              onTap: onSettings,
              child: SizedBox(
                width: 24,
                height: 24,
                child: SvgPicture.asset(
                  rightIconPath,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(svgColor, BlendMode.srcIn),
                  fit: BoxFit.contain,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ChatToDateHeaderGradient extends StatelessWidget {
  final String leftIconPath;
  final String rightIconPath;
  final Color? iconColor;
  final VoidCallback? onSettings;
  final VoidCallback? onBack;

  const ChatToDateHeaderGradient({
    super.key,
    required this.leftIconPath,
    required this.rightIconPath,
    this.iconColor,
    this.onSettings,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final Color svgColor = iconColor ?? Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.btnPrimary, AppColors.brandSecondary],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.btnPrimary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            child: SizedBox(
              width: 120,
              height: 40,
              child: SvgPicture.asset(
                leftIconPath,
                width: 120,
                height: 40,
                colorFilter: ColorFilter.mode(svgColor, BlendMode.srcIn),
                fit: BoxFit.contain,
              ),
            ),
          ),

          const Spacer(),

          InkWell(
            onTap: onSettings,
            child: SizedBox(
              width: 24,
              height: 24,
              child: SvgPicture.asset(
                rightIconPath,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(svgColor, BlendMode.srcIn),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
