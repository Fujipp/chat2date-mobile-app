import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CardChatComponent extends StatelessWidget {
  final String? svgPath;
  final String? imagePath;
  final IconData? icon;
  final double? heightSvg;
  final Color? colorIcon;
  final double? widthSvg;
  final String? svgPathEnd;
  final String? imagePathEnd;
  final IconData? iconEnd;
  final double? heightSvgEnd;
  final Color? colorIconEnd;
  final double? widthSvgEnd;
  final List<Color>? colors;
  final String title;
  final FontWeight titleWeight;
  final String subtitle;
  final FontWeight subtitleWeight;
  final String? svgPathMiddle;
  final String? imagePathMiddle;
  final IconData? iconMiddle;
  final double? heightSvgMiddle;
  final Color? colorIconMiddle;
  final double? widthSvgMiddle;
  final VoidCallback? onClick;

  const CardChatComponent({
    super.key,
    this.svgPath,
    this.imagePath,
    this.icon,
    this.heightSvg,
    this.widthSvg,
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
    this.heightSvgMiddle,
    this.widthSvgMiddle,
    this.colorIconMiddle,
    
    this.colors = const [Color(0xFF4FE3F7), Color(0xFFA4FBA6)],
    required this.title,
    required this.subtitle,
    this.titleWeight = FontWeight.w700,
    this.subtitleWeight = FontWeight.w700,
    this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick ?? () {},
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        height: 97,
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
                width: widthSvg,
                height: heightSvg,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(icon, color: colorIcon, size: heightSvg),
                ),
              ),
            if (svgPath != null)
              SvgPicture.asset(svgPath!, width: widthSvg, height: heightSvg),
            if (imagePath != null)
              Container(
                child: imagePath!.startsWith('http')
                    ? Image.network(
                        imagePath!,
                        width: widthSvg,
                        height: heightSvg,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        imagePath!,
                        width: widthSvg,
                        height: heightSvg,
                        fit: BoxFit.cover,
                      ),
              ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (iconMiddle != null)
                  SizedBox(
                    width: widthSvgMiddle,
                    height: heightSvgMiddle,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Icon(
                        iconMiddle,
                        color: colorIconMiddle,
                        size: heightSvgMiddle,
                      ),
                    ),
                  ),
                if (svgPathMiddle != null)
                  SvgPicture.asset(
                    svgPathMiddle!,
                    width: widthSvgMiddle,
                    height: heightSvgMiddle,
                  ),
                if (imagePathMiddle != null)
                  Container(
                    child: imagePathMiddle!.startsWith('http')
                        ? Image.network(
                            imagePathMiddle!,
                            width: widthSvgMiddle,
                            height: heightSvgMiddle,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            imagePathMiddle!,
                            width: widthSvgMiddle,
                            height: heightSvgMiddle,
                            fit: BoxFit.cover,
                          ),
                  ),
                SizedBox(
                  width: 222,
                  child: Text(
                    title,
                    style: TextStyle(
                      color: const Color(0xFF1F2024),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: titleWeight,
                    ),
                  ),
                ),
                SizedBox(
                  width: 186,
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white /* Light-Text-Secondary */,
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
