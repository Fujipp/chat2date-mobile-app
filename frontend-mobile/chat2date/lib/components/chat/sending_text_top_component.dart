import 'package:flutter/material.dart';

class SendingTextTopComponent extends StatelessWidget {
  const SendingTextTopComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      height: 44,
      width: 122.1,
      decoration: BoxDecoration(
        color: Color(0xFFFF8FB3),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: const Text(
        'Sending Text',
        style: TextStyle(fontSize: 14, color: Colors.white),
      ),
    );
  }
}