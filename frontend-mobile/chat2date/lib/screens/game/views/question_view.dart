import 'package:flutter/material.dart';

class QuestionView extends StatelessWidget {
  final int currentQuestion;
  final Function(int) onAnswer;

  const QuestionView({
    super.key,
    required this.currentQuestion,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final questionNumber = currentQuestion + 1;
    final totalQuestions = 5;

    final question = 'คู่เดตของคุณชอบเล่นกีฬาประเภทไหน';
    final options = [
      'กีฬาในร่ม เช่น ฟิตเนส โยคะ',
      'กีฬากลางแจ้ง เช่น วิ่ง ปั่นจักรยาน',
      'กีฬาทีม เช่น ฟุตบอล บาส',
      'ไม่ชอบเล่นกีฬา',
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 130),

            // Question number
            Text(
              'คำถามข้อที่ $questionNumber/$totalQuestions',
              style: TextStyle(
                color: const Color(0xFF0F172A) /* Light-Text-Primary */,
                fontSize: 32,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 16),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: questionNumber / totalQuestions,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF5CE1E6),
                ),
                minHeight: 8,
              ),
            ),

            const SizedBox(height: 40),

            // Question text
            Text(
              question,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 22,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 40),

            // Answer options
            Expanded(
              child: ListView.separated(
                itemCount: options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 30),
                itemBuilder: (context, index) {
                  return _buildAnswerButton(
                    text: options[index],
                    onPressed: () => onAnswer(index),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFF8FB3), width: 1.5),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFFFF8FB3),
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
