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
  // 🔥 Static variable เก็บว่ารูปโหลดไปแล้วหรือยัง (ข้าม Widget lifecycle)
  static final Set<String> _loadedImageUrls = {};

  Timer? _countdownTimer;
  int? _remainingSeconds;

  bool _hasTimerStarted = false;
  bool _isLoading = true;

  ImageProvider? _myImageProvider;
  ImageProvider? _partnerImageProvider;

  @override
  void initState() {
    super.initState();
    debugPrint("--------------------------------------------------");
    debugPrint("🔍 CHECK AVATAR URLS:");
    debugPrint("👤 My Avatar: '${widget.myAvatarUrl}'");
    debugPrint("👥 Partner Avatar: '${widget.partnerAvatarUrl}'");
    debugPrint("--------------------------------------------------");

    // 🔥 ถ้า URL ว่างเปล่า → ยังคง loading รอ API
    bool hasValidUrls =
        (widget.myAvatarUrl?.isNotEmpty ?? false) ||
        (widget.partnerAvatarUrl?.isNotEmpty ?? false);

    if (!hasValidUrls) {
      debugPrint("⏸️ URLs not ready yet. Staying in loading...");
      // ⬅️ ไม่ต้อง set _isLoading = false เพราะเราต้องการให้ขึ้น loading
      return;
    }

    // เช็ค cache ตั้งแต่เริ่มต้น
    bool myImageAlreadyLoaded =
        widget.myAvatarUrl != null &&
        widget.myAvatarUrl!.isNotEmpty &&
        _loadedImageUrls.contains(widget.myAvatarUrl);
    bool partnerImageAlreadyLoaded =
        widget.partnerAvatarUrl != null &&
        widget.partnerAvatarUrl!.isNotEmpty &&
        _loadedImageUrls.contains(widget.partnerAvatarUrl);

    bool allImagesInCache = myImageAlreadyLoaded && partnerImageAlreadyLoaded;

    debugPrint("📦 Initial Cache Check:");
    debugPrint("   My Image in cache: $myImageAlreadyLoaded");
    debugPrint("   Partner Image in cache: $partnerImageAlreadyLoaded");
    debugPrint("   All in cache: $allImagesInCache");

    // ถ้ารูปอยู่ใน cache หมดแล้ว → ไม่ต้องโหลดเลย
    if (allImagesInCache) {
      _isLoading = false;
      debugPrint("✅ Skip loading! Images already cached.");
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isLoading) {
        _initializeData();
      }
    });
  }

  @override
  void didUpdateWidget(WaitingView oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool myUrlChanged = widget.myAvatarUrl != oldWidget.myAvatarUrl;
    bool partnerUrlChanged =
        widget.partnerAvatarUrl != oldWidget.partnerAvatarUrl;

    // 🔥 ถ้า URL เปลี่ยนจาก empty → มีค่า (API response มาแล้ว)
    bool urlsJustArrived =
        (myUrlChanged &&
            (oldWidget.myAvatarUrl?.isEmpty ?? true) &&
            (widget.myAvatarUrl?.isNotEmpty ?? false)) ||
        (partnerUrlChanged &&
            (oldWidget.partnerAvatarUrl?.isEmpty ?? true) &&
            (widget.partnerAvatarUrl?.isNotEmpty ?? false));

    if (urlsJustArrived) {
      debugPrint("🆕 URLs just arrived! Starting loading...");

      // 🔥 ขึ้น loading เสมอ (ไม่เช็ค cache ก่อน)
      if (mounted) {
        setState(() {
          _isLoading = true;
        });

        // รอให้ UI update แล้วค่อยโหลด
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadImagesAndShow();
        });
      }
      return;
    }

    // ถ้า URL เปลี่ยนแต่ไม่ใช่กรณี empty → มีค่า (แค่ refresh background)
    if (myUrlChanged || partnerUrlChanged) {
      debugPrint("🔄 URL Update detected. Background refreshing...");
      _preloadImages().then((_) {
        if (mounted) setState(() {});
      });
    }

    // ถ้ามีคนพร้อมคนแรก → start timer
    final bool someoneIsReady = widget.isMeReady || widget.isPartnerReady;
    if (someoneIsReady && !_hasTimerStarted) {
      debugPrint("⏰ Someone is ready! Starting countdown...");
      _startCountdown();
    }
  }

  // 🔥 ฟังก์ชันใหม่: โหลดรูปและแสดงผล
  Future<void> _loadImagesAndShow() async {
    debugPrint("⏳ Loading images...");

    // เช็คว่ารูปอยู่ใน cache หรือยัง
    bool myImageAlreadyLoaded =
        widget.myAvatarUrl != null &&
        widget.myAvatarUrl!.isNotEmpty &&
        _loadedImageUrls.contains(widget.myAvatarUrl);
    bool partnerImageAlreadyLoaded =
        widget.partnerAvatarUrl != null &&
        widget.partnerAvatarUrl!.isNotEmpty &&
        _loadedImageUrls.contains(widget.partnerAvatarUrl);

    bool allImagesInCache = myImageAlreadyLoaded && partnerImageAlreadyLoaded;

    debugPrint("📦 Cache Status:");
    debugPrint("   My Image in cache: $myImageAlreadyLoaded");
    debugPrint("   Partner Image in cache: $partnerImageAlreadyLoaded");
    debugPrint("   All in cache: $allImagesInCache");

    if (allImagesInCache) {
      // ถ้าอยู่ใน cache แล้ว → set provider แล้วแสดงทันที (User B)
      debugPrint("✅ Images in cache! Setting providers...");

      if (widget.myAvatarUrl?.isNotEmpty == true &&
          !widget.myAvatarUrl!.toLowerCase().endsWith('.svg')) {
        _myImageProvider = NetworkImage(widget.myAvatarUrl!);
      }
      if (widget.partnerAvatarUrl?.isNotEmpty == true &&
          !widget.partnerAvatarUrl!.toLowerCase().endsWith('.svg')) {
        _partnerImageProvider = NetworkImage(widget.partnerAvatarUrl!);
      }

      // แสดงทันที
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      // ถ้ายังไม่มีใน cache → โหลดจาก network (User A)
      debugPrint("📥 Loading from network...");
      await _preloadImages();

      // รอให้แน่ใจว่า log ขึ้นหมดแล้ว
      await Future.delayed(const Duration(milliseconds: 100));

      // รอให้ครบ 1.5 วินาที
      debugPrint("⏳ Wait 1.5s for smooth transition");
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }

    debugPrint("✅ Ready to show game!");
  }

  Future<void> _initializeData() async {
    debugPrint("⏳ Loading new images...");

    // โหลดรูปใหม่
    await _preloadImages();

    // รอให้แน่ใจว่า log ขึ้นหมดแล้ว
    await Future.delayed(const Duration(milliseconds: 100));

    // รอให้ครบ 1.5 วินาที (User A)
    debugPrint("⏳ Wait 1.5s for smooth transition");
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    debugPrint("✅ Ready to show game!");
  }

  Future<void> _preloadImages() async {
    List<Future> tasks = [];

    // โหลดรูปฉัน
    if (widget.myAvatarUrl?.isNotEmpty ?? false) {
      if (!widget.myAvatarUrl!.toLowerCase().endsWith('.svg')) {
        _myImageProvider = NetworkImage(widget.myAvatarUrl!);
        tasks.add(
          precacheImage(_myImageProvider!, context)
              .then((_) {
                // เก็บ URL ที่โหลดเสร็จแล้ว
                _loadedImageUrls.add(widget.myAvatarUrl!);
                debugPrint("✅ My image cached: ${widget.myAvatarUrl}");
              })
              .catchError((e) {
                debugPrint("❌ My Image Error: $e");
              }),
        );
      }
    }

    // โหลดรูปคู่
    if (widget.partnerAvatarUrl?.isNotEmpty ?? false) {
      if (!widget.partnerAvatarUrl!.toLowerCase().endsWith('.svg')) {
        _partnerImageProvider = NetworkImage(widget.partnerAvatarUrl!);
        tasks.add(
          precacheImage(_partnerImageProvider!, context)
              .then((_) {
                // เก็บ URL ที่โหลดเสร็จแล้ว
                _loadedImageUrls.add(widget.partnerAvatarUrl!);
                debugPrint(
                  "✅ Partner image cached: ${widget.partnerAvatarUrl}",
                );
              })
              .catchError((e) {
                debugPrint("❌ Partner Image Error: $e");
              }),
        );
      }
    }

    if (tasks.isNotEmpty) {
      try {
        // 🔥 รอให้ทุก task เสร็จจริงๆ
        await Future.wait(tasks);
        debugPrint("✅ All precache tasks completed!");
      } catch (e) {
        debugPrint("⚠️ Image load warning: $e");
      }
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
                  "assets/images/illustrations/question.svg",
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
                "assets/images/illustrations/question.svg",
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

              // Timer Widget
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
                        provider: _myImageProvider,
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
                        provider: _partnerImageProvider,
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
    ImageProvider? provider,
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
        imageWidget = Image(
          image: provider ?? NetworkImage(avatarUrl),
          fit: BoxFit.cover,
          gaplessPlayback: true,
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
