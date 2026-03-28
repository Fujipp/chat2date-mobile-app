import 'package:chat2date/models/dto/game_dto.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class QuestionView extends StatefulWidget {
  final int currentQuestionIndex;
  final int totalQuestions;
  final GameQuestionDto questionData;
  final Function(String) onAnswer;

  const QuestionView({
    super.key,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    required this.questionData,
    required this.onAnswer,
  });

  @override
  State<QuestionView> createState() => _QuestionViewState();
}

class _QuestionViewState extends State<QuestionView> {
  bool _isAnswered = false;
  String? _selectedOption;

  void _handleOptionTap(String option) {
    if (_isAnswered) return;

    setState(() {
      _isAnswered = true;
      _selectedOption = option;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      widget.onAnswer(option);
    });
  }

  @override
  void didUpdateWidget(covariant QuestionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.questionData.questionId != widget.questionData.questionId) {
      setState(() {
        _isAnswered = false;
        _selectedOption = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionNumber = widget.currentQuestionIndex + 1;

    return Scaffold(
      backgroundColor: AppColors.surface, 
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // --- Header & Progress Bar ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.brandPrimary200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'ข้อที่ $questionNumber/${widget.totalQuestions}',
                      style: const TextStyle(
                        color: AppColors.brandOnPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: questionNumber / widget.totalQuestions,
                        backgroundColor: AppColors.neutral200,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.brandPrimary,
                        ),
                        minHeight: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- Question Card (กล่องคำถาม) ---
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandAccentStrong.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.psychology_alt_rounded, size: 40, color: AppColors.brandPrimary),
                    const SizedBox(height: 16),
                    
                    Text(
                      widget.questionData.text,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // --- Answer Options ---
                    Expanded(
                      child: ListView.separated(
                        itemCount: widget.questionData.options.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final option = widget.questionData.options[index];
                          return _CuteAnswerButton(
                            option: option,
                            isSelected: _isAnswered && _selectedOption == option,
                            isCorrect: _isAnswered && widget.questionData.correct == option,
                            isAnswered: _isAnswered,
                            onTap: () => _handleOptionTap(option),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget ปุ่ม: ปรับสีเป็นชมพูน่ารัก 💖
class _CuteAnswerButton extends StatelessWidget {
  final String option;
  final bool isSelected;
  final bool isCorrect;
  final bool isAnswered;
  final VoidCallback onTap;

  const _CuteAnswerButton({
    required this.option,
    required this.isSelected,
    required this.isCorrect,
    required this.isAnswered,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 🎨 Palette สี
    const pinkMain = Color(0xFFFF8FB3); // ชมพูหลัก (ตาม Theme surfaceLight)
    
    // Default State (ยังไม่ตอบ)
    Color bgColor = Colors.white;
    Color borderColor = pinkMain.withOpacity(0.5); // ขอบชมพูอ่อน
    Color textColor = pinkMain;
    double borderWidth = 1.5;
    IconData? icon;
    List<BoxShadow> shadows = [
      BoxShadow(
        color: pinkMain.withOpacity(0.1), // เงาชมพูจางๆ
        blurRadius: 8,
        offset: const Offset(0, 4),
      )
    ];

    if (isAnswered) {
      if (isCorrect) {
        // ✅ ถูก: เขียว
        bgColor = AppColors.success.withOpacity(0.2);
        borderColor = AppColors.success;
        textColor = AppColors.successText;
        icon = Icons.check_circle_rounded;
        shadows = [];
      } else if (isSelected) {
        // ❌ ผิด: แดง
        bgColor = AppColors.error.withOpacity(0.1);
        borderColor = AppColors.error;
        textColor = AppColors.error;
        icon = Icons.cancel_rounded;
        shadows = [];
      } else {
        // ⚪ ไม่เกี่ยว: จางลง
        bgColor = AppColors.neutral50;
        borderColor = AppColors.neutral200;
        textColor = AppColors.textMuted;
        shadows = [];
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        // ใช้ easeOutCubic ปลอดภัย ไม่พังแน่นอน
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic, 
        margin: EdgeInsets.symmetric(horizontal: isSelected ? 0 : 4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24), // มนๆ น่ารัก
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: shadows,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: isSelected || isCorrect ? FontWeight.w700 : FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(icon, color: textColor, size: 24),
            ]
          ],
        ),
      ),
    );
  }
}