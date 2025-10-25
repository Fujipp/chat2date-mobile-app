import 'package:flutter/material.dart';

class BotTextGameComponent extends StatelessWidget {
  const BotTextGameComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Image.asset("assets/images/bot.png", width: 50, height: 50),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          height: 162,
          width: 259,
          decoration: BoxDecoration(
            color: Color(0xFFFFF1C1),
            borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'header',
                style: TextStyle(fontSize: 14, color: Color(0xFF0F172A))
              ),
              SizedBox(height: 5),
              Text(
                'description',
                style: TextStyle(fontSize: 10, color: Color(0xFF7C4A00))
              ),
              const Spacer(),
              Center(
                child: Text(
                'time remaining',
                style: TextStyle(fontSize: 10, color: Color(0xFFFF6B6B))
                )
              ),
              SizedBox(height: 14),
              SizedBox(
                width: 227,
                height: 40,
                child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4DF8FF),
                  foregroundColor: Color(0xFFFFFFFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)
                    )
                ),
                onPressed: (){}, 
                child: const Text('เริ่ม')
                ),
              )
            ],
          )
        )
      ],
    );
  }
}