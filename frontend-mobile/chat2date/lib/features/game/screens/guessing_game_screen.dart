import 'dart:async';

import 'package:chat2date/models/user.dart';
import 'package:chat2date/features/game/screens/views/loading_view.dart';
import 'package:chat2date/features/game/screens/views/question_view.dart';
import 'package:chat2date/features/game/screens/views/result_view.dart';
import 'package:chat2date/features/game/screens/views/waiting_view.dart';
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
  StreamSubscription<Map<String, dynamic>>? _socketSubscription;

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

  void _connectSocket() {
    final userStore = ref.read(userStoreProvider);
    final User? userObj = userStore['user'] as User?;
    final myUserId = userObj?.userId;

    if (myUserId == null) {
      return;
    }

    if (widget.roomId != null) {
      _socketService = GameSocketService(
        roomId: widget.roomId.toString(),
        accessToken: userStore['accessToken'].toString(),
      );

      _socketService!.connect();

      _socketSubscription = _socketService!.gameStream.listen((payload) {
        final type = payload['type'];

        if (type == 'GAME_CANCELLED') {
          if (mounted && !_isExiting) {
            setState(() {
              _isExiting = true;
              _canPop = true;
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
    if (mounted && !_isExiting) {
      FocusScope.of(context).unfocus();
      final gameId = ref.read(gameProvider).gameId;
      if (gameId != null) {
        ref.read(gameServiceProvider).sendTimeout(gameId);
      }

      setState(() {
        _isExiting = true;
        _canPop = true;
      });

      Future.delayed(const Duration(milliseconds: 300), () {
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
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        quitGame();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _buildCurrentView(gameState),
      ),
    );
  }

  Widget _buildCurrentView(GameState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(child: Text('Error: ${state.error}'));
    }

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

    if (state.hasUserFinishedAll) {
      return LoadingView(
        partnerProgress: state.partnerAnsweredCount,
        totalQuestions: state.questions.length,
        onBothComplete: () async {
          if (state.gameId != null) {
            try {
              final refreshedData = await ref
                  .read(gameServiceProvider)
                  .getGameInfo(state.gameId!);
              ref.read(gameProvider.notifier).syncFromGameInfo(refreshedData);
            } catch (e) {
              ref.read(gameProvider.notifier).onGameOverBySocket();
            }
          } else {
            ref.read(gameProvider.notifier).onGameOverBySocket();
          }
        },
      );
    }

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

    return const SizedBox();
  }
}
