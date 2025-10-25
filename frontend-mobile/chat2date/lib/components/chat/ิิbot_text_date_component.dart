import 'package:flutter/material.dart';

class BotTextDateComponent extends StatelessWidget {
  const BotTextDateComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Image.asset("assets/images/bot.png", width: 50, height: 50),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          height: 142,
          width: 264,
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
                'ตอบแล้ว 0/2',
                style: TextStyle(fontSize: 10, color: Color(0xFFFF6B6B))
                )
              ),
              SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 40,
                    child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF6B6B),
                      foregroundColor: Color(0xFFFFFFFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                        )
                      ),
                    onPressed: (){}, 
                    child: const Text('ไม่ไป')
                    ),
                  ),
                  SizedBox(width: 27),
                  SizedBox(
                    width: 100,
                    height: 40,
                    child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF98FB98),
                      foregroundColor: Color(0xFFFFFFFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                        )
                      ),
                    onPressed: (){}, 
                    child: const Text('ไป')
                    ),
                  )
                ]
              )
            ],
          )
        )
      ],
    );
  }
}