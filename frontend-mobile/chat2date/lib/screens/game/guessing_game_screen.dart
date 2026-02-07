import 'dart:async';

import 'package:chat2date/models/user.dart';
import 'package:chat2date/screens/game/views/loading_view.dart';
import 'package:chat2date/screens/game/views/question_view.dart';
import 'package:chat2date/screens/game/views/result_view.dart';
import 'package:chat2date/screens/game/views/waiting_view.dart';
import 'package:chat2date/services/game_service.dart';
import 'package:chat2date/services/game_socket_service.dart';
import 'package:chat2date/stores/game_store.dart';
import 'package:chat2date/stores/user_store.dart';
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
  GameSocketService? _socketService;
  StreamSubscription? _socketSubscription;

  bool _canPop = false;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref
          .read(gameProvider.notifier)
          .initGame(roomId: widget.roomId, resumeGameId: widget.resumeGameId);

      _connectSocket();
    });
  }

  // ในไฟล์ guessing_game_screen.dart
  void _connectSocket() {
    final gameState = ref.read(gameProvider);
    final userStore = ref.read(userStoreProvider);
    final User? userObj = userStore['user'] as User?;
    final myUserId = userObj?.userId;

    if (myUserId == null) {
      print("❌ CRITICAL ERROR: UserID is still NULL. Please Re-Login.");
      return;
    }

    if (gameState.gameId != null && widget.roomId != null) {
      _socketService = GameSocketService(
        roomId: widget.roomId.toString(),
        accessToken: userStore['accessToken'].toString(),
      );

      _socketService!.connect();

      _socketSubscription = _socketService!.gameStream.listen((payload) {
        print("🎧 Socket Received in Screen: $payload");

        final type = payload['type'];

        if (type == 'GAME_CANCELLED') {
          print("🚫 Game Cancelled by partner/server");

          if (mounted && !_isExiting) {
            setState(() {
              _isExiting = true; // ล็อคไม่ให้ทำซ้ำ
              _canPop = true; // ปลดล็อค PopScope
            });


            Future.microtask(() {
              if (mounted && Navigator.canPop(context)) {
                Navigator.pop(context, 'FAILED');
              }
            });
          }
          return;
        }

        ref
            .read(gameProvider.notifier)
            .socketMessage(payload, myUserId.toString());
      });
    }
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    _socketService?.dispose();
    super.dispose();
  }

  void quitGame({bool isTimeout = false}) {
    // 1. เช็คว่ากำลังออกอยู่แล้วหรือยัง (กัน Socket สั่งซ้ำ)
    if (mounted && !_isExiting) {
      final gameId = ref.read(gameProvider).gameId;
      if (gameId != null) {
        ref.read(gameServiceProvider).sendTimeout(gameId);
      }

      setState(() {
        _isExiting =
            true; // 2. ล็อคทันที! เพื่อบอก Socket ว่า "ฉันกำลังออกแล้วนะ อย่า Pop ซ้ำ"
        _canPop = true;
      });

      Future.microtask(() {
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context, 'FAILED');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);

    return PopScope(
      canPop: _canPop,
      onPopInvoked: (didPop) {
        if (didPop) return;
        // เมื่อกด Back ให้ถือว่า Failed
        quitGame();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _buildCurrentView(gameState),
      ),
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
        isMeReady: state.isImReady,
        isPartnerReady: state.isPartnerReady,
        onReady: () {
          ref.read(gameProvider.notifier).sendReady();
        },
        onTimeout: () {
          quitGame(isTimeout: true);
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
