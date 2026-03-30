import 'package:chat2date/core/theme/app_assets.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoadingView extends StatefulWidget {
  final VoidCallback onBothComplete;
  final int partnerProgress;
  final int totalQuestions;

  const LoadingView({
    super.key,
    required this.onBothComplete,
    required this.partnerProgress,
    required this.totalQuestions,
  });

  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant LoadingView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.partnerProgress >= widget.totalQuestions &&
        oldWidget.partnerProgress < oldWidget.totalQuestions) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onBothComplete();
      });
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.totalQuestions == 0
        ? 0.0
        : widget.partnerProgress / widget.totalQuestions;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
          child: Column(
            children: [
              const Spacer(flex: 2),
              RotationTransition(
                turns: CurvedAnimation(
                  parent: _rotationController,
                  curve: Curves.linear,
                ),
                child: SvgPicture.asset(
                  AppAssets.loadingIllustration,
                  width: 130,
                  height: 130,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'โปรดรอคู่เดตของคุณ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 22 / 16,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'ตอบคำถามเสร็จ..',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 20 / 14,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'คู่ของคุณตอบไปแล้ว',
                        style: TextStyle(
                          color: AppColors.textBlack,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 20 / 14,
                        ),
                      ),
                    ),
                    Text(
                      '${widget.partnerProgress}/${widget.totalQuestions} ข้อ',
                      style: const TextStyle(
                        color: AppColors.brandPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 20 / 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: SizedBox(
                  width: 344,
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: const Color(0xFFE3E3E6),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.brandPrimary,
                    ),
                    minHeight: 10,
                  ),
                ),
              ),
              const Spacer(flex: 4),
            ],
          ),
        ),
      ),
    );
  }
}
