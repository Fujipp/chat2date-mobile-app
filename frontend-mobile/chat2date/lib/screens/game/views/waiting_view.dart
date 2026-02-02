import 'dart:async';
import 'package:chat2date/components/buttons/ds_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WaitingView extends StatefulWidget {
  final VoidCallback onReady;
  final String? myAvatarUrl;
  final String? partnerAvatarUrl;

  const WaitingView({
    super.key,
    required this.onReady,
    this.myAvatarUrl,
    this.partnerAvatarUrl,
  });

  @override
  State<WaitingView> createState() => _WaitingViewState();
}

class _WaitingViewState extends State<WaitingView> {
  Timer? _countdownTimer;
  int? _remainingSeconds;
  bool _isPlayerReady = false;
  final bool _isPartnerReady = false;

  @override
  void initState() {
    super.initState();
    // ✅ จุดเช็คของ: สั่งปริ้น URL ออกมาดูใน Console
    debugPrint("--------------------------------------------------");
    debugPrint("🔍 CHECK AVATAR URLS:");
    debugPrint("👤 My Avatar: '${widget.myAvatarUrl}'");
    debugPrint("👥 Partner Avatar: '${widget.partnerAvatarUrl}'");
    debugPrint("--------------------------------------------------");
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() => _remainingSeconds = 60);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds! > 0) {
        setState(() => _remainingSeconds = _remainingSeconds! - 1);
      } else {
        _countdownTimer?.cancel();
        Navigator.pop(context);
      }
    });
  }

  Future<void> _handleReady() async {
    setState(() => _isPlayerReady = true);
    if (_remainingSeconds == null) _startCountdown();
    widget.onReady();
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
              SvgPicture.asset("assets/images/question.svg", width: 130, height: 130),
              const SizedBox(height: 32),
              
              // ... (ส่วน Title และ กติกา เหมือนเดิม) ...
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Guessing Game', style: TextStyle(color: Color(0xFF0F172A), fontSize: 28, fontFamily: 'Inter', fontWeight: FontWeight.w600, height: 1.2)),
                    SizedBox(height: 12),
                    Text('คิดว่าคุณเข้าใจคู่ของคุณดีแค่ไหน?\nลองทายดูสิ!', style: TextStyle(color: Color(0xFF64748B), fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w400, height: 1.5)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0), width: 1)),
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

              if (isTimerStarted) ...[
                 Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: _remainingSeconds! <= 10 ? const Color(0xFFFEE2E2) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20), border: Border.all(color: _remainingSeconds! <= 10 ? const Color(0xFFEF4444) : const Color(0xFFE2E8F0), width: 1)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.timer_outlined, size: 18, color: _remainingSeconds! <= 10 ? const Color(0xFFEF4444) : const Color(0xFF64748B)),
                    const SizedBox(width: 8),
                    Text('เหลือเวลา $_remainingSeconds วินาที', style: TextStyle(color: _remainingSeconds! <= 10 ? const Color(0xFFEF4444) : const Color(0xFF64748B), fontSize: 14, fontFamily: 'Inter', fontWeight: _remainingSeconds! <= 10 ? FontWeight.w600 : FontWeight.w500)),
                  ]),
                ),
                const SizedBox(height: 24),
              ],

              Column(
                children: [
                  Text(_getStatusText(), textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF9AA5B1), fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w400)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ✅ เรียกใช้ Widget แสดงรูปที่เราแก้ใหม่
                      _buildPlayerIndicator(
                        isReady: _isPlayerReady, 
                        label: 'คุณ', 
                        avatarUrl: widget.myAvatarUrl
                      ),
                      const SizedBox(width: 24),
                      const Icon(Icons.favorite, color: Color(0xFFFFB4D6), size: 20),
                      const SizedBox(width: 24),
                      // ✅ เรียกใช้ Widget แสดงรูปที่เราแก้ใหม่
                      _buildPlayerIndicator(
                        isReady: _isPartnerReady, 
                        label: 'คู่', 
                        avatarUrl: widget.partnerAvatarUrl
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
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

  // ... Helper methods (StatusText, RuleItem) ...
  String _getStatusText() {
    if (_isPlayerReady && _isPartnerReady) return 'ทั้งคู่พร้อมแล้ว!';
    if (_isPlayerReady) return 'กำลังรอคู่ของคุณ...';
    if (_isPartnerReady) return 'คู่ของคุณพร้อมแล้ว รอคุณอยู่!';
    return 'รอคู่ของคุณกดเตรียมพร้อม';
  }

  Widget _buildRuleItem(String text) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Text(text, style: const TextStyle(color: Color(0xFF475569), fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w400, height: 1.5))),
    ]);
  }

  // ✅ แก้ใหม่: รองรับทั้ง SVG และ JPG/PNG และมี Log Error
  Widget _buildPlayerIndicator({
    required bool isReady,
    required String label,
    String? avatarUrl,
  }) {
    // 1. เช็คก่อนว่ามี URL ไหม
    Widget imageWidget;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      // 2. ถ้าเป็นไฟล์ .svg ใช้ SvgPicture
      if (avatarUrl.toLowerCase().endsWith('.svg')) {
        imageWidget = SvgPicture.network(
          avatarUrl,
          fit: BoxFit.cover,
          placeholderBuilder: (_) => const Icon(Icons.person, color: Color(0xFF94A3B8)),
        );
      } else {
        // 3. ถ้าเป็นไฟล์รูปทั่วไป ใช้ Image.network
        imageWidget = Image.network(
          avatarUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // ถ้าโหลดไม่ขึ้น จะปริ้น Error บอกใน Console
            debugPrint("❌ LOAD IMAGE ERROR: $error");
            return const Icon(Icons.person, color: Color(0xFF94A3B8));
          },
        );
      }
    } else {
      // 4. ถ้าไม่มี URL ให้โชว์ไอคอน
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
              color: isReady ? const Color(0xFF5CE1E6) : const Color(0xFFCBD5E1),
              width: 2,
            ),
          ),
          child: ClipOval(child: imageWidget), // ตัดขอบรูปให้กลม
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