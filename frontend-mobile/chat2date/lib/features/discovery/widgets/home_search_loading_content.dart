import 'package:chat2date/core/theme/app_assets.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeSearchLoadingContent extends StatefulWidget {
  const HomeSearchLoadingContent({super.key});

  @override
  State<HomeSearchLoadingContent> createState() =>
      _HomeSearchLoadingContentState();
}

class _HomeSearchLoadingContentState extends State<HomeSearchLoadingContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _rippleCount = 4;
  static const _baseColor = AppColors.brandPrimary;
  static const _maxScale = 3.5;
  static const _centerSize = 200.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final textCardWidth = (screenWidth - 32).clamp(280.0, 358.0);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;

        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 389,
                  height: 335,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      for (int i = 0; i < _rippleCount; i++)
                        _buildRippleHeart(t, i),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Opacity(
                            opacity: 0.24,
                            child: Transform.scale(
                              scale: 1.13,
                              child: ColorFiltered(
                                colorFilter: const ColorFilter.mode(
                                  AppColors.textOnDark,
                                  BlendMode.srcATop,
                                ),
                                child: SvgPicture.asset(
                                  AppAssets.heartOnlyIcon,
                                  width: _centerSize,
                                  height: _centerSize,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          Transform.scale(
                            scale: 1.065,
                            child: ColorFiltered(
                              colorFilter: const ColorFilter.mode(
                                AppColors.textOnDark,
                                BlendMode.srcATop,
                              ),
                              child: SvgPicture.asset(
                                AppAssets.heartOnlyIcon,
                                width: _centerSize,
                                height: _centerSize,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          SvgPicture.asset(
                            AppAssets.heartOnlyIcon,
                            width: _centerSize,
                            height: _centerSize,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: textCardWidth,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: const Text(
                    'กำลังค้นหาคนที่ใช่สำหรับคุณ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      height: 24 / 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandPrimary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRippleHeart(double t, int index) {
    final stagger = index / _rippleCount;
    final progress = ((t + stagger) % 1.0);

    final scale = 1.0 + (progress * (_maxScale - 1.0));
    final opacity = (1.0 - progress).clamp(0.0, 0.6);

    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: SizedBox(
          width: _centerSize,
          height: _centerSize,
          child: FittedBox(
            fit: BoxFit.contain,
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                _baseColor,
                BlendMode.srcATop,
              ),
              child: SvgPicture.asset(
                AppAssets.heartOnlyIcon,
                width: _centerSize,
                height: _centerSize,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
