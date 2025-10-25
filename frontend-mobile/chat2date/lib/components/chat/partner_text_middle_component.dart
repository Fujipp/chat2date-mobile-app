import 'package:flutter/material.dart';

class PartnerTextMiddleComponent extends StatelessWidget {
  const PartnerTextMiddleComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      height: 44,
      width: 122,
      decoration: BoxDecoration(
        color: Color(0xFFF6F9FC),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: const Text(
        'Partner Text',
        style: TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
      ),
    );
  }
}