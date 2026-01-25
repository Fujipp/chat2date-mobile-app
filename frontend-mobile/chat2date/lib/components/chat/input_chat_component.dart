import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InputChatComponent extends StatelessWidget {
  //รูปหน้าสุด
  final String? svgPath;
  final Color? leftIconColor;
  final Color? leftIconBackgroundColor;

  //รูปท้ายสุด
  final String? svgPathLast;
  final Color? sendIconColor;
  final Color? sendIconBackgroundColor;
  final bool isSendEnabled;

  //เรียกฟังก์ชั่น
  final VoidCallback? onClick;
  final VoidCallback? onSend;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final Color inputFillColor;

  const InputChatComponent({
    super.key,
    //รูปหน้าสุด
    this.svgPath,
    this.leftIconColor,
    this.leftIconBackgroundColor,
    //รูปท้ายสุด
    this.svgPathLast,
    this.sendIconColor,
    this.sendIconBackgroundColor,
    this.isSendEnabled = true,

    //เรียกฟังก์ชั่น
    this.onSend,
    this.onClick,
    this.controller,
    this.onChanged,
    this.hintText = 'เขียนข้อความ',
    this.inputFillColor = AppColors.neutralLight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // More Options button (+ icon) - ตาม Figma
          if (svgPath != null)
            GestureDetector(
              onTap: onClick,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: SvgPicture.asset(
                  svgPath!,
                  width: 16,
                  height: 16,
                  colorFilter: leftIconColor == null
                      ? null
                      : ColorFilter.mode(leftIconColor!, BlendMode.srcIn),
                ),
              ),
            ),
          if (svgPath != null) const SizedBox(width: 6), // gap=6px ตาม Figma
          // Text Input with Send button inside - ตาม Figma
          Expanded(
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 40,
                maxHeight: 120,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FE), // #F8F9FE ตาม Figma
                borderRadius: BorderRadius.circular(71), // rounded-[71px] ตาม Figma
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      maxLines: null,
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      style: const TextStyle(
                        color: Color(0xFF1F2024),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: TextStyle(
                          color: const Color(0xFF1F2024).withOpacity(0.5),
                          fontSize: 14,
                          fontFamily: 'Inter',
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send button (32x32 circle) - ตาม Figma
                  if (svgPathLast != null)
                    GestureDetector(
                      onTap: isSendEnabled ? onSend : null,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12, bottom: 4),
                        child: Opacity(
                          opacity: isSendEnabled ? 1.0 : 0.5,
                          child: SvgPicture.asset(
                            svgPathLast!,
                            width: 32,
                            height: 32,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
