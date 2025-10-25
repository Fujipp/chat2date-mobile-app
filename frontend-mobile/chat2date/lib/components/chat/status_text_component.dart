import 'package:flutter/material.dart';

class StatusTextComponent extends StatelessWidget {
  const StatusTextComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
        'เห็นแล้ว',
        style: TextStyle(fontSize: 12, color: Color(0xFF93A1B3))),
        SizedBox(width: 3),
        Image.asset("assets/images/seen.png", width: 12.6, height: 12),
      ],
    );
  }
}