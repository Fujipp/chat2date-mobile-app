import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PartnerTextTopComponent extends StatelessWidget {
  const PartnerTextTopComponent({super.key});

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
          bottomLeft: Radius.circular(20),
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

class PartnerTextBottomComponent extends StatelessWidget {
  const PartnerTextBottomComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset("assets/images/person.svg", width: 50, height: 50),
        SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFE2E8F0),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Text(
            'Partner Text',
            style: TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
          ),
        ),
      ],
    );
  }
}

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

class SendingTextMiddleComponent extends StatelessWidget {
  const SendingTextMiddleComponent({super.key});

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
          topRight: Radius.circular(5),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(5),
        ),
      ),
      child: const Text(
        'Sending Text',
        style: TextStyle(fontSize: 14, color: Colors.white),
      ),
    );
  }
}

class SendingTextBottomComponent extends StatelessWidget {
  const SendingTextBottomComponent({super.key});

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
          topRight: Radius.circular(0),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: const Text(
        'Sending Text',
        style: TextStyle(fontSize: 14, color: Colors.white),
      ),
    );
  }
}

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
        SvgPicture.asset("assets/images/seen.svg", width: 12.6, height: 12),
      ],
    );
  }
}

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

class BotTextDateComponent extends StatelessWidget {
  const BotTextDateComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SvgPicture.asset("assets/images/bot.svg", width: 50, height: 50),
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

class BotTextGameComponent extends StatelessWidget {
  const BotTextGameComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SvgPicture.asset("assets/images/bot.svg", width: 50, height: 50),
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

class BotTextSuccessComponent extends StatelessWidget {
  const BotTextSuccessComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SvgPicture.asset("assets/images/bot.svg", width: 50, height: 50),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          height: 66,
          width: 194,
          decoration: BoxDecoration(
            color: Color(0xFFE9FFE9),
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
                style: TextStyle(fontSize: 10, color: Color(0xFF134F2C))
              ),
            ],
          )

        )
      ],
    );
  }
}

class BotTextUnSuccessComponent extends StatelessWidget {
  const BotTextUnSuccessComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SvgPicture.asset("assets/images/bot.svg", width: 50, height: 50),
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