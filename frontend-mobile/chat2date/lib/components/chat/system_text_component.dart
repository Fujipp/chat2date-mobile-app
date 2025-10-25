import 'package:flutter/material.dart';

class SystemTextComponent extends StatelessWidget {
  const SystemTextComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFF0F8FF),
      ),
      child: const Text(
        'System Text',
        style: TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
      ),
    );
  }
}