import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:chat2date/theme/app_assets.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DsLevelProgressBar extends StatefulWidget {
  const DsLevelProgressBar({
    super.key,
    required this.level,
    required this.progress,
    this.width = 322,
    this.barWidth = 255,
    this.barThickness = 10,
    this.heartWidth = 25,
    this.heartHeight = 22,
    this.trailingIconSize = 20,
    this.onInfoTap,
  });

  final int level;
  final double progress;
  final double width;
  final double barWidth;
  final double barThickness;
  final double heartWidth;
  final double heartHeight;
  final double trailingIconSize;
  final VoidCallback? onInfoTap;

  @override
  State<DsLevelProgressBar> createState() => _DsLevelProgressBarState();
}

class _DsLevelProgressBarState extends State<DsLevelProgressBar>
    with TickerProviderStateMixin {
  late final AnimationController _valueController;
  late final AnimationController _rainbowController;

  double _fromProgress = 0;
  double _toProgress = 0;
  bool _infoPressed = false;

  static const List<Color> _rainbowColors = [
    Color(0xFFC8A2E7),
    Color(0xFF9FBBFF),
    Color(0xFFA7EAF2),
    Color(0xFFB7E4C7),
    Color(0xFFFFF1A8),
    Color(0xFFFFD1A6),
    Color(0xFFFFB3B3),
  ];

  int get _effectiveLevel => widget.level.clamp(0, 3);
  bool get _isLevelMax => _effectiveLevel == 3;
  double get _effectiveTargetProgress =>
      _isLevelMax ? 1 : widget.progress.clamp(0.0, 1.0);

  @override
  void initState() {
    super.initState();
    _toProgress = _effectiveTargetProgress;
    _valueController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    )..value = 1;
    _rainbowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );
    if (_isLevelMax) {
      _rainbowController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant DsLevelProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    final nextTarget = _effectiveTargetProgress;
    final currentDisplayed = _displayedProgress;
    if ((nextTarget - _toProgress).abs() > 0.0001) {
      _fromProgress = currentDisplayed;
      _toProgress = nextTarget;
      _valueController
        ..stop()
        ..forward(from: 0);
    }

    if (_isLevelMax) {
      if (!_rainbowController.isAnimating) {
        _rainbowController.repeat();
      }
    } else {
      _rainbowController
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    _rainbowController.dispose();
    super.dispose();
  }

  double get _displayedProgress {
    final curve = Curves.easeOutCubic.transform(_valueController.value);
    return ui.lerpDouble(_fromProgress, _toProgress, curve) ?? _toProgress;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_valueController, _rainbowController]),
      builder: (context, _) {
        final displayedProgress = _displayedProgress.clamp(0.0, 1.0);
        final isDecreasing = _fromProgress > _toProgress;
        final baseProgress = isDecreasing ? _toProgress : displayedProgress;
        final decreaseOverlay = isDecreasing
            ? (displayedProgress - _toProgress).clamp(0.0, 1.0)
            : 0.0;

        return SizedBox(
          width: widget.width,
          height: 25,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeart(),
              SizedBox(
                width: widget.barWidth,
                height: 24,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: widget.barWidth,
                        height: widget.barThickness,
                        decoration: BoxDecoration(
                          color: AppColors.divider,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _buildFill(
                        widthFactor: baseProgress,
                        color: _isLevelMax ? null : AppColors.brandPrimary,
                        gradient: _isLevelMax
                            ? _animatedRainbowGradient
                            : null,
                      ),
                    ),
                    if (decreaseOverlay > 0)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: widget.barWidth * _toProgress,
                          ),
                          child: _buildFill(
                            widthFactor: decreaseOverlay,
                            color: AppColors.brandSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: widget.onInfoTap,
                onTapDown: (_) => setState(() => _infoPressed = true),
                onTapUp: (_) => setState(() => _infoPressed = false),
                onTapCancel: () => setState(() => _infoPressed = false),
                behavior: HitTestBehavior.opaque,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 140),
                  curve: Curves.easeOut,
                  offset: _infoPressed ? const Offset(0, -0.08) : Offset.zero,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 140),
                    curve: Curves.easeOut,
                    scale: _infoPressed ? 1.04 : 1,
                    child: SvgPicture.asset(
                      AppAssets.statusInfoIcon,
                      width: widget.trailingIconSize,
                      height: widget.trailingIconSize,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFill({
    required double widthFactor,
    Color? color,
    Gradient? gradient,
  }) {
    return FractionallySizedBox(
      widthFactor: widthFactor.clamp(0.0, 1.0),
      child: Container(
        height: widget.barThickness,
        decoration: BoxDecoration(
          color: color,
          gradient: gradient,
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }

  Widget _buildHeart() {
    if (_isLevelMax) {
      return ShaderMask(
        shaderCallback: (bounds) => _animatedRainbowGradient.createShader(bounds),
        blendMode: BlendMode.srcIn,
        child: SizedBox(
          width: widget.heartWidth,
          height: widget.heartHeight,
          child: SvgPicture.asset(
            AppAssets.statusHeartIcon,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: widget.heartWidth,
      height: widget.heartHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            AppAssets.statusHeartIcon,
            width: widget.heartWidth,
            height: widget.heartHeight,
          ),
          if (_effectiveLevel > 0)
            Text(
              '$_effectiveLevel',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1,
                fontFamily: 'Inter',
              ),
            ),
        ],
      ),
    );
  }

  Gradient get _animatedRainbowGradient {
    final shiftedColors = _buildShiftedRainbowColors(_rainbowController.value);
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: shiftedColors,
    );
  }

  List<Color> _buildShiftedRainbowColors(double progress) {
    final count = _rainbowColors.length;
    final shifted = progress * count;
    final baseIndex = shifted.floor() % count;
    final t = shifted - shifted.floor();

    return List<Color>.generate(count, (index) {
      final current = _rainbowColors[(baseIndex + index) % count];
      final next = _rainbowColors[(baseIndex + index + 1) % count];
      return Color.lerp(current, next, _ease(t)) ?? current;
    });
  }

  double _ease(double t) {
    return 0.5 - math.cos(t * math.pi) / 2;
  }
}
