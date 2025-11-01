import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InputChatComponent extends StatelessWidget {
  //รูปหน้าสุด
  final String? svgPath;

  //รูปท้ายสุด
  final String? svgPathLast;

  //เรียกฟังก์ชั่น
  final VoidCallback? onClick;
  final VoidCallback? onSend;

  const InputChatComponent({
    super.key,
    //รูปหน้าสุด
    this.svgPath,
    //รูปท้ายสุด
    this.svgPathLast,

    //เรียกฟังก์ชั่น
    this.onSend,
    this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        height: 72,
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: onClick,
              child: SvgPicture.asset(svgPath!, width: 16, height: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'เขียนข้อความ',
                  filled: true,
                  fillColor: AppColors.neutralLight,
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
                        child: SvgPicture.asset(
                          svgPathLast!,
                          width: 32,
                          height: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
