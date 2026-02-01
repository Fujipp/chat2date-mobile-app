import 'dart:math';
import 'package:flutter/material.dart';
import 'package:chat2date/theme/app_colors.dart';

class MatchSuccessArgs {
  final int? matchId;  // roomId for navigating to chat
  final String partnerUserId;  // target user for chat
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

// Main animation controller for entrance animations
class _MatchSuccessScreenState extends State<MatchSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _heartController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Main entrance animation (fade + scale for match card)
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Looping animation for floating hearts in background
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Trigger entrance animation
    _mainController.forward();

    // ✅ ตั้ง timer 5 วิ แล้วไปหน้า chat
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      final args = widget.args;
      // Navigate to chat screen with matchId as roomId
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
    _mainController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Romantic gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.btnPrimary.withOpacity(0.15),
                  Colors.white,
                  AppColors.btnPrimary.withOpacity(0.1),
                ],
              ),
            ),
          ),

          // Floating hearts background animation
          _FloatingHeartsBackground(animation: _heartController),

          // Main content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Animated match card with fade + scale
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: _MatchCard(args: args),
                      ),
                    ),

                    const Spacer(flex: 1),

                    // Animated subtitle with slide
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          'คุณได้คู่แล้วเราจะนำไปสู่การแชท',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Match card layout with avatars and title
class _MatchCard extends StatelessWidget {
  final MatchSuccessArgs args;

  const _MatchCard({required this.args});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.btnPrimary.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // "It's a match!" title
          Text(
            'จับคู่สำเร็จ! 💕',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.btnPrimary,
            ),
          ),
          const SizedBox(height: 40),

          // Overlapping avatars with heart - wider spacing
          SizedBox(
            width: 280, // Increased width to prevent overlap
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Left avatar (my avatar)
                Positioned(
                  left: 0,
                  child: _MatchUserAvatar(
                    name: args.myName,
                    imageUrl: args.myAvatarUrl,
                    size: 100,
                  ),
                ),

                // Right avatar (partner avatar)
                Positioned(
                  right: 0,
                  child: _MatchUserAvatar(
                    name: args.partnerName,
                    imageUrl: args.partnerAvatarUrl,
                    size: 100,
                  ),
                ),

                // Center heart icon
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.btnPrimary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.btnPrimary.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 60),

          // Names row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Text(
                  args.myName,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                child: Text(
                  args.partnerName,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MatchUserAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double size;

  const _MatchUserAvatar({
    required this.name,
    this.imageUrl,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFE2E8F0),
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: const Color(0xFF64748B),
      ),
    );
  }
}

// Animated button with scale micro-interaction on tap
class _AnimatedButton extends StatefulWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _AnimatedButton({
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: widget.isPrimary
                ? AppColors.btnPrimary
                : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: widget.isPrimary
                ? null
                : Border.all(color: AppColors.btnPrimary, width: 2),
            boxShadow: [
              if (widget.isPrimary)
                BoxShadow(
                  color: AppColors.btnPrimary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: widget.isPrimary
                  ? Colors.white
                  : AppColors.btnPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

// Floating hearts background animation (subtle looping particles)
class _FloatingHeartsBackground extends StatelessWidget {
  final Animation<double> animation;

  const _FloatingHeartsBackground({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          children: List.generate(8, (index) {
            final random = Random(index);
            final xPos = random.nextDouble();
            final yOffset = (animation.value + random.nextDouble()) % 1.0;
            final size = 20.0 + random.nextDouble() * 20;
            final opacity = (1.0 - yOffset) * 0.3;

            return Positioned(
              left: MediaQuery.of(context).size.width * xPos,
              top: MediaQuery.of(context).size.height * yOffset,
              child: Opacity(
                opacity: opacity,
                child: Icon(
                  Icons.favorite,
                  size: size,
                  color: AppColors.btnPrimary,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
