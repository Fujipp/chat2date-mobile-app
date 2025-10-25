import 'package:flutter/material.dart';

class BotTextUnSuccessComponent extends StatelessWidget {
  const BotTextUnSuccessComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Image.asset("assets/images/bot.png", width: 50, height: 50),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          height: 66,
          width: 194,
          decoration: BoxDecoration(
            color: Color(0xFFFFE6E6),
            borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Text(
                'header',
                style: TextStyle(fontSize: 14, color: Color(0xFF0F172A))
              ),
              SizedBox(height: 5),
              Text(
                'description',
                style: TextStyle(fontSize: 10, color: Color(0xFF991B1B))
              ),
            ],
          )

        )
      ],
    );
  }
}