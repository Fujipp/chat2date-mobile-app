import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ModalComponent extends StatelessWidget {
  final String? svgPath;
  final String? imagePath;
  final String? imageName;
  final IconData? icon;
  final bool textOnly;
  final double heightSvg;
  final Color? colorIcon;
  final double widthSvg;
  final String topic;
  final bool? topicTop;
  final String? description;
  final double spaceTop;
  final double spaceBottom;
  final bool? choice;
  final String? firstChoiceText;
  final Color? firstChoiceColor;
  final String? secondChoiceText;
  final Color? secondChoiceColor;
  final bool? subDescription;
  final String? headingSubDescriptionText;
  final String? subDescriptionText;
  final double? headingSubDescriptionSize;
  final Color? headingSubDescriptionColor;
  final FontWeight headingSubDescriptionWeight;
  final bool? placeholder;
  final String? placeholderText;
  final VoidCallback? onFirstChoice;
  final VoidCallback? onSecondChoice;

  const ModalComponent({
    super.key,
    this.svgPath,
    this.imagePath,
    this.imageName,
    this.icon,
    this.colorIcon,
    this.textOnly = false,
    this.spaceTop = 0,
    this.spaceBottom = 0,
    this.choice = false,
    this.firstChoiceText,
    this.secondChoiceText,
    this.firstChoiceColor,
    this.secondChoiceColor,
    this.subDescription = false,
    this.subDescriptionText,
    this.headingSubDescriptionText,
    this.headingSubDescriptionSize = 12,
    this.headingSubDescriptionColor = const Color(0xFF7A4D0B),
    this.headingSubDescriptionWeight = FontWeight.w400,
    this.topicTop = false,
    this.placeholder = false,
    this.placeholderText,
    required this.heightSvg,
    required this.widthSvg,
    required this.topic,
    this.description,
    this.onFirstChoice,
    this.onSecondChoice,
  }) : assert(
         (svgPath != null && textOnly == false) ^
             (icon != null && colorIcon != null && textOnly == false) ^
             (imagePath != null && imageName != null && textOnly == false) ^
             (textOnly == true),
         'ต้องใส่ svgPath หรือ icon หรือ imagePath หรือ อย่างใดอย่างหนึ่ง แต่ห้ามใส่ทั้งสองพร้อมกัน ต้อง มี height width topic เสมอ',
       );

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.all(10),
        width: 310,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              strokeAlign: BorderSide.strokeAlignCenter,
              color: Colors.black.withOpacity(0.10),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          shadows: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 20,
              offset: Offset(20, 20),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          spacing: 15,
          mainAxisSize: MainAxisSize.min, // ขยายพอดี content
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (spaceTop != 0) SizedBox(height: spaceTop),
            if (topicTop != false)
              SizedBox(
                width: 310,
                child: Text(
                  topic,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary /* Light-Text-Primary */,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
            if (icon != null && textOnly == false)
              Container(
                width: widthSvg,
                height: heightSvg,
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(icon, color: colorIcon, size: heightSvg),
                ),
              ),
            if (svgPath != null && textOnly == false)
              SvgPicture.asset(svgPath!, width: widthSvg, height: heightSvg),
            if (imagePath != null && textOnly == false)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
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
                  SizedBox(
                    width: 100,
                    child: Text(
                      imageName!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary /* Light-Text-Primary */,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            if (topicTop != true)
              SizedBox(
                width: 310,
                child: Text(
                  topic,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary /* Light-Text-Primary */,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
            if (description != null)
              SizedBox(
                width: 310,
                child: Text(
                  description!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMuted /* text-muted */,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.67,
                  ),
                ),
              ),
            if (subDescription != false)
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: headingSubDescriptionText,
                      style: TextStyle(
                        color: headingSubDescriptionColor,
                        fontSize: headingSubDescriptionSize,
                        fontFamily: 'Inter',
                        fontWeight: headingSubDescriptionWeight,
                        height: 1.67,
                      ),
                    ),
                    if (placeholder == false)
                      TextSpan(
                        text: subDescriptionText,
                        style: TextStyle(
                          color: AppColors.textMuted /* text-muted */,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.67,
                        ),
                      ),
                    if (placeholder == true)
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          width: double.infinity,
                          height: 73,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: Color(0xFFC5C6CC),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                placeholderText!,
                                style: TextStyle(
                                  color: Color(0xFF8F9098),
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  height: 1.43,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            if (choice != false)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 15,
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
                              color: Colors.white /* Light-Text-Secondary */,
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
                              color: Colors.white /* Light-Text-Secondary */,
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
            if (spaceBottom != 0) SizedBox(height: spaceBottom),
          ],
        ),
      ),
    );
  }
}
