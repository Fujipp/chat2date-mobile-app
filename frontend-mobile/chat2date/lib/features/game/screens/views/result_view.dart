import 'dart:math' as math;

import 'package:chat2date/components/design_system/buttons/ds_button.dart';
import 'package:chat2date/components/design_system/organisms/ds_bot_chat.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ResultView extends StatelessWidget {
  final int score;
  final int matchedAnswers;
  final int totalQuestions;
  final VoidCallback onFinish;
  final int? relationshipScore;
  final String myAvatarUrl;
  final String partnerAvatarUrl;
  final int myScore;
  final int partnerScore;

  const ResultView({
    super.key,
    required this.score,
    required this.matchedAnswers,
    required this.totalQuestions,
    required this.onFinish,
    required this.myAvatarUrl,
    required this.partnerAvatarUrl,
    required this.myScore,
    required this.partnerScore,
    this.relationshipScore,
  });

  @override
  Widget build(BuildContext context) {
    final baseScore = relationshipScore ?? 0;
    final gameBonus = matchedAnswers;
    final totalRelationshipScore = baseScore + gameBonus;
    final totalPercent = (totalRelationshipScore / 100).clamp(0.0, 1.0);
    final basePercent = (baseScore / 100).clamp(0.0, 1.0);
    final hasPositiveResult = gameBonus > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 72, 16, 32),
          child: Column(
            children: [
              const Text(
                'สรุปผลคำตอบ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 22 / 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'คะแนนรวมกับของทั้งคู่ : $score',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 20 / 14,
                ),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: DsBotChat(
                  width: 310,
                  type: hasPositiveResult
                      ? DsBotChatType.askSuccess
                      : DsBotChatType.askFail,
                  title: hasPositiveResult
                      ? 'เยี่ยมมาก!'
                      : 'ครั้งหน้าต้องได้ดีกว่านี้',
                  description: hasPositiveResult
                      ? 'คุณกับคู่เดตตอบตรงกัน $gameBonus ข้อ และได้รับคะแนนความสัมพันธ์เพิ่ม'
                      : 'รอบนี้คำตอบยังไม่ค่อยตรงกัน ลองคุยกันอีกนิดแล้วกลับมาเล่นใหม่ได้',
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Column(
                  children: [
                    Text(
                      '+$gameBonus',
                      style: const TextStyle(
                        color: AppColors.textBlack,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 32 / 24,
                      ),
                    ),
                    const Text(
                      'คะแนนที่ได้รับ',
                      style: TextStyle(
                        color: AppColors.textBlack,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 20 / 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ResultProgressBar(
                      basePercent: basePercent,
                      totalPercent: totalPercent,
                      bonusLabel: '+$gameBonus',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'คะแนนความสัมพันธ์ = $totalRelationshipScore คะแนน',
                      style: const TextStyle(
                        color: AppColors.textBlack,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 20 / 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ResultPlayerScore(
                    label: 'คุณ',
                    score: myScore,
                    avatarUrl: myAvatarUrl,
                  ),
                  const SizedBox(width: 28),
                  const Icon(
                    Icons.favorite_rounded,
                    color: AppColors.brandPrimary,
                    size: 24,
                  ),
                  const SizedBox(width: 28),
                  _ResultPlayerScore(
                    label: 'คู่',
                    score: partnerScore,
                    avatarUrl: partnerAvatarUrl,
                  ),
                ],
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: 231,
                child: DsButton(
                  label: 'กลับ',
                  onPressed: onFinish,
                  variant: DsButtonVariant.primary,
                  size: DsButtonSize.md,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultProgressBar extends StatelessWidget {
  const _ResultProgressBar({
    required this.basePercent,
    required this.totalPercent,
    required this.bonusLabel,
  });

  final double basePercent;
  final double totalPercent;
  final String bonusLabel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;

        final double lowerBound = totalWidth * basePercent;
        final double upperBound = totalWidth - 40;

        final double safeUpperBound = math.max(lowerBound, upperBound);

        final bonusLeft = (totalWidth * totalPercent - 20).clamp(
          lowerBound,
          safeUpperBound,
        );

        return SizedBox(
          height: 26,
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3E3E6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              FractionallySizedBox(
                widthFactor: totalPercent,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD20A),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              FractionallySizedBox(
                widthFactor: basePercent,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Positioned(
                left: bonusLeft,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Text(
                    bonusLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 20 / 14,
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
}

class _ResultPlayerScore extends StatelessWidget {
  const _ResultPlayerScore({
    required this.label,
    required this.score,
    required this.avatarUrl,
  });

  final String label;
  final int score;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.inputBorder,
          backgroundImage: avatarUrl.isNotEmpty
              ? NetworkImage(avatarUrl)
              : null,
          child: avatarUrl.isEmpty
              ? const Icon(
                  Icons.person_rounded,
                  size: 34,
                  color: AppColors.textSecondary,
                )
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          '$score คะแนน',
          style: const TextStyle(
            color: AppColors.textBlack,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 20 / 14,
          ),
        ),
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
