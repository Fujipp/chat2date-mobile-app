import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InputChatComponent extends StatelessWidget {
  final String? svgPath;
  final String? imagePath;
  final IconData? icon;
  final double? heightSvg;
  final Color? colorIcon;
  final double? widthSvg;
  final VoidCallback? onSend;
  final VoidCallback? onClick;
  final String? svgPathLast;
  final String? imagePathLast;
  final IconData? iconLast;
  final double? heightSvgLast;
  final Color? colorIconLast;
  final double? widthSvgLast;

  const InputChatComponent({
    super.key,
    this.svgPath,
    this.imagePath,
    this.icon,
    this.heightSvg,
    this.widthSvg,
    this.colorIcon,
    this.onSend,
    this.onClick,
    this.svgPathLast,
    this.imagePathLast,
    this.iconLast,
    this.heightSvgLast,
    this.widthSvgLast,
    this.colorIconLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      height: 72,
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (icon != null)
            GestureDetector(
              onTap: onClick,
              child: SizedBox(
                width: widthSvg,
                height: heightSvg,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(icon, color: colorIcon, size: heightSvg),
                ),
              ),
            )
          else if (svgPath != null)
            GestureDetector(
              onTap: onClick,
              child: SvgPicture.asset(
                svgPath!,
                width: widthSvg,
                height: heightSvg,
              ),
            )
          else if (imagePath != null)
            GestureDetector(
              onTap: onClick,
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
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'เขียนข้อความ',
                filled: true,
                fillColor: const Color(0xFFF6F9FC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: SizedBox(
                  width: 48,
                  height: 48,
                  child: GestureDetector(
                    onTap: onSend ?? () {},
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: Builder(
                        builder: (_) {
                          if (iconLast != null) {
                            return Icon(
                              iconLast,
                              size: heightSvgLast,
                              color: colorIconLast,
                            );
                          } else if (svgPath != null) {
                            return SvgPicture.asset(
                              svgPathLast!,
                              width: widthSvgLast,
                              height: heightSvgLast,
                            );
                          } else if (imagePathLast != null) {
                            return imagePathLast!.startsWith('http')
                                ? Image.network(
                                    imagePathLast!,
                                    width: widthSvgLast,
                                    height: heightSvgLast,
                                    fit: BoxFit.contain,
                                  )
                                : Image.asset(
                                    imagePathLast!,
                                    width: widthSvgLast,
                                    height: heightSvgLast,
                                    fit: BoxFit.contain,
                                  );
                          } else {
                            return const SizedBox();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}