import 'package:chat2date/screens/game/views/loading_view.dart';
import 'package:chat2date/screens/game/views/question_view.dart';
import 'package:chat2date/screens/game/views/result_view.dart';
import 'package:chat2date/screens/game/views/waiting_view.dart';
import 'package:chat2date/stores/game_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GuessingGameScreen extends ConsumerStatefulWidget {
  final int? roomId;
  final String? resumeGameId;

  const GuessingGameScreen({super.key, this.roomId, this.resumeGameId});

  @override
  ConsumerState<GuessingGameScreen> createState() => _GuessingGameScreenState();
}

class _GuessingGameScreenState extends ConsumerState<GuessingGameScreen> {
  @override
  void initState() {
    super.initState();
    // โหลดข้อมูลเกมมารอไว้ก่อน
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(gameProvider.notifier)
          .initGame(roomId: widget.roomId, resumeGameId: widget.resumeGameId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildCurrentView(gameState),
    );
  }

  Widget _buildCurrentView(GameState state) {
    // 1. Loading (ตอนดึงข้อมูลครั้งแรก)
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Error
    if (state.error != null) {
      return Center(child: Text('Error: ${state.error}')); // แต่งสวยๆ ได้
    }

    // 3. Result View (เกมจบสมบูรณ์)
    if (state.isGameOver) {
      return ResultView(
        score: state.totalScore,
        myScore: state.myScore,
        partnerScore: state.partnerScore,
        matchedAnswers: state.totalScore,
        totalQuestions: state.questions.length,
        relationshipScore: state.relationshipScore,
        myAvatarUrl: state.myAvatar,
        partnerAvatarUrl: state.partnerAvatar,
        onFinish: () => Navigator.pop(context),
      );
    }

    // 4. Waiting View (ยังไม่ได้กดเริ่ม)
    if (!state.hasStartedGame) {
      return WaitingView(
        myAvatarUrl: state.myAvatar,
        partnerAvatarUrl: state.partnerAvatar,
        onReady: () {
          // กดปุ่มแล้วเปลี่ยน State เพื่อเข้าสู่คำถาม
          ref.read(gameProvider.notifier).state = state.copyWith(
            hasStartedGame: true,
          );
        },
      );
    }

    // 5. Loading View (ตอบครบแล้ว แต่รอคู่)
    // ถ้า index เกินจำนวนข้อ แสดงว่าเราตอบหมดแล้ว แต่ isGameOver ยังไม่ true (เพราะรออีกคน)
    if (state.hasUserFinishedAll) {
      return LoadingView(
        onBothComplete: () {
          // หน้านี้จะรอ WebSocket/API update state.isGameOver เป็น true
          // เมื่อ true มันจะเด้งไป case ที่ 3 (Result) เองอัตโนมัติ
        },
      );
    }

    // 6. Question View (กำลังเล่น)
    if (state.questions.isNotEmpty) {
      final currentQ = state.questions[state.currentIndex];
      return QuestionView(
        currentQuestionIndex: state.currentIndex,
        totalQuestions: state.questions.length,
        questionData: currentQ,
        onAnswer: (selectedOption) {
          ref.read(gameProvider.notifier).submitAnswer(selectedOption);
        },
      );
    }

    return const SizedBox(); // Fallback
  }
}
