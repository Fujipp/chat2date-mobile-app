import 'dart:async';

import 'package:chat2date/components/design_system/buttons/ds_button.dart';
import 'package:chat2date/core/theme/app_assets.dart';
import 'package:chat2date/core/theme/app_colors.dart';
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

    final hasValidUrls =
        (widget.myAvatarUrl?.isNotEmpty ?? false) ||
        (widget.partnerAvatarUrl?.isNotEmpty ?? false);

    if (!hasValidUrls) {
      return;
    }

    final myImageAlreadyLoaded =
        widget.myAvatarUrl != null &&
        widget.myAvatarUrl!.isNotEmpty &&
        _loadedImageUrls.contains(widget.myAvatarUrl);
    final partnerImageAlreadyLoaded =
        widget.partnerAvatarUrl != null &&
        widget.partnerAvatarUrl!.isNotEmpty &&
        _loadedImageUrls.contains(widget.partnerAvatarUrl);

    if (myImageAlreadyLoaded && partnerImageAlreadyLoaded) {
      _isLoading = false;
      _setImageProviders();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_isLoading) {
        await _loadImagesAndShow();
      }
    });
  }

  @override
  void didUpdateWidget(covariant WaitingView oldWidget) {
    super.didUpdateWidget(oldWidget);

    final urlsJustArrived =
        ((oldWidget.myAvatarUrl?.isEmpty ?? true) &&
                (widget.myAvatarUrl?.isNotEmpty ?? false)) ||
            ((oldWidget.partnerAvatarUrl?.isEmpty ?? true) &&
                (widget.partnerAvatarUrl?.isNotEmpty ?? false));

    if (urlsJustArrived) {
      if (mounted) {
        setState(() => _isLoading = true);
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await _loadImagesAndShow();
        });
      }
      return;
    }

    if (widget.myAvatarUrl != oldWidget.myAvatarUrl ||
        widget.partnerAvatarUrl != oldWidget.partnerAvatarUrl) {
      _preloadImages().then((_) {
        if (!mounted) return;
        setState(() => _setImageProviders());
      });
    }

    final someoneIsReady = widget.isMeReady || widget.isPartnerReady;
    if (someoneIsReady && !_hasTimerStarted) {
      _startCountdown();
    }
  }

  void _setImageProviders() {
    if (widget.myAvatarUrl?.isNotEmpty == true &&
        !widget.myAvatarUrl!.toLowerCase().endsWith('.svg')) {
      _myImageProvider = NetworkImage(widget.myAvatarUrl!);
    }
    if (widget.partnerAvatarUrl?.isNotEmpty == true &&
        !widget.partnerAvatarUrl!.toLowerCase().endsWith('.svg')) {
      _partnerImageProvider = NetworkImage(widget.partnerAvatarUrl!);
    }
  }

  Future<void> _loadImagesAndShow() async {
    final myImageAlreadyLoaded =
        widget.myAvatarUrl != null &&
        widget.myAvatarUrl!.isNotEmpty &&
        _loadedImageUrls.contains(widget.myAvatarUrl);
    final partnerImageAlreadyLoaded =
        widget.partnerAvatarUrl != null &&
        widget.partnerAvatarUrl!.isNotEmpty &&
        _loadedImageUrls.contains(widget.partnerAvatarUrl);

    if (myImageAlreadyLoaded && partnerImageAlreadyLoaded) {
      _setImageProviders();
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    await _preloadImages();
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() {
      _setImageProviders();
      _isLoading = false;
    });
  }

  Future<void> _preloadImages() async {
    final tasks = <Future<void>>[];

    if (widget.myAvatarUrl?.isNotEmpty == true &&
        !widget.myAvatarUrl!.toLowerCase().endsWith('.svg')) {
      _myImageProvider = NetworkImage(widget.myAvatarUrl!);
      tasks.add(
        precacheImage(_myImageProvider!, context).then((_) {
          _loadedImageUrls.add(widget.myAvatarUrl!);
        }).catchError((_) {}),
      );
    }

    if (widget.partnerAvatarUrl?.isNotEmpty == true &&
        !widget.partnerAvatarUrl!.toLowerCase().endsWith('.svg')) {
      _partnerImageProvider = NetworkImage(widget.partnerAvatarUrl!);
      tasks.add(
        precacheImage(_partnerImageProvider!, context).then((_) {
          _loadedImageUrls.add(widget.partnerAvatarUrl!);
        }).catchError((_) {}),
      );
    }

    if (tasks.isNotEmpty) {
      await Future.wait(tasks);
    }
  }

  void _startCountdown() {
    if (_hasTimerStarted) return;

    _hasTimerStarted = true;
    setState(() => _remainingSeconds = 60);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if ((_remainingSeconds ?? 0) > 0) {
        setState(() => _remainingSeconds = (_remainingSeconds ?? 1) - 1);
      } else {
        _countdownTimer?.cancel();
        widget.onTimeout();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _statusText() {
    if (widget.isMeReady && widget.isPartnerReady) {
      return 'พร้อมแล้ว';
    }
    if (widget.isMeReady) {
      return 'รอคู่ของคุณกดเตรียมพร้อม';
    }
    if (widget.isPartnerReady) {
      return 'คู่ของคุณกดเตรียมพร้อมแล้ว';
    }
    return 'รอคู่ของคุณกดเตรียมพร้อม';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  AppAssets.questionIllustration,
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(
                  color: AppColors.brandPrimary,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final readyCount =
        (widget.isMeReady ? 1 : 0) + (widget.isPartnerReady ? 1 : 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BackCircleButton(
                onTap: widget.onTimeout,
              ),
              const SizedBox(height: 26),
              Center(
                child: SvgPicture.asset(
                  AppAssets.questionIllustration,
                  width: 158,
                  height: 158,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Guessing Time',
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 22 / 16,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'ลองทายดูสิ! คิดว่าคุณเข้าใจคู่ของคุณดีแค่ไหน?',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 20 / 14,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RuleBullet(text: '5 คำถามจากบทสนทนาของคุณทั้งคู่'),
                    SizedBox(height: 14),
                    _RuleBullet(text: 'แต่ละข้อมี 4 ตัวเลือก'),
                    SizedBox(height: 14),
                    _RuleBullet(text: 'ตอบให้ตรงกับคู่ของคุณให้ได้มากที่สุด'),
                  ],
                ),
              ),
              const Spacer(),
              Center(
                child: Text(
                  _statusText(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 20 / 14,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '$readyCount/2',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 20 / 14,
                  ),
                ),
              ),
              if (_remainingSeconds != null) ...[
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'เหลือเวลา $_remainingSeconds วินาที',
                    style: TextStyle(
                      color: (_remainingSeconds ?? 0) <= 10
                          ? AppColors.error
                          : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 18 / 12,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PlayerReadyAvatar(
                    label: 'คุณ',
                    imageProvider: _myImageProvider,
                    imageUrl: widget.myAvatarUrl,
                    isReady: widget.isMeReady,
                  ),
                  const SizedBox(width: 22),
                  const Icon(
                    Icons.favorite_rounded,
                    color: AppColors.brandPrimary,
                    size: 24,
                  ),
                  const SizedBox(width: 22),
                  _PlayerReadyAvatar(
                    label: 'คู่',
                    imageProvider: _partnerImageProvider,
                    imageUrl: widget.partnerAvatarUrl,
                    isReady: widget.isPartnerReady,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: 231,
                  child: DsButton(
                    label: widget.isMeReady ? 'กำลังรอ' : 'เตรียมพร้อม',
                    onPressed: widget.isMeReady ? null : widget.onReady,
                    variant: DsButtonVariant.primary,
                    size: DsButtonSize.md,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackCircleButton extends StatelessWidget {
  const _BackCircleButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: AppColors.brandSecondary,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

class _RuleBullet extends StatelessWidget {
  const _RuleBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Icon(Icons.circle, size: 5, color: AppColors.textBlack),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textBlack,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 20 / 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _PlayerReadyAvatar extends StatelessWidget {
  const _PlayerReadyAvatar({
    required this.label,
    required this.imageProvider,
    required this.imageUrl,
    required this.isReady,
  });

  final String label;
  final ImageProvider? imageProvider;
  final String? imageUrl;
  final bool isReady;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.textBlack,
            border: Border.all(
              color: isReady ? AppColors.brandPrimary : AppColors.textBlack,
              width: 2,
            ),
            image: imageProvider != null
                ? DecorationImage(image: imageProvider!, fit: BoxFit.cover)
                : null,
          ),
          child: imageProvider == null
              ? const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 34,
                )
              : null,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textBlack,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 20 / 14,
          ),
        ),
      ],
    );
  }
}
