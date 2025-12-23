import 'package:chat2date/components/buttons/ds_button.dart';
import 'package:flutter/material.dart';

class ResultView extends StatelessWidget {
  final int score;
  final int matchedAnswers;
  final int totalQuestions;
  final VoidCallback onFinish;
  final int? relationshipScore; // คะแนนจาก relationship tracking (optional)

  const ResultView({
    super.key,
    required this.score,
    required this.matchedAnswers,
    required this.totalQuestions,
    required this.onFinish,
    this.relationshipScore, // ถ้าไม่ส่งมาจะใช้ค่า default
  });

  String get userAvatarUrl =>
      'https://res.cloudinary.com/dov7wgzv1/image/upload/v1764667953/chat2date_users/q1vahx2j70ixeluypklw.jpg';
  String get partnerAvatarUrl =>
      'https://res.cloudinary.com/dov7wgzv1/image/upload/v1764668236/chat2date_users/xflsgk1stvlx48ntfe84.png';

  @override
  Widget build(BuildContext context) {
    // คะแนนจาก relationship tracking (สีชมพู)
    final baseScore = relationshipScore ?? 50; // Default 50 ถ้าไม่มี

    // คะแนนที่ได้จากเกมครั้งนี้ (สีเขียว)
    final gameBonus = matchedAnswers;

    // คะแนนรวมทั้งหมด
    final totalScore = baseScore + gameBonus;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          children: [
            const SizedBox(height: 60),

            // Title
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'สรุปผลคำตอบ',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 32,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'คะแนนรวมของทั้งคู่: $totalScore',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 20,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Score display with gradient progress bar
            _buildScoreProgress(
              baseScore: baseScore,
              gameBonus: gameBonus,
              totalScore: totalScore,
            ),
            const SizedBox(height: 20),
            // Player scores
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPlayerScore(
                  label: 'คุณ',
                  score: (matchedAnswers / 2).ceil(),
                  avatarUrl: userAvatarUrl, // ต้องมี
                ),
                const SizedBox(width: 50),
                _buildPlayerScore(
                  label: 'คู่',
                  score: (matchedAnswers / 2).floor(),
                  avatarUrl: partnerAvatarUrl, // ต้องมี
                ),
              ],
            ),

            const SizedBox(height: 50),

            // Finish button
            SizedBox(
              width: double.infinity,
              child: DsButton(
                label: 'กลับ',
                onPressed: onFinish,
                variant: DsButtonVariant.primary,
                size: DsButtonSize.md,
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreProgress({
    required int baseScore,
    required int gameBonus,
    required int totalScore,
  }) {
    // คำนวณเปอร์เซ็นต์สำหรับ progress bar (สมมติว่าเต็ม 100 คะแนน)
    final maxScore = 100.0;
    final basePercent = (baseScore / maxScore).clamp(0.0, 1.0);
    final totalPercent = (totalScore / maxScore).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        children: [
          // Score number (คะแนนที่ได้จากเกม)
          Text(
            '+$gameBonus',
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 48,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'คะแนนที่ได้รับ',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 24),

          // Progress bar with gradient - ใช้ LayoutBuilder เพื่อเข้าถึงความกว้าง
          LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth;

              return Container(
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Stack(
                  children: [
                    // Background (gray) - แสดงเต็ม bar
                    Container(
                      width: double.infinity,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),

                    // Total progress (green + pink combined)
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: totalPercent,
                      child: Container(
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFF98FB98), // สีเขียว (คะแนนรวม)
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),

                    // Base score (pink) - คะแนน relationship tracking
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: basePercent,
                      child: Container(
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFFF8FB3,
                          ), // สีชมพู (relationship tracking)
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),

                    // Score text on the bar
                    if (gameBonus > 0)
                      Positioned(
                        left: (basePercent * barWidth).clamp(
                          20.0,
                          barWidth - 40,
                        ),
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Text(
                            '+$gameBonus',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Score breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildScoreInfo(
                color: const Color(0xFFFF8FB3),
                label: 'คะแนนความสัมพันธ์',
                score: baseScore,
              ),
              const SizedBox(width: 16),
              const Text(
                '+',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              _buildScoreInfo(
                color: const Color(0xFF98FB98),
                label: 'เกมนี้',
                score: gameBonus,
              ),
              const SizedBox(width: 16),
              const Text(
                '=',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '$totalScore คะแนน',
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreInfo({
    required Color color,
    required String label,
    required int score,
  }) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 10,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '$score',
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerScore({
    required String label,
    required int score,
    required String avatarUrl,
  }) {
    return Column(
      children: [
        // Avatar
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE2E8F0), width: 3),
            image: DecorationImage(
              image: NetworkImage(avatarUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Score
        Text(
          '$score คะแนน',
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 4),

        // Label
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
