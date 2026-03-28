import 'package:chat2date/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CardChatComponent extends StatelessWidget {
  //path รูปแรก (Avatar)
  final String? svgPath;
  final String? imagePath;
  final IconData? icon;
  final Color? colorIcon;

  //path รูปกลาง
  final String? svgPathMiddle;
  final String? imagePathMiddle;
  final IconData? iconMiddle;
  final Color? colorIconMiddle;

  //path รูปท้าย
  final String? svgPathEnd;
  final String? imagePathEnd;
  final IconData? iconEnd;
  final double? heightSvgEnd;
  final Color? colorIconEnd;
  final double? widthSvgEnd;

  // Unread message count (แสดง badge จำนวนข้อความใหม่)
  final int? unreadCount;

  // NEW badge สำหรับ Match ใหม่
  final bool isNewMatch;

  //color สี content
  final List<Color>? colors;

  //title
  final String title;

  //subtitle
  final String subtitle;
  final FontWeight? subtitleWeight;

  //เรียกใช้เมื่อกด
  final VoidCallback? onClick;

  const CardChatComponent({
    super.key,
    this.svgPath,
    this.imagePath,
    this.icon,
    this.colorIcon,
    this.svgPathEnd,
    this.imagePathEnd,
    this.iconEnd,
    this.heightSvgEnd,
    this.widthSvgEnd,
    this.colorIconEnd,
    this.svgPathMiddle,
    this.imagePathMiddle,
    this.iconMiddle,
    this.colorIconMiddle,
    this.unreadCount,
    this.isNewMatch = false,
    this.colors = const [AppColors.btnPrimary, AppColors.brandSecondary],
    required this.title,
    required this.subtitle,
    this.subtitleWeight = FontWeight.w700,
    this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    bool? isWhite =
        colors?.length == 1 && colors?[0] == AppColors.backgroundWhite;

    return GestureDetector(
      onTap: onClick ?? () {},
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        width: 330,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: (colors != null && colors!.length == 1) ? colors![0] : null,
          gradient: (colors != null && colors!.length > 1)
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: colors!,
                )
              : null,
        ),
        child: Row(
          children: [
            // รูปแรก (Avatar) - ใช้รูป User แบบวงกลม
            _buildAvatar(),
            const SizedBox(width: 16),

            // ส่วนกลาง (Text) - ใช้ Expanded เพื่อให้ยืดหยุ่น
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // รูปกลาง (ถ้ามี)
                  if (iconMiddle != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Icon(
                            iconMiddle,
                            color: AppColors.brandOnPrimary,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  if (svgPathMiddle != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: SvgPicture.asset(
                        svgPathMiddle!,
                        width: 24,
                        height: 24,
                      ),
                    ),
                  if (imagePathMiddle != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: imagePathMiddle!.startsWith('http')
                            ? Image.network(
                                imagePathMiddle!,
                                width: 24,
                                height: 24,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                imagePathMiddle!,
                                width: 24,
                                height: 24,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),

                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.btnTextPrimary,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),

                  // Subtitle
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isWhite ? AppColors.textNeutral : Colors.white,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: subtitleWeight,
                      height: 1.33,
                      letterSpacing: 0.12,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),

            // Badge แสดงสถานะ (unread count หรือ NEW)
            _buildBadge(),
          ],
        ),
      ),
    );
  }

  /// สร้าง Avatar แบบวงกลมพร้อมรูป User
  Widget _buildAvatar() {
    const double size = 48.0;

    // ถ้ามี imagePath ให้แสดงรูป User เป็นวงกลม
    if (imagePath != null && imagePath!.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isNewMatch ? AppColors.btnPrimary : Colors.white,
            width: isNewMatch ? 2.5 : 2.0,
          ),
          boxShadow: isNewMatch
              ? [
                  BoxShadow(
                    color: AppColors.btnPrimary.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: ClipOval(
          child: imagePath!.startsWith('http')
              ? Image.network(
                  imagePath!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildDefaultAvatar(size);
                  },
                )
              : Image.asset(
                  imagePath!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildDefaultAvatar(size);
                  },
                ),
        ),
      );
    }

    // ถ้ามี svgPath ให้แสดง SVG เป็นรูป user
    if (svgPath != null && svgPath!.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isNewMatch ? AppColors.btnPrimary : Colors.white,
            width: isNewMatch ? 2.5 : 2.0,
          ),
          boxShadow: isNewMatch
              ? [
                  BoxShadow(
                    color: AppColors.btnPrimary.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: ClipOval(
          child: svgPath!.startsWith('http')
              ? SvgPicture.network(
                  svgPath!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                )
              : SvgPicture.asset(
                  svgPath!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                ),
        ),
      );
    }

    // ถ้ามี icon ให้แสดง icon
    if (icon != null) {
      return SizedBox(
        width: size,
        height: size,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Icon(icon, color: colorIcon, size: size),
        ),
      );
    }

    // Default avatar
    return _buildDefaultAvatar(size);
  }

  /// สร้าง default avatar เมื่อไม่มีรูป
  Widget _buildDefaultAvatar(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.btnPrimary.withOpacity(0.2),
        border: Border.all(color: Colors.white, width: 2.0),
      ),
      child: Icon(
        Icons.person,
        size: size * 0.6,
        color: AppColors.btnPrimary,
      ),
    );
  }

  /// สร้าง Badge สำหรับ unread count หรือ NEW
  Widget _buildBadge() {
    // แสดง unread count badge
    if (unreadCount != null && unreadCount! > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFF4757),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF4757).withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          unreadCount! > 99 ? '99+' : unreadCount.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // แสดง NEW badge สำหรับ Match ใหม่
    if (isNewMatch) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B6B).withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Text(
          'ใหม่',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    // ถ้ามี icon/svg/image แบบเดิมให้แสดง
    if (iconEnd != null) {
      return SizedBox(
        width: widthSvgEnd,
        height: heightSvgEnd,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Icon(
            iconEnd,
            color: colorIconEnd,
            size: heightSvgEnd,
          ),
        ),
      );
    }

    if (svgPathEnd != null) {
      return SvgPicture.asset(
        svgPathEnd!,
        width: widthSvgEnd,
        height: heightSvgEnd,
      );
    }

    if (imagePathEnd != null) {
      return SizedBox(
        width: widthSvgEnd,
        height: heightSvgEnd,
        child: imagePathEnd!.startsWith('http')
            ? Image.network(
                imagePathEnd!,
                width: widthSvgEnd,
                height: heightSvgEnd,
                fit: BoxFit.cover,
              )
            : Image.asset(
                imagePathEnd!,
                width: widthSvgEnd,
                height: heightSvgEnd,
                fit: BoxFit.cover,
              ),
      );
    }

    // ไม่มี badge
    return const SizedBox.shrink();
  }
}
