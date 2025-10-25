import 'package:flutter/material.dart';

class PartnerTextBottomComponent extends StatelessWidget {
  const PartnerTextBottomComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset("assets/images/person.png", width: 50, height: 50),
        SizedBox(width: 16),
        Text(
        'Partner Text',
        style: TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
      ],
    );
  }
}