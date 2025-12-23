import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoadingView extends StatefulWidget {
  final VoidCallback onBothComplete;

  const LoadingView({super.key, required this.onBothComplete});

  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView>
    with SingleTickerProviderStateMixin {
  int _partnerProgress = 0;
  final int _totalQuestions = 5;

  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();

    // controller สำหรับหมุน SVG
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _simulatePartnerProgress();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _simulatePartnerProgress() {
    // Mock: คู่ทำข้อละ 1.5 วินาที
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      if (_partnerProgress < _totalQuestions) {
        setState(() => _partnerProgress++);
        _simulatePartnerProgress();
      } else {
        // คู่ตอบครบแล้ว รออีกนิดแล้วไปหน้า result
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            widget.onBothComplete();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                          '$_partnerProgress/$_totalQuestions ข้อ',
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
                      value: _partnerProgress / _totalQuestions,
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
