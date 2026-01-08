import 'dart:ui';

import 'package:chat2date/components/chat/chat_text_component.dart';
import 'package:chat2date/components/chat/input_chat_component.dart';
import 'package:chat2date/components/chat/spin_date_component.dart';
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
  bool _showWheelModal = false;
  bool _showUnlockDate = false;

  @override
  void initState() {
    super.initState();
    // เรียกเช็คทันทีที่เข้าหน้านี้
    _checkSpinWheelCondition();
  }

  void _checkSpinWheelCondition() {
    // เงื่อนไข: หลอดเต็ม (1.0) หรือ หัวใจครบตามที่กำหนด (เช่น 3 ดวง)
    if (_heartCount >= 1) {
      setState(() {
        _isWheelShowing = true;
      });
    }
  }

  void _triggerUnlockDate() {
    setState(() {
      _showUnlockDate = true;
    });

    // นับถอยหลัง 5 วินาทีแล้วปิด
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showUnlockDate = false;
        });
      }
    });
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
                  showBorder: false,
                  onBack: () => Navigator.maybePop(context),
                  showSpinwheel: _isWheelShowing,
                  onSpinwheel: () {
                    setState(() {
                      _showWheelModal = true; // ✅ กดแล้วเปิดวงล้อ
                    });
                  },
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
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                          children: [
                            ChatTextComponent(
                              text: 'text message',
                              isChatRight: true,
                            ),
                            // ... ข้อความอื่นๆ ...
                          ],
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
