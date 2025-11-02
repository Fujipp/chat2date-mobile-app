import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CardChatComponent extends StatelessWidget {
  //path รูปแรก
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

    this.colors = const [AppColors.btnPrimary, AppColors.brandSecondary],
    required this.title,
    required this.subtitle,
    this.subtitleWeight = FontWeight.w700,
    this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    bool? isWhite = colors?.length == 1 && colors?[0] == AppColors.backgroundWhite;

    return GestureDetector(
      onTap: onClick ?? () {},
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        width: 310,
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
            if (icon != null)
              SizedBox(
                width: 40,
                height: 40,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(icon, color: colorIcon, size: 40),
                ),
              ),
            if (svgPath != null)
              SvgPicture.asset(svgPath!, width: 40, height: 40),
            if (imagePath != null)
              Container(
                child: imagePath!.startsWith('http')
                    ? Image.network(
                        imagePath!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        imagePath!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
              ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 2,
              children: [
                if (iconMiddle != null)
                  SizedBox(
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
                if (svgPathMiddle != null)
                  SvgPicture.asset(
                    svgPathMiddle!,
                    width: 24,
                    height: 24,
                  ),
                if (imagePathMiddle != null)
                  Container(
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
                SizedBox(
                  width: 222,
                  child: Text(
                    title,
                    style: TextStyle(
                      color:AppColors.btnTextPrimary,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(
                  width: 186,
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      color: isWhite ? AppColors.textNeutral : Colors.white/* Light-Text-Secondary */,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: subtitleWeight,
                      height: 1.33,
                      letterSpacing: 0.12,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (iconEnd != null)
              SizedBox(
                width: widthSvgEnd,
                height: heightSvgEnd,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(iconEnd, color: colorIconEnd, size: heightSvgEnd),
                ),
              ),
            if (svgPathEnd != null)
              SvgPicture.asset(
                svgPathEnd!,
                width: widthSvgEnd,
                height: heightSvgEnd,
              ),
            if (imagePathEnd != null)
              Container(
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
              ),
          ],
        ),
      ),
    );
  }
}
