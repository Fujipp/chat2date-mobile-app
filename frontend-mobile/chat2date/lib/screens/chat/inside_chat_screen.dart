import 'package:chat2date/components/chat/chat_text_component.dart';
import 'package:chat2date/components/chat/input_chat_component.dart';
import 'package:chat2date/components/layout/header.dart';
import 'package:chat2date/components/status_bar/score_row.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InsideChatScreen extends StatefulWidget {
  const InsideChatScreen({super.key});

  @override
  State<InsideChatScreen> createState() => _InsideChatScreenState();
}

class _InsideChatScreenState extends State<InsideChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _hasText = false;
  bool _isWheelShowing = false;
  final double _currentPercent = 0.45; // สมมติค่าเริ่มต้น
  final int _heartCount = 1;

  @override
  void initState() {
    super.initState();
    // เรียกเช็คทันทีที่เข้าหน้านี้
    _checkSpinWheelCondition();
  }

  void _checkSpinWheelCondition() {
    // เงื่อนไข: หลอดเต็ม (1.0) หรือ หัวใจครบตามที่กำหนด (เช่น 3 ดวง)
    if (_currentPercent >= 1.0 || _heartCount >= 1) {
      setState(() {
        _isWheelShowing = true;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Header(
              name: 'Name',
              showFlag: true,
              showBorder: false,
              onBack: () => Navigator.maybePop(context),
              showSpinwheel: _isWheelShowing,
              onFlag: () {
                Navigator.pushReplacementNamed(context, '/report');
              },
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double barWidth = (constraints.maxWidth - 25 - 20)
                      .clamp(140, 260);
                  return ScoreRow(
                    basePercent: _currentPercent,
                    number: 0,
                    barWidth: barWidth,
                    barHeight: 8,
                    rightIconSize: 18,
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'วันเสาร์ 13:30',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                children: [
                  ChatTextComponent(
                    text: 'text message',
                    isChatRight: true,
                    bottomLeftRadius: 20,
                    bottomRightRadius: 20,
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'เห็นแล้ว',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 4),
                        SvgPicture.asset(
                          'assets/icons/icon_seen.svg',
                          width: 14,
                          height: 14,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ChatTextComponent(
                    text: 'text message',
                    color: AppColors.surfaceMuted,
                    bottomLeftRadius: 20,
                    bottomRightRadius: 20,
                  ),
                  const SizedBox(height: 8),
                  ChatTextComponent(
                    text: 'text message',
                    svgPath: 'assets/icons/icon_avatar.svg',
                    color: AppColors.surfaceMuted,
                    bottomLeftRadius: 20,
                    bottomRightRadius: 20,
                  ),
                  const SizedBox(height: 16),
                  ChatTextComponent(
                    text: 'text message',
                    isChatRight: true,
                    bottomLeftRadius: 20,
                    bottomRightRadius: 20,
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'เห็นแล้ว',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 4),
                        SvgPicture.asset(
                          'assets/icons/icon_seen.svg',
                          width: 14,
                          height: 14,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            InputChatComponent(
              svgPath: 'assets/icons/icon_new-black.svg',
              svgPathLast: _hasText ? 'assets/icons/icon_send.svg' : null,
              leftIconColor: AppColors.surfaceLight,
              sendIconColor: Colors.white,
              sendIconBackgroundColor: AppColors.surfaceLight,
              isSendEnabled: _hasText,
              controller: _messageController,
              onChanged: (value) =>
                  setState(() => _hasText = value.trim().isNotEmpty),
              onSend: () {},
            ),
          ],
        ),
      ),
    );
  }
}
