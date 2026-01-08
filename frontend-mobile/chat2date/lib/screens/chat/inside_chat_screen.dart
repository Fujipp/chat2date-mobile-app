import 'dart:ui';

import 'package:chat2date/components/chat/bot_message_component.dart';
import 'package:chat2date/components/chat/chat_text_component.dart';
import 'package:chat2date/components/chat/input_chat_component.dart';
import 'package:chat2date/components/chat/spin_date_component.dart';
import 'package:chat2date/components/layout/header.dart';
import 'package:chat2date/components/status_bar/score_row.dart';
import 'package:chat2date/models/chat_message.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';

class InsideChatScreen extends StatefulWidget {
  const InsideChatScreen({super.key});

  @override
  State<InsideChatScreen> createState() => _InsideChatScreenState();
}

class _InsideChatScreenState extends State<InsideChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _hasText = false;
  bool _isWheelShowing = false;
  final double _currentPercent = 0.35; // 90px / 255px ≈ 0.35 ตาม Figma
  final int _heartCount = 1; // 0 = ซ่อน, 1-2 = แสดง, 3 = rainbow
  bool _showWheelModal = false;
  bool _showUnlockDate = false;
  
  // ตัวอย่างข้อความแชทตาม Figma designs
  late List<ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _checkSpinWheelCondition();
    _initSampleMessages();
  }
  
  void _initSampleMessages() {
    _messages = [
      // ข้อความปกติ
      ChatMessage.sent(
        id: '1',
        text: 'text message',
        isSeen: false,
      ),
      ChatMessage.received(
        id: '2',
        text: 'text message',
      ),
      ChatMessage.received(
        id: '3',
        text: 'text message',
      ),
      ChatMessage.sent(
        id: '4',
        text: 'text message',
        isSeen: true,
      ),
    ];
  }

  void _checkSpinWheelCondition() {
    // เงื่อนไข: หลอดเต็ม (1.0) หรือ หัวใจครบตามที่กำหนด (เช่น 3 ดวง)
    if (_heartCount >= 1) {
      setState(() {
        _isWheelShowing = true;
      });
    }
  }
  
  /// สร้าง Widget สำหรับแต่ละ message
  Widget _buildMessageWidget(ChatMessage message, int index) {
    // Bot message
    if (message.isBot && message.botType != null) {
      return BotMessageComponent.fromMessage(
        message: message,
        onActionPressed: () {
          // Handle action button press
          debugPrint('Action pressed for message: ${message.id}');
        },
        onFirstChoice: () {
          // Handle "ใช่" choice
          debugPrint('First choice (ใช่) for message: ${message.id}');
        },
        onSecondChoice: () {
          // Handle "ไม่" choice
          debugPrint('Second choice (ไม่) for message: ${message.id}');
        },
      );
    }
    
    // User message (sent/received)
    return Column(
      crossAxisAlignment: message.isOwn 
          ? CrossAxisAlignment.end 
          : CrossAxisAlignment.start,
      children: [
        ChatTextComponent(
          text: message.text,
          isChatRight: message.isOwn,
          // Received message ใช้ avatar ด้านซ้าย
          imagePath: !message.isOwn && index > 0 && _messages[index - 1].isOwn 
              ? 'assets/images/figma/avatar_placeholder.png' 
              : null,
          bottomLeftRadius: message.isOwn ? 20 : 0,
          bottomRightRadius: message.isOwn ? 0 : 20,
        ),
        // แสดง "เห็นแล้ว" สำหรับข้อความที่ส่งและถูกอ่านแล้ว
        if (message.isOwn && message.isSeen)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: StatusTextComponent(
              text: 'เห็นแล้ว',
              textColor: AppColors.textMuted,
              textSize: 10,
              isMiddle: false,
              svgPath: 'assets/icons/icon_seen.svg',
              size: 12,
            ),
          ),
      ],
    );
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
        child: Stack(
          // ✅ ใช้ Stack เพื่อวาง Layer ของวงล้อทับส่วนแชท
          children: [
            Column(
              children: [
                const SizedBox(height: 8),
                Header(
                  name: 'Name',
                  showFlag: true,
                  showHeart: true,
                  showBorder: false,
                  onBack: () => Navigator.maybePop(context),
                  showSpinCooldown: true,
                  cooldownDays: 7,
                  isSpinCooldownEnabled: _isWheelShowing,
                  onSpinwheel: _isWheelShowing
                      ? () {
                          setState(() {
                            _showWheelModal = true; // ✅ กดแล้วเปิดวงล้อ
                          });
                        }
                      : null,
                  onFlag: () {
                    Navigator.pushReplacementNamed(context, '/report');
                  },
                ),

                // --- ส่วนแชททั้งหมด (ScoreRow + ListView + Input) ---
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final double barWidth =
                                (constraints.maxWidth - 25 - 20).clamp(
                                  140,
                                  260,
                                );
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
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildMessageWidget(message, index),
                            );
                          },
                        ),
                      ),
                      InputChatComponent(
                        svgPath: 'assets/icons/icon_new-black.svg',
                        svgPathLast: _hasText
                            ? 'assets/icons/icon_send.svg'
                            : null,
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
              ],
            ),
            if (_showWheelModal) ...[
              // 1. ฉากหลังสีเทาจาง (Dim background)
              Positioned.fill(
                top: 85, // ให้เริ่มหลัง Header
                child: GestureDetector(
                  onTap: () => setState(() => _showWheelModal = false),
                  child: Container(color: Colors.black.withOpacity(0.5)),
                ),
              ),

              // 2. ตัว SpinDateComponent
              // ✅ ใช้ Positioned.fill เพื่อกำหนดขอบเขตพื้นที่ที่เหลือจาก Header
              Positioned.fill(
                top: 85, // เริ่มต้นที่ขอบล่างของ Header
                child: Align(
                  alignment: Alignment.center, // จัดกลางใน "พื้นที่ที่เหลือ"
                  child: SingleChildScrollView(
                    // ✅ กันบั๊กกรณีจอเตี้ยเกินไปหรือ Content ยาวเกินจอ
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ), // ✅ เพิ่ม vertical padding กันติดขอบ
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SpinDateComponent(
                                onCloseModal: () =>
                                    setState(() => _showWheelModal = false),
                                prizes: const [
                                  {'label': 'Coffee'},
                                  {'label': 'Pizza'},
                                  {'label': 'Movie'},
                                  {'label': 'Book'},
                                  {'label': 'Gift'},
                                  {'label': 'Ice-cream'},
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (_showUnlockDate) ...[
              // 1. ฉากหลังเบลอแบบมีสีสัน (สไตล์ Dating App)
              Positioned.fill(
                top: 85,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.pink.withOpacity(0.1), // สีชมพูระเรื่อ
                            Colors.deepPurple.withOpacity(0.1), // สีม่วงจางๆ
                            Colors.white.withOpacity(
                              0.4,
                            ), // ไล่ไปสีขาวให้ดูคลีน
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 2. การ์ด Unlock Date สไตล์ Minimal & Soft
              Positioned.fill(
                top: 85,
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.82,
                    padding: const EdgeInsets.symmetric(
                      vertical: 35,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 25,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ไอคอนหัวใจ + กุญแจ (สื่อถึงแอปหาคู่ได้ดีกว่า)
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.pink.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.favorite_rounded,
                                size: 35,
                                color: Colors.pinkAccent,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.lock_open,
                                  size: 18,
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'UNLOCK DATE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: Color(0xFF4A4A4A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
