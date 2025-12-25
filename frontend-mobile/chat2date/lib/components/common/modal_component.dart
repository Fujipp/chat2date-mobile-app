import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ModalComponent extends StatefulWidget {
  //รูป
  final String? svgPath;
  final String? imagePath;
  final String? imageName;
  final IconData? icon;
  final double? heightSvg;
  final Color? colorIcon;
  final double? widthSvg;
  final bool onRange;

  //โหมด text เท่านั้น
  final bool textOnly;

  //หัวเรื่อง กับ ทำให้หัวเรื่องอยู่หัวสุด
  final String topic;
  final bool? topicTop;

  //มี description
  final String? description;

  //space หัวท้ายเพื่อความสวยงาม
  final double spaceTop;
  final double spaceBottom;
  final double width;

  //มี choice
  final bool? choice;
  final String? firstChoiceText;
  final String? secondChoiceText;
  final VoidCallback? onFirstChoice;
  final VoidCallback? onSecondChoice;

  //มี subdescription
  final bool? subDescription;
  final String? headingSubDescriptionText;
  final Color? headingSubDescriptionColor;
  final FontWeight headingSubDescriptionWeight;
  final String? subDescriptionText;

  //มี placeholder
  final bool? placeholder;
  final String? placeholderText;

  const ModalComponent({
    super.key,

    //รูปและ title
    this.heightSvg,
    this.widthSvg,
    required this.topic,
    this.svgPath,
    this.imagePath,
    this.imageName,
    this.icon,
    this.colorIcon,
    this.onRange = false,

    //โหมดใส่ text เท่านั้น
    this.textOnly = false,

    //มี space หัวท้าย
    this.spaceTop = 0,
    this.spaceBottom = 0,
    this.width = 310,

    //มี choice
    this.choice = false,
    this.firstChoiceText,
    this.secondChoiceText,
    this.onFirstChoice,
    this.onSecondChoice,

    //มี subdescription ย่อยอีกที
    this.subDescription = false,
    this.subDescriptionText,
    this.headingSubDescriptionText,
    this.headingSubDescriptionColor = const Color(0xFF7A4D0B),
    this.headingSubDescriptionWeight = FontWeight.w400,

    //ทำให้ topic อยู่หัว
    this.topicTop = false,

    //มี placeholder
    this.placeholder = false,
    this.placeholderText,

    //มี description
    this.description,
  }) : assert(
         (svgPath != null && textOnly == false) ^
             (icon != null && colorIcon != null && textOnly == false) ^
             (imagePath != null && imageName != null && textOnly == false) ^
             (textOnly == true),
         'ต้องใส่ svgPath หรือ icon หรือ imagePath หรือ อย่างใดอย่างหนึ่ง แต่ห้ามใส่ทั้งสองพร้อมกัน ต้อง มี height width topic เสมอ',
       );

  @override
  State<ModalComponent> createState() => _ModalComponentState();
}

class _ModalComponentState extends State<ModalComponent> {
  RangeValues selectedRange = const RangeValues(0, 1800);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.all(10),
        width: widget.width,
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
            if (widget.spaceTop != 0) SizedBox(height: widget.spaceTop),
            if (widget.topicTop != false)
              SizedBox(
                width: 310,
                child: Text(
                  widget.topic,
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
            if (widget.icon != null && widget.textOnly == false)
              Container(
                width: widget.widthSvg,
                height: widget.heightSvg,
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(
                    widget.icon,
                    color: widget.colorIcon,
                    size: widget.heightSvg,
                  ),
                ),
              ),
            if (widget.svgPath != null && widget.textOnly == false)
              SvgPicture.asset(
                widget.svgPath!,
                width: widget.widthSvg,
                height: widget.heightSvg,
              ),
            if (widget.imagePath != null && widget.textOnly == false)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: widget.imagePath!.startsWith('http')
                        ? Image.network(
                            widget.imagePath!,
                            width: widget.widthSvg,
                            height: widget.heightSvg,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            widget.imagePath!,
                            width: widget.widthSvg,
                            height: widget.heightSvg,
                            fit: BoxFit.cover,
                          ),
                  ),
                  SizedBox(
                    width: 100,
                    child: Text(
                      widget.imageName!,
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
            if (widget.topicTop != true)
              SizedBox(
                width: 310,
                child: Text(
                  widget.topic,
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
            if (widget.description != null)
              SizedBox(
                width: 310,
                child: Text(
                  widget.description!,
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
            if (widget.subDescription != false)
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: widget.headingSubDescriptionText,
                      style: TextStyle(
                        color: widget.headingSubDescriptionColor,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: widget.headingSubDescriptionWeight,
                        height: 1.67,
                      ),
                    ),
                    if (widget.placeholder == false)
                      TextSpan(
                        text: widget.subDescriptionText,
                        style: TextStyle(
                          color: AppColors.textMuted /* text-muted */,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.67,
                        ),
                      ),
                    if (widget.placeholder == true)
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
                                widget.placeholderText!,
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
            if (widget.choice != false)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 15,
                children: [
                  GestureDetector(
                    onTap: widget.onFirstChoice,
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
                            widget.firstChoiceText!,
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
                    onTap: widget.onSecondChoice,
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
                            widget.secondChoiceText!,
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
            // if (widget.onRange == true)
            //   Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Text(
            //         '${selectedRange.start.round()}',
            //         style: const TextStyle(
            //           fontSize: 16,
            //           fontWeight: FontWeight.w500,
            //         ),
            //       ),
            //       Text(
            //         '${selectedRange.end.round()}',
            //         style: const TextStyle(
            //           fontSize: 16,
            //           fontWeight: FontWeight.w500,
            //         ),
            //       ),
            //     ],
            //   ),
            // if (widget.onRange == true) const SizedBox(height: 10),
            // if (widget.onRange == true)
            //   SliderTheme(
            //     data: SliderThemeData(
            //       trackHeight: 8,
            //       activeTrackColor: const Color(0xFF6B7280),
            //       inactiveTrackColor: const Color(0xFFE0E0E0),
            //       thumbColor: const Color(0xFF6B7280),
            //       thumbShape: const RoundSliderThumbShape(
            //         enabledThumbRadius: 8,
            //       ),
            //       overlayColor: const Color(0xFF6B7280).withOpacity(0.2),
            //       overlayShape: const RoundSliderOverlayShape(
            //         overlayRadius: 16,
            //       ),
            //       trackShape: const RoundedRectSliderTrackShape(),
            //     ),
            //     child: RangeSlider(
            //       values: selectedRange,
            //       min: 1,
            //       max: 1900,
            //       divisions: 82,
            //       onChanged: (RangeValues values) {
            //         setState(() {
            //           selectedRange = values;
            //         });
            //       },
            //     ),
            //   ),
            if (widget.spaceBottom != 0) SizedBox(height: widget.spaceBottom),
          ],
        ),
      ),
    );
  }
}
