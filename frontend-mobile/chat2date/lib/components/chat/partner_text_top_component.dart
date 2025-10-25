import 'package:flutter/material.dart';

class PartnerTextTopComponent extends StatelessWidget {
  const PartnerTextTopComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      height: 44,
      width: 122,
      child: const Text(
        'Partner Text',
        style: TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
      ),
    );
  }
}