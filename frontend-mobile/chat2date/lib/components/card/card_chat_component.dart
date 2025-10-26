import 'package:flutter/material.dart';

class CardChatNewComponent extends StatelessWidget {
  const CardChatNewComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      height: 72,
      width: 310,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4FE3F7),
            Color(0xFFA4FBA6),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Image.asset("assets/images/avatar.png", width: 40, height: 40),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'header',
                style: TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
              ),
              SizedBox(height: 5),
              Text(
                'description',
                style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
              ),
            ],
          ),
          const Spacer(),
          Image.asset("assets/images/new-white.png", width: 20, height: 14),
        ],
      ),
    );
  }
}

class CardChatNewV2Component extends StatelessWidget {
  const CardChatNewV2Component({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      height: 72,
      width: 310,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4FE3F7),
            Color(0xFFA4FBA6),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Image.asset("assets/images/avatar.png", width: 40, height: 40),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset("assets/images/new-black.png", width: 24, height: 24),
              SizedBox(height: 5),
              Text(
                'header',
                style: TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
              ),
              SizedBox(height: 5),
              Text(
                'description',
                style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
              ),
            ],
          ),
          const Spacer(),
          Image.asset("assets/images/new-white.png", width: 20, height: 14),
        ],
      ),
    );
  }
}

class CardChatNormalComponent extends StatelessWidget {
  const CardChatNormalComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      height: 72,
      width: 310,
      decoration: BoxDecoration(
        color: Color(0xFFE2E8F0),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Image.asset("assets/images/avatar.png", width: 40, height: 40),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'header',
                style: TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
              ),
              SizedBox(height: 5),
              Text(
                'description',
                style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CardChatNotificationComponent extends StatelessWidget {
  const CardChatNotificationComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      height: 72,
      width: 310,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4FE3F7),
            Color(0xFFA4FBA6),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Image.asset("assets/images/avatar.png", width: 40, height: 40),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'header',
                style: TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
              ),
              SizedBox(height: 5),
              Text(
                'description',
                style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
              ),
            ],
          ),
          const Spacer(),
          Image.asset("assets/images/new-white.png", width: 33, height: 33),
        ],
      ),
    );
  }
}
