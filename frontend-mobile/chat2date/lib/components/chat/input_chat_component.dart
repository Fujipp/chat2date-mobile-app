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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      height: 72,
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (svgPath != null)
            GestureDetector(
              onTap: onClick,
              child: leftIconBackgroundColor == null
                  ? SvgPicture.asset(
                      svgPath!,
                      width: 16,
                      height: 16,
                      colorFilter: leftIconColor == null
                          ? null
                          : ColorFilter.mode(leftIconColor!, BlendMode.srcIn),
                    )
                  : Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: leftIconBackgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          svgPath!,
                          width: 14,
                          height: 14,
                          colorFilter: leftIconColor == null
                              ? null
                              : ColorFilter.mode(leftIconColor!, BlendMode.srcIn),
                        ),
                      ),
                    ),
            ),
          if (svgPath != null) const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hintText,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: inputFillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: svgPathLast == null
                    ? null
                    : SizedBox(
                        width: 48,
                        height: 48,
                        child: GestureDetector(
                          onTap: isSendEnabled ? (onSend ?? () {}) : null,
                          behavior: HitTestBehavior.opaque,
                          child: Center(
                            child: sendIconBackgroundColor == null
                                ? SvgPicture.asset(
                                    svgPathLast!,
                                    width: 32,
                                    height: 32,
                                    colorFilter: sendIconColor == null
                                        ? null
                                        : ColorFilter.mode(
                                            sendIconColor!,
                                            BlendMode.srcIn,
                                          ),
                                  )
                                : Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: isSendEnabled
                                          ? sendIconBackgroundColor
                                          : sendIconBackgroundColor!.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        svgPathLast!,
                                        width: 16,
                                        height: 16,
                                        colorFilter: sendIconColor == null
                                            ? null
                                            : ColorFilter.mode(
                                                sendIconColor!,
                                                BlendMode.srcIn,
                                              ),
                                      ),
                                    ),
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
