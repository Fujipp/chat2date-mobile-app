import 'package:flutter/material.dart';
import 'stacked_progress_bar.dart';
import 'score_row.dart';

class StatusBarExample extends StatelessWidget {
  const StatusBarExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 362,
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFF9747FF)),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScoreRow(
            segments: [
              ProgressSegment(percent: 0.27, color: Color(0xFFFF8FB3)),
              ProgressSegment(percent: 0.34, color: Color(0xFFFFD166)),
            ],
          ),
          const SizedBox(height: 12),
          const ScoreRow(
            segments: [
              ProgressSegment(percent: 0.35, color: Color(0xFFFF8FB3)),
            ],
          ),
          const SizedBox(height: 12),
          const ScoreRow(
            leading: ScoreLeading.number,
            numberText: '1',
            segments: [
              ProgressSegment(percent: 0.50, color: Color(0xFFFF8FB3)),
            ],
          ),
          const SizedBox(height: 12),
          const ScoreRow(
            leading: ScoreLeading.number,
            numberText: '2',
            segments: [
              ProgressSegment(percent: 0.74, color: Color(0xFFFF8FB3)),
            ],
          ),
          const SizedBox(height: 12),
          ScoreRow(
            leading: ScoreLeading.none,
            segments: const [
              ProgressSegment(
                percent: 0.60,
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFFC8A2E7),
                    Color(0xFF9FBBFF),
                    Color(0xFFA7EAF2),
                    Color(0xFFB7E4C7),
                    Color(0xFFFFF1A8),
                    Color(0xFFFFD1A6),
                    Color(0xFFFFB3B3),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
