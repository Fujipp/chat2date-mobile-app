import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Header extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final bool showCalendar;
  final bool showSpinwheel;
  final bool showSpinwait;
  final bool showFlag;
  final bool showOptions;
  final VoidCallback? onBack;
  final VoidCallback? onCalendar;
  final VoidCallback? onSettings;
  final VoidCallback? onFlag;

  const Header({
    super.key,
    required this.name,
    this.avatarUrl,
    this.showCalendar = false,
    this.showSpinwheel = false,
    this.showSpinwait = false,
    this.showOptions = false,
    this.showFlag = false,
    this.onBack,
    this.onCalendar,
    this.onSettings,
    this.onFlag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Avatar + Name อยู่กึ่งกลางเสมอ
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                backgroundImage: avatarUrl != null
                    ? NetworkImage(avatarUrl!)
                    : null,
                child: avatarUrl == null
                    ? const Icon(Icons.person, color: Colors.white, size: 30)
                    : null,
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          Positioned(
            left: 0,
            child: InkWell(
              onTap: onBack ?? () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.brandSecondary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),

          Positioned(
            right: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showCalendar) ...[
                  InkWell(
                    onTap: onCalendar,
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: SvgPicture.asset(
                        'assets/icons/icon_calendar.svg',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (showSpinwheel) ...[
                  InkWell(
                    onTap: onSettings,
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: SvgPicture.asset(
                        'assets/icons/icon_spinwheel.svg',
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (showSpinwait) ...[
                  InkWell(
                    onTap: onSettings,
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: SvgPicture.asset(
                        'assets/icons/icon_spinwheel_7.svg',
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (showFlag)
                  InkWell(
                    onTap: onFlag,
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: SvgPicture.asset(
                        'assets/icons/icon_report.svg',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                if (showOptions)
                  InkWell(
                    onTap: onFlag,
                    child: SizedBox(
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
            color: Colors.black.withOpacity(0.05),
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
                color: svgColor,
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
                color: svgColor,
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
            color: AppColors.btnPrimary.withOpacity(0.3),
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
                color: svgColor,
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
                color: svgColor,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
