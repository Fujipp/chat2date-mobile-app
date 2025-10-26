import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InputChatNoTextComponent extends StatelessWidget {
  const InputChatNoTextComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      height: 72,
      width: double.infinity,
      child: Row(
        children: [
          SvgPicture.asset(
            "assets/images/more-options.svg",
            width: 32,
            height: 32,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InputChatHaveTextComponent extends StatelessWidget {
  final VoidCallback? onSend;

  const InputChatHaveTextComponent({super.key, this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      height: 72,
      width: double.infinity, // ขยายเต็มหน้าจอ
      child: Row(
        children: [
          SvgPicture.asset(
            "assets/images/more-options.svg",
            width: 32,
            height: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'เขียนข้อความ',
                filled: true,
                fillColor: Color(0xFFF6F9FC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton(
                    onPressed: onSend ?? () {},
                    icon: SvgPicture.asset(
                      'assets/images/send.svg',
                      width: 32,
                      height: 32,
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
