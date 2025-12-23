import 'dart:async';

import 'package:chat2date/components/buttons/ds_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WaitingView extends StatefulWidget {
  const WaitingView({super.key, required void Function() onReady});

  @override
  State<WaitingView> createState() => _WaitingViewState();
}

class _WaitingViewState extends State<WaitingView> {
  Timer? _countdownTimer;
  int? _remainingSeconds; // null = ยังไม่เริ่มนับ
  bool _isPlayerReady = false;
  final bool _isPartnerReady = false;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _remainingSeconds = 60;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds! > 0) {
        setState(() {
          _remainingSeconds = _remainingSeconds! - 1;
        });
      } else {
        _countdownTimer?.cancel();
        _exitGame();
      }
    });
  }

  void _exitGame() {
    // เด้งออกจากเกม
    Navigator.pop(context);
  }

  void _handleReady() {
    setState(() {
      _isPlayerReady = true;
    });

    // เริ่มนับถอยหลังทันทีที่คนแรกกด
    if (_remainingSeconds == null) {
      _startCountdown();
    }

    // TODO: ส่ง ready status ไป backend
    // TODO: รอคู่กดพร้อม แล้วเริ่มเกม

    // Mock: คู่กดพร้อมหลังจาก 3 วินาที (สำหรับ demo)
    // Future.delayed(const Duration(seconds: 3), () {
    //   if (mounted) {
    //     setState(() {
    //       _isPartnerReady = true;
    //     });
    //     // ทั้งคู่พร้อมแล้ว เริ่มเกมได้
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    final bool isTimerStarted = _remainingSeconds != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              const SizedBox(height: 60),

              SvgPicture.asset(
                "assets/images/question.svg",
                width: 130,
                height: 130,
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Guessing Game',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 28,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'คิดว่าคุณเข้าใจคู่ของคุณดีแค่ไหน?\nลองทายดูสิ!',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Game Rules Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRuleItem('• 5 คำถามจากบทสนทนาของคุณทั้งคู่'),
                    const SizedBox(height: 12),
                    _buildRuleItem('• แต่ละข้อมี 4 ตัวเลือก'),
                    const SizedBox(height: 12),
                    _buildRuleItem('• ตอบให้ตรงกับคู่ของคุณให้ได้มากที่สุด'),
                  ],
                ),
              ),

              const Spacer(),

              // Countdown Timer - แสดงเมื่อมีคนกดแล้ว
              if (isTimerStarted) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _remainingSeconds! <= 10
                        ? const Color(0xFFFEE2E2) // สีแดงอ่อนเมื่อเหลือเวลาน้อย
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _remainingSeconds! <= 10
                          ? const Color(0xFFEF4444)
                          : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 18,
                        color: _remainingSeconds! <= 10
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'เหลือเวลา $_remainingSeconds วินาที',
                        style: TextStyle(
                          color: _remainingSeconds! <= 10
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF64748B),
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: _remainingSeconds! <= 10
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Status section
              Column(
                children: [
                  Text(
                    _getStatusText(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF9AA5B1),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Player status indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPlayerIndicator(
                        isReady: _isPlayerReady,
                        label: 'คุณ',
                      ),
                      const SizedBox(width: 24),
                      const Icon(
                        Icons.favorite,
                        color: Color(0xFFFFB4D6),
                        size: 20,
                      ),
                      const SizedBox(width: 24),
                      _buildPlayerIndicator(
                        isReady: _isPartnerReady,
                        label: 'คู่',
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              // Button
              SizedBox(
                width: double.infinity,
                child: DsButton(
                  label: _isPlayerReady ? 'กำลังรอคู่...' : 'เตรียมพร้อม',
                  onPressed: _isPlayerReady ? null : _handleReady,
                  variant: DsButtonVariant.primary,
                  size: DsButtonSize.md,
                ),
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText() {
    if (_isPlayerReady && _isPartnerReady) {
      return 'ทั้งคู่พร้อมแล้ว!';
    } else if (_isPlayerReady) {
      return 'กำลังรอคู่ของคุณ...';
    } else if (_isPartnerReady) {
      return 'คู่ของคุณพร้อมแล้ว รอคุณอยู่!';
    } else {
      return 'รอคู่ของคุณกดเตรียมพร้อม';
    }
  }

  Widget _buildRuleItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerIndicator({required bool isReady, required String label}) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isReady ? const Color(0xFF5CE1E6) : const Color(0xFFE2E8F0),
            shape: BoxShape.circle,
            border: Border.all(
              color: isReady
                  ? const Color(0xFF5CE1E6)
                  : const Color(0xFFCBD5E1),
              width: 2,
            ),
          ),
          child: Icon(
            isReady ? Icons.check : Icons.person_outline,
            color: isReady ? Colors.white : const Color(0xFF94A3B8),
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isReady ? const Color(0xFF5CE1E6) : const Color(0xFF94A3B8),
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
