import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChatTextComponent extends StatelessWidget {
  //ข้อความ
  final String text;

  //การจัดเรียง content
  final bool isChatRight;
  final bool isContentMiddle;

  //สี content
  final Color? color;

  //ความมนของมุม
  final double? bottomLeftRadius;
  final double? bottomRightRadius;

  //path รูป
  final String? svgPath;
  final String? imagePath;
  final IconData? icon;
  final Color? colorIcon;

  //description + สี
  final String? description;
  final Color? colorDescription;

  //subdescription
  final String? subDescription;

  //มี choice
  final bool? choice;
  final String? firstChoiceText;
  final String? secondChoiceText;
  final VoidCallback? onFirstChoice;
  final VoidCallback? onSecondChoice;

  //มีปุ่ม action ปุ่มกดเดียว
  final bool? actionButton;
  final String? actionButtonText;
  final VoidCallback? actionClick;
  final bool? isDisabled;

  const ChatTextComponent({
    super.key,
    //ข้อความ
    required this.text,

    //การจัดเรียง content
    this.isChatRight = false,
    this.isContentMiddle = false,

    //ความมนของมุม
    this.bottomLeftRadius = 20,
    this.bottomRightRadius = 0,

    //สี content
    this.color = AppColors.surfaceMuted,

    //path รูป
    this.svgPath,
    this.imagePath,
    this.icon,
    this.colorIcon,

    //description + สี
    this.description,
    this.colorDescription = const Color(0xFF7A4D0B),

    //subdescription
    this.subDescription,

    //มี choice
    this.choice = false,
    this.firstChoiceText,
    this.secondChoiceText,
    this.onFirstChoice,
    this.onSecondChoice,

    //มีปุ่ม action ปุ่มกดเดียว
    this.actionButton = false,
    this.isDisabled = false,
    this.actionButtonText,
    this.actionClick,

  }) : assert(
         (svgPath != null) ^
             (icon != null && colorIcon != null) ^
             (imagePath != null) ^
             (svgPath == null && icon == null && imagePath == null),
         'ไม่จำเป็น แต่ถ้าจะใส่ต้องใส่ svgPath หรือ icon หรือ imagePath หรือ อย่างใดอย่างหนึ่ง แต่ห้ามใส่ทั้งสองพร้อมกัน ต้อง มี height width เสมอ',
       );

  @override
  Widget build(BuildContext context) {
    MainAxisAlignment alignment = isChatRight ? MainAxisAlignment.end : MainAxisAlignment.start;
    CrossAxisAlignment contentAlignment  = isContentMiddle ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    return Row(
      mainAxisAlignment: alignment,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (icon != null)
          SizedBox(
            width: 50,
            height: 50,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Icon(icon, color: colorIcon, size: 50),
            ),
          ),
        if (svgPath != null) SvgPicture.asset(svgPath!, width: 50, height: 50),
        if (imagePath != null)
          Container(
            child: imagePath!.startsWith('http')
                ? Image.network(
                    imagePath!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    imagePath!,
                    width: 50,
                    height: 50,
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
            color: isChatRight ? AppColors.surfaceLight : color,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(bottomLeftRadius!),
              bottomRight: Radius.circular(bottomRightRadius!),
            ),
          ),
          child: Column(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: contentAlignment,
            children: [
              Text(
                text, // header
                style: TextStyle(
                  color: isChatRight ? Colors.white : AppColors.textPrimary,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
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
                      fontSize: 10,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
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
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.error /* Light-Error */,
                      fontSize: 10,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 2.20,
                    ),
                  ),
                ),
              if (actionButton != false)
                GestureDetector(
                  onTap: isDisabled! ? null : (actionClick ?? () {}),
                  child: Container(
                    width: 227,
                    height: 40,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: isDisabled!
                          ? AppColors
                                .btnDisabledPrimary // สีตอน disable
                          : AppColors.btnActivePrimary, // สีปกติ
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
                            color: isDisabled!
                                ? Colors
                                      .white // สีตัวอักษรตอน disable
                                : Colors.white,
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
                          color: AppColors.error /* Light-Error */,
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
                          color: AppColors.brandSecondary /* Light-Secondary */,
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
            ],
          ),
        ),
      ],
    );
  }
}

class StatusTextComponent extends StatelessWidget {
  final String text;
  final Color textColor;
  final double textSize;
  final bool isMiddle;
  final IconData? icon;
  final Color? iconColor;
  final String? svgPath;
  final double? size;
  //isSeen

  const StatusTextComponent({
    super.key,
    required this.text,
    this.textColor = Colors.black,
    this.isMiddle = true,
    this.textSize = 14,
    this.icon,
    this.iconColor,
    this.size,
    this.svgPath,
  });

  @override
  Widget build(BuildContext context) {
    Alignment contentAlignment = isMiddle ? Alignment.topCenter : Alignment.topRight;

    return Align(
      alignment: contentAlignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: textSize,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Icon(
                icon,
                color: iconColor ?? Colors.black,
                size: size ?? 24,
              ),
            ),
          if (svgPath != null)
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: SvgPicture.asset(
                svgPath!,
                width: size ?? 24,
                height: size ?? 24,
              ),
            ),
        ],
      ),
    );
  }
}
