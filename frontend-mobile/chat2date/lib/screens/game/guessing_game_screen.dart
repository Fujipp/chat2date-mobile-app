import 'package:chat2date/screens/game/views/loading_view.dart';
import 'package:chat2date/screens/game/views/result_view.dart';
import 'package:flutter/material.dart';

import 'views/question_view.dart';
import 'views/waiting_view.dart';

class GuessingGameScreen extends StatefulWidget {
  const GuessingGameScreen({super.key});

  @override
  State<GuessingGameScreen> createState() => _GuessingGameScreenState();
}

class _GuessingGameScreenState extends State<GuessingGameScreen> {
  String currentView = 'loading'; // waiting, question, loading, result

  // Game State
  int currentQuestion = 0;
  List<int> userAnswers = [];
  int score = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: _buildCurrentView());
  }

  Widget _buildCurrentView() {
    switch (currentView) {
      case 'waiting':
        return WaitingView(onReady: _goToQuestion);

      case 'question':
        return QuestionView(
          currentQuestion: currentQuestion,
          onAnswer: _handleAnswer,
        );

      case 'loading':
        return LoadingView(onBothComplete: _goToResult);

      case 'result':
        return ResultView(
          score: score,
          matchedAnswers: 4,
          totalQuestions: 5,
          // onFinish: _exitGame,
          onFinish: _goToWaiting,
        );

      default:
        return WaitingView(onReady: _goToQuestion);
    }
  }

  // Navigation methods
  void _goToQuestion() {
    setState(() {
      currentView = 'question';
    });
  }

  void _handleAnswer(int answerIndex) {
    setState(() {
      userAnswers.add(answerIndex);
      currentQuestion++;

      // ถ้าตอบครบ 5 ข้อแล้ว ไปหน้าโหลด
      if (currentQuestion >= 5) {
        currentView = 'loading';
      }
    });
  }

  void _goToResult() {
    setState(() {
      // TODO: คำนวณคะแนนจริง
      score = 80; // Mock score
      currentView = 'result';
    });
  }

  void _exitGame() {
    Navigator.pop(context);
  }

  void _goToWaiting() {
    setState(() {
      currentView = 'waiting';
    });
  }
}
