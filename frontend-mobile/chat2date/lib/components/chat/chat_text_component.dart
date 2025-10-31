import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChatTextComponent extends StatelessWidget {
  final String text;
  final MainAxisAlignment? mainAlignmentRow;
  final CrossAxisAlignment? crossAlignmentRow;
  final Color? color;
  final double? bottomLeftRadius;
  final double? bottomRightRadius;
  final String? svgPath;
  final String? imagePath;
  final IconData? icon;
  final double? heightSvg;
  final Color? colorIcon;
  final double? widthSvg;
  final double? horizontal;
  final double? vertical;
  final Color? colorText;
  final double? textSize;
  final FontWeight? textWeight;
  final String? description;
  final double? descriptionSize;
  final FontWeight? descriptionWeight;
  final Color? colorDescription;
  final String? subDescription;
  final Color? subDescriptionColor;
  final double? subDescriptionSize;
  final FontWeight? subDescriptionWeight;
  final MainAxisAlignment? mainAxisAlignmentContentColumn;
  final CrossAxisAlignment? crossAxisAlignmentContentColumn;
  final TextAlign subDescriptionAlignment;
  final bool? choice;
  final String? firstChoiceText;
  final Color? firstChoiceColor;
  final String? secondChoiceText;
  final Color? secondChoiceColor;
  final VoidCallback? onFirstChoice;
  final VoidCallback? onSecondChoice;
  final bool? actionButton;
  final String? actionButtonText;
  final double spaceContent;
  final Color? actionColor;
  final VoidCallback? actionClick;
  final Color? actionButtonTextColor;

  const ChatTextComponent({
    super.key,
    required this.text,
    this.mainAlignmentRow = MainAxisAlignment.end,
    this.crossAlignmentRow = CrossAxisAlignment.center,
    this.bottomLeftRadius = 20,
    this.bottomRightRadius = 0,
    this.color = const Color(0xFFFF8FB3),
    this.svgPath,
    this.imagePath,
    this.icon,
    this.heightSvg,
    this.widthSvg,
    this.colorIcon,
    this.horizontal = 16,
    this.vertical = 0,
    this.colorText = Colors.white,
    this.textSize = 12,
    this.textWeight = FontWeight.w400,
    this.description,
    this.descriptionSize = 12,
    this.descriptionWeight = FontWeight.w400,
    this.colorDescription = const Color(0xFF7A4D0B),
    this.subDescription,
    this.subDescriptionColor = const Color(0xFFFF6B6B),
    this.subDescriptionSize = 10,
    this.subDescriptionWeight = FontWeight.w400,
    this.mainAxisAlignmentContentColumn = MainAxisAlignment.start,
    this.crossAxisAlignmentContentColumn = CrossAxisAlignment.center,
    this.subDescriptionAlignment = TextAlign.center,
    this.choice = false,
    this.firstChoiceText,
    this.secondChoiceText,
    this.firstChoiceColor,
    this.secondChoiceColor,
    this.onFirstChoice,
    this.onSecondChoice,
    this.actionButton = false,
    this.actionButtonText,
    this.spaceContent = 5,
    this.actionClick,
    this.actionColor = const Color(0xFF5CE1E6),
    this.actionButtonTextColor,
  }) : assert(
         (svgPath != null && widthSvg != null && heightSvg != null) ^
             (icon != null &&
                 colorIcon != null &&
                 widthSvg != null &&
                 heightSvg != null) ^
             (imagePath != null && widthSvg != null && heightSvg != null) ^
             (svgPath == null && icon == null && imagePath == null),
         'ไม่จำเป็น แต่ถ้าจะใส่ต้องใส่ svgPath หรือ icon หรือ imagePath หรือ อย่างใดอย่างหนึ่ง แต่ห้ามใส่ทั้งสองพร้อมกัน ต้อง มี height width เสมอ',
       );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontal!,
        vertical: vertical!,
      ),
      child: Row(
        mainAxisAlignment: mainAlignmentRow!,
        crossAxisAlignment: crossAlignmentRow!,
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
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            constraints:
                (description == null &&
                    subDescription == null &&
                    actionButton != true &&
                    choice != true)
                ? const BoxConstraints(maxWidth: 200)
                : const BoxConstraints(),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(bottomLeftRadius!),
                bottomRight: Radius.circular(bottomRightRadius!),
              ),
            ),
            child: Column(
              spacing: spaceContent,
              mainAxisAlignment: mainAxisAlignmentContentColumn!,
              crossAxisAlignment: crossAxisAlignmentContentColumn!,
              children: [
                Text(
                  text, // header
                  style: TextStyle(
                    color: colorText,
                    fontSize: textSize,
                    fontFamily: 'Inter',
                    fontWeight: textWeight,
                    height: 1.43,
                  ),
                ),
                if (description != null)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 4,
                    ), // ระยะห่างระหว่าง header กับ description
                    child: Text(
                      description!,
                      style: TextStyle(
                        color: colorDescription,
                        fontSize: descriptionSize,
                        fontFamily: 'Inter',
                        fontWeight: descriptionWeight,
                        height: 1.6,
                      ),
                    ),
                  ),
                if (subDescription != null)
                  SizedBox(
                    width: 227,
                    height: 20,
                    child: Text(
                      subDescription!,
                      textAlign: subDescriptionAlignment,
                      style: TextStyle(
                        color: subDescriptionColor /* Light-Error */,
                        fontSize: subDescriptionSize,
                        fontFamily: 'Inter',
                        fontWeight: subDescriptionWeight,
                        height: 2.20,
                      ),
                    ),
                  ),
                if (actionButton != false)
                  GestureDetector(
                    onTap: actionClick ?? () {},
                    child: Container(
                      width: 227,
                      height: 40,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: actionColor /* btn-bg-Primary */,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 8,
                        children: [
                          Text(
                            actionButtonText!,
                            style: TextStyle(
                              color: actionButtonTextColor /* Light-Text-Secondary */,
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (choice != false)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 32,
                    children: [
                      GestureDetector(
                        onTap: onFirstChoice,
                        child: Container(
                          width: 105,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color: firstChoiceColor /* Light-Error */,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 8,
                            children: [
                              Text(
                                firstChoiceText!,
                                style: TextStyle(
                                  color:
                                      Colors.white /* Light-Text-Secondary */,
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: onSecondChoice,
                        child: Container(
                          width: 105,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color: secondChoiceColor /* Light-Secondary */,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 8,
                            children: [
                              Text(
                                secondChoiceText!,
                                style: TextStyle(
                                  color:
                                      Colors.white /* Light-Text-Secondary */,
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StatusTextComponent extends StatelessWidget {
  final String text;
  final Alignment alignment;
  final Color color;
  final double textSize;
  final FontWeight textWeight;
  final double width;
  final double height;
  final IconData? icon;
  final Color? iconColor;
  final double? iconSize;
  final double? svgWidth;
  final double? svgHeight;
  final String? svgPath;
  final double? horizontal;
  final double? vertical;

  const StatusTextComponent({
    super.key,
    required this.text,
    required this.width,
    required this.height,
    this.color = Colors.black,
    this.alignment = Alignment.topCenter,
    this.textSize = 14,
    this.textWeight = FontWeight.w400,
    this.icon,
    this.iconColor,
    this.iconSize,
    this.svgHeight,
    this.svgWidth,
    this.svgPath,
    this.horizontal = 16,
    this.vertical = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontal!,
          vertical: vertical!,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // ขยายตาม content
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: textSize,
                fontFamily: 'Inter',
                fontWeight: textWeight,
              ),
            ),
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Icon(
                  icon,
                  color: iconColor ?? Colors.black,
                  size: iconSize ?? 24,
                ),
              ),
            if (svgPath != null)
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: SvgPicture.asset(
                  svgPath!,
                  width: svgWidth ?? 24,
                  height: svgHeight ?? 24,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
