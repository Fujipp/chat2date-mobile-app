import 'package:chat2date/core/theme/app_assets.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:chat2date/models/dto/game_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  static const _answerFeedbackDuration = Duration(milliseconds: 280);

  bool _isAnswered = false;
  String? _selectedOption;

  void _handleOptionTap(String option) {
    if (_isAnswered) return;

    setState(() {
      _isAnswered = true;
      _selectedOption = option;
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
          child: Column(
            children: [
              const Spacer(flex: 2),
              AnimatedSwitcher(
                duration: _answerFeedbackDuration,
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final slide = Tween<Offset>(
                    begin: const Offset(0.06, 0),
                    end: Offset.zero,
                  ).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: slide, child: child),
                  );
                },
                child: Container(
                  key: ValueKey(widget.questionData.questionId),
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(19, 22, 19, 18),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        AppAssets.questionIllustration,
                        width: 95,
                        height: 95,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.questionData.text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textBlack,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 22 / 16,
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: _answerFeedbackDuration,
                        child: !_isAnswered
                            ? const SizedBox(height: 18)
                            : Padding(
                                key: ValueKey<String?>(
                                  '${widget.questionData.questionId}$_selectedOption',
                                ),
                                padding: const EdgeInsets.only(top: 14, bottom: 2),
                                child: _AnswerStatusChip(
                                  isCorrect:
                                      _selectedOption ==
                                      widget.questionData.correct,
                                ),
                              ),
                      ),
                      if (!_isAnswered) const SizedBox(height: 18),
                      for (int index = 0;
                          index < widget.questionData.options.length;
                          index++) ...[
                        _QuestionOptionButton(
                          label: widget.questionData.options[index],
                          isAnswered: _isAnswered,
                          isSelected:
                              _selectedOption == widget.questionData.options[index],
                          isCorrect:
                              widget.questionData.correct ==
                              widget.questionData.options[index],
                          onTap: () =>
                              _handleOptionTap(widget.questionData.options[index]),
                        ),
                        if (index != widget.questionData.options.length - 1)
                          const SizedBox(height: 22),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '$questionNumber/${widget.totalQuestions}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 20 / 14,
                ),
              ),
              const SizedBox(height: 14),
              _QuestionProgressBar(
                value: questionNumber / widget.totalQuestions,
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionOptionButton extends StatelessWidget {
  const _QuestionOptionButton({
    required this.label,
    required this.isAnswered,
    required this.isSelected,
    required this.isCorrect,
    required this.onTap,
  });

  final String label;
  final bool isAnswered;
  final bool isSelected;
  final bool isCorrect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color background = AppColors.background;
    Color border = AppColors.textBlack;
    Color text = AppColors.textBlack;
    double scale = 1;
    double opacity = 1;
    List<BoxShadow>? boxShadow;

    if (isAnswered) {
      if (isCorrect) {
        background = const Color(0xFF8BF78D);
        border = const Color(0xFF3A9440);
        scale = 1.02;
        boxShadow = const [
          BoxShadow(
            color: Color(0x1A3A9440),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ];
      } else if (isSelected) {
        background = const Color(0xFFFF676C);
        border = const Color(0xFFD93439);
        scale = 1.02;
        boxShadow = const [
          BoxShadow(
            color: Color(0x1AD93439),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ];
      } else {
        opacity = 0.72;
      }
    }

    return AnimatedOpacity(
      duration: _QuestionViewState._answerFeedbackDuration,
      opacity: opacity,
      child: AnimatedScale(
        duration: _QuestionViewState._answerFeedbackDuration,
        curve: Curves.easeOutBack,
        scale: scale,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isAnswered ? null : onTap,
            borderRadius: BorderRadius.circular(22),
            child: AnimatedContainer(
              duration: _QuestionViewState._answerFeedbackDuration,
              curve: Curves.easeOutCubic,
              width: double.infinity,
              height: 61,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: border, width: 1.5),
                boxShadow: boxShadow,
              ),
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 20 / 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnswerStatusChip extends StatelessWidget {
  const _AnswerStatusChip({required this.isCorrect});

  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final background = isCorrect
        ? const Color(0x1F8BF78D)
        : const Color(0x1FFF676C);
    final border = isCorrect
        ? const Color(0xFF3A9440)
        : const Color(0xFFD93439);
    final label = isCorrect ? 'เลือกคำตอบนี้แล้ว' : 'ส่งคำตอบแล้ว';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: border,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 16 / 12,
        ),
      ),
    );
  }
}

class _QuestionProgressBar extends StatelessWidget {
  const _QuestionProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        width: 290,
        child: LinearProgressIndicator(
          value: value.clamp(0.0, 1.0),
          backgroundColor: const Color(0xFFE3E3E6),
          valueColor: const AlwaysStoppedAnimation<Color>(
            AppColors.brandPrimary,
          ),
          minHeight: 10,
        ),
      ),
    );
  }
}
