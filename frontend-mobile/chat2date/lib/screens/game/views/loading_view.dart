import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final partnerProgress = widget.partnerProgress;
    final totalQuestions = widget.totalQuestions;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          children: [
            const SizedBox(height: 130),

            // ===== Loading animation (SVG หมุน) =====
            Container(
              child: Center(
                child: RotationTransition(
                  turns: CurvedAnimation(
                    parent: _rotationController,
                    curve: Curves.linear,
                  ),
                  child: SvgPicture.asset(
                    'assets/images/loading.svg',
                    width: 130,
                    height: 130,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 80),

            // ===== Text & Progress =====
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'โปรดรอคู่เดตของคุณ',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 28,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ตอบคำถามเสร็จ..',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 20,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Progress info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'คู่ของคุณตอบไปแล้ว',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '$partnerProgress/$totalQuestions ข้อ',
                          style: const TextStyle(
                            color: Color(0xFF5CE1E6),
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Linear progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: totalQuestions > 0
                          ? partnerProgress / totalQuestions
                          : 0.0,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF5CE1E6),
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
