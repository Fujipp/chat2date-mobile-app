import 'dart:async';

import 'package:chat2date/core/theme/app_assets.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MatchSuccessArgs {
  final int? matchId;
  final String partnerUserId;
  final String myName;
  final String partnerName;
  final String? myAvatarUrl;
  final String? partnerAvatarUrl;

  const MatchSuccessArgs({
    this.matchId,
    required this.partnerUserId,
    required this.myName,
    required this.partnerName,
    this.myAvatarUrl,
    this.partnerAvatarUrl,
  });
}

class MatchSuccessScreen extends StatefulWidget {
  static const routeName = '/match-success';

  final MatchSuccessArgs args;

  const MatchSuccessScreen({
    super.key,
    required this.args,
  });

  @override
  State<MatchSuccessScreen> createState() => _MatchSuccessScreenState();
}

class _MatchSuccessScreenState extends State<MatchSuccessScreen>
    with TickerProviderStateMixin {
  late final AnimationController _enterController;
  late final AnimationController _heartRippleController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  Timer? _navigateTimer;

  @override
  void initState() {
    super.initState();

    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _enterController,
      curve: Curves.easeOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.94, end: 1).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: Curves.easeOutCubic,
      ),
    );

    _enterController.forward();
    _heartRippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _navigateTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      final route = ModalRoute.of(context);
      if (route?.isCurrent != true) return;

      final args = widget.args;
      Navigator.of(context).pushReplacementNamed(
        '/chat',
        arguments: {
          'roomId': args.matchId?.toString(),
          'targetUserId': args.partnerUserId,
          'userName': args.partnerName,
          'avatarUrl': args.partnerAvatarUrl,
        },
      );
    });
  }

  @override
  void dispose() {
    _navigateTimer?.cancel();
    _enterController.dispose();
    _heartRippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    const Spacer(flex: 8),
                    Text(
                      'MATCH',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        height: 32 / 28,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const SizedBox(height: 52),
                    _MatchArtwork(
                      animation: _heartRippleController,
                      myName: args.myName,
                      partnerName: args.partnerName,
                      myAvatarUrl: args.myAvatarUrl,
                      partnerAvatarUrl: args.partnerAvatarUrl,
                    ),
                    const SizedBox(height: 60),
                    const SizedBox(
                      width: 310,
                      child: Text(
                        'คุณได้คู่แล้วระบบจะนำไปสู่ห้องแชท',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 20 / 14,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                    const Spacer(flex: 11),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MatchArtwork extends StatelessWidget {
  final Animation<double> animation;
  final String myName;
  final String partnerName;
  final String? myAvatarUrl;
  final String? partnerAvatarUrl;

  const _MatchArtwork({
    required this.animation,
    required this.myName,
    required this.partnerName,
    this.myAvatarUrl,
    this.partnerAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;

        return SizedBox(
          width: 310,
          height: 360,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Positioned.fill(child: _HeartRippleBackdrop(progress: t)),
              Positioned(
                top: 92,
                left: 14,
                child: _MatchUserCircle(
                  name: myName,
                  imageUrl: myAvatarUrl,
                ),
              ),
              Positioned(
                top: 92,
                right: 14,
                child: _MatchUserCircle(
                  name: partnerName,
                  imageUrl: partnerAvatarUrl,
                ),
              ),
              Positioned(
                top: 100,
                child: SvgPicture.asset(
                  AppAssets.heartOnlyIcon,
                  width: 184,
                  height: 156,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeartRippleBackdrop extends StatelessWidget {
  final double progress;

  const _HeartRippleBackdrop({required this.progress});

  static const double _centerSize = 200;
  static const int _rippleCount = 4;
  static const double _maxScale = 3.5;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        for (int i = 0; i < _rippleCount; i++)
          Positioned(
            top: 58,
            child: _MatchRippleHeart(
              progress: progress,
              index: i,
              centerSize: _centerSize,
              maxScale: _maxScale,
            ),
          ),
      ],
    );
  }
}

class _MatchRippleHeart extends StatelessWidget {
  final double progress;
  final int index;
  final double centerSize;
  final double maxScale;

  const _MatchRippleHeart({
    required this.progress,
    required this.index,
    required this.centerSize,
    required this.maxScale,
  });

  @override
  Widget build(BuildContext context) {
    final stagger = index / _HeartRippleBackdrop._rippleCount;
    final rippleProgress = ((progress + stagger) % 1.0);
    final scale = 1.0 + (rippleProgress * (maxScale - 1.0));
    final opacity = (1.0 - rippleProgress).clamp(0.0, 0.52);

    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: ColorFiltered(
          colorFilter: const ColorFilter.mode(
            AppColors.brandPrimary,
            BlendMode.srcATop,
          ),
          child: SvgPicture.asset(
            AppAssets.heartOnlyIcon,
            width: centerSize,
            height: centerSize,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _MatchUserCircle extends StatelessWidget {
  final String name;
  final String? imageUrl;

  const _MatchUserCircle({
    required this.name,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 100,
            height: 182,
            child: OverflowBox(
              minWidth: 182,
              maxWidth: 182,
              minHeight: 182,
              maxHeight: 182,
              alignment: Alignment.topCenter,
              child: Container(
                width: 182,
                height: 182,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.surface,
                    width: 26,
                  ),
                ),
                child: ClipOval(
                  child: imageUrl != null && imageUrl!.isNotEmpty
                      ? Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildIconFallback(),
                        )
                      : _buildIconFallback(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 20 / 14,
              color: AppColors.textBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconFallback() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
      ),
      child: ColorFiltered(
        colorFilter: const ColorFilter.mode(
          AppColors.surface,
          BlendMode.srcIn,
        ),
        child: SvgPicture.asset(
          AppAssets.headerSecondaryAvatar,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
