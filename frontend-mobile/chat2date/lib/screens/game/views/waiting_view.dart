import 'dart:async';

import 'package:chat2date/components/buttons/ds_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WaitingView extends StatefulWidget {
  final VoidCallback onReady;
  final VoidCallback onTimeout;
  final String? myAvatarUrl;
  final String? partnerAvatarUrl;

  final bool isMeReady;
  final bool isPartnerReady;

  const WaitingView({
    super.key,
    required this.onReady,
    required this.onTimeout,
    this.myAvatarUrl,
    this.partnerAvatarUrl,
    required this.isMeReady,
    required this.isPartnerReady,
  });

  @override
  State<WaitingView> createState() => _WaitingViewState();
}

class _WaitingViewState extends State<WaitingView> {
  Timer? _countdownTimer;
  int? _remainingSeconds;

  bool _hasTimerStarted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    debugPrint("--------------------------------------------------");
    debugPrint("🔍 CHECK AVATAR URLS:");
    debugPrint("👤 My Avatar: '${widget.myAvatarUrl}'");
    debugPrint("👥 Partner Avatar: '${widget.partnerAvatarUrl}'");
    debugPrint("--------------------------------------------------");

    // โหลดข้อมูลและรอให้พร้อม
    _initializeData();
  }

  Future<void> _initializeData() async {
    // รอให้ข้อมูล avatar โหลดเสร็จ
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      debugPrint("✅ Data loaded successfully!");
    }
  }

  @override
  void didUpdateWidget(WaitingView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 🔥 ถ้ามีคนพร้อมคนแรก และยัง start timer ไม่ได้ → start เลย
    final bool someoneIsReady = widget.isMeReady || widget.isPartnerReady;

    if (someoneIsReady && !_hasTimerStarted) {
      debugPrint("⏰ Someone is ready! Starting countdown...");
      _startCountdown();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    if (_hasTimerStarted) return;

    _hasTimerStarted = true;
    setState(() => _remainingSeconds = 60);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (_remainingSeconds! > 0) {
          setState(() => _remainingSeconds = _remainingSeconds! - 1);
        } else {
          _countdownTimer?.cancel();
          widget.onTimeout();
          debugPrint("⏰ Timer expired!");
        }
      }
    });
  }

  Future<void> _handleReady() async {
    widget.onReady();
  }

  @override
  Widget build(BuildContext context) {
    // แสดง Loading Screen ถ้ายังโหลดไม่เสร็จ
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/images/question.svg",
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 32),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5CE1E6)),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 24),
                const Text(
                  'กำลังเตรียมเกม...',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final bool isMeReady = widget.isMeReady;
    final bool isPartnerReady = widget.isPartnerReady;
    final bool isTimerStarted = _remainingSeconds != null;

    debugPrint(
      "🎨 UI Update - Me: $isMeReady, Partner: $isPartnerReady, Timer: $_remainingSeconds",
    );

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

              // 🔥 Timer Widget
              if (isTimerStarted) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _remainingSeconds! <= 10
                        ? const Color(0xFFFEE2E2)
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

              Column(
                children: [
                  Text(
                    _getStatusText(isMeReady, isPartnerReady),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF9AA5B1),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPlayerIndicator(
                        isReady: isMeReady,
                        label: 'คุณ',
                        avatarUrl: widget.myAvatarUrl,
                      ),
                      const SizedBox(width: 24),
                      const Icon(
                        Icons.favorite,
                        color: Color(0xFFFFB4D6),
                        size: 20,
                      ),
                      const SizedBox(width: 24),
                      _buildPlayerIndicator(
                        isReady: isPartnerReady,
                        label: 'คู่',
                        avatarUrl: widget.partnerAvatarUrl,
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: DsButton(
                  label: isMeReady ? 'กำลังรอคู่...' : 'เตรียมพร้อม',
                  onPressed: isMeReady ? null : _handleReady,
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

  String _getStatusText(bool isMeReady, bool isPartnerReady) {
    if (isMeReady && isPartnerReady) return 'ทั้งคู่พร้อมแล้ว!';
    if (isMeReady) return 'กำลังรอคู่ของคุณ...';
    if (isPartnerReady) return 'คู่ของคุณพร้อมแล้ว รอคุณอยู่!';
    return 'รอคู่ของคุณกดเตรียมพร้อม';
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

  Widget _buildPlayerIndicator({
    required bool isReady,
    required String label,
    String? avatarUrl,
  }) {
    Widget imageWidget;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      if (avatarUrl.toLowerCase().endsWith('.svg')) {
        imageWidget = SvgPicture.network(
          avatarUrl,
          fit: BoxFit.cover,
          placeholderBuilder: (_) =>
              const Icon(Icons.person, color: Color(0xFF94A3B8)),
        );
      } else {
        imageWidget = Image.network(
          avatarUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint("❌ LOAD IMAGE ERROR: $error");
            return const Icon(Icons.person, color: Color(0xFF94A3B8));
          },
        );
      }
    } else {
      imageWidget = const Icon(Icons.person, color: Color(0xFF94A3B8));
    }

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
          child: ClipOval(child: imageWidget),
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
