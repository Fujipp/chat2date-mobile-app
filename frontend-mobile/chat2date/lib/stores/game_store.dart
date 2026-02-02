import 'package:chat2date/models/dto/game_dto.dart';
import 'package:chat2date/services/game_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class GameState {
  final bool isLoading;
  final String? error;

  final bool hasStartedGame;

  final String? gameId;
  final List<GameQuestionDto> questions;
  final int currentIndex;
  final int myScore;
  final int partnerScore;
  final int totalScore;
  final bool isGameOver;

  final String myAvatar;
  final String partnerAvatar;
  final int relationshipScore;

  bool get hasUserFinishedAll =>
      questions.isNotEmpty && currentIndex >= questions.length;

  GameState({
    this.isLoading = false,
    this.error,
    this.hasStartedGame = false, 
    this.gameId,
    this.questions = const [],
    this.currentIndex = 0,
    this.myScore = 0,
    this.partnerScore = 0,
    this.totalScore = 0,
    this.isGameOver = false,
    this.myAvatar = '',
    this.partnerAvatar = '',
    this.relationshipScore = 0,
  });

  GameState copyWith({
    bool? isLoading,
    String? error,
    bool? hasStartedGame,
    String? gameId,
    List<GameQuestionDto>? questions,
    int? currentIndex,
    int? myScore,
    int? partnerScore,
    int? totalScore,
    bool? isGameOver,
    String? myAvatar,
    String? partnerAvatar,
    int? relationshipScore,
  }) {
    return GameState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasStartedGame: hasStartedGame ?? this.hasStartedGame,
      gameId: gameId ?? this.gameId,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      myScore: myScore ?? this.myScore,
      partnerScore: partnerScore ?? this.partnerScore,
      totalScore: totalScore ?? this.totalScore,
      isGameOver: isGameOver ?? this.isGameOver,
      myAvatar: myAvatar ?? this.myAvatar,
      partnerAvatar: partnerAvatar ?? this.partnerAvatar,
      relationshipScore: relationshipScore ?? this.relationshipScore,
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  final GameService _service;

  GameNotifier(this._service) : super(GameState());

  Future<void> initGame({int? roomId, String? resumeGameId}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      GameInfoResponseDto data;

      if (resumeGameId != null) {
        data = await _service.getGameInfo(resumeGameId);
      } else if (roomId != null) {
        data = await _service.createGame(roomId);
      } else {
        throw Exception("Missing roomId or gameId");
      }

      int startIndex = data.myAnsweredQuestionIds.length;
      bool shouldStartImmediately = resumeGameId != null || startIndex > 0;

      state = state.copyWith(
        isLoading: false,
        gameId: data.gameId,
        questions: data.questions,
        currentIndex: startIndex,
        myScore: data.myScore,
        partnerScore: data.partnerScore,
        totalScore: data.totalScore,
        myAvatar: data.myAvatar,
        partnerAvatar: data.partnerAvatar,
        relationshipScore: data.relationshipScore,
        isGameOver: data.status == 'COMPLETED',
        hasStartedGame: shouldStartImmediately, 
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void startGame() {
    state = state.copyWith(hasStartedGame: true);
  }

  Future<bool> submitAnswer(String selectedOption) async {
    try {
      if (state.currentIndex >= state.questions.length) return false;

      final currentQ = state.questions[state.currentIndex];
      final result = await _service.answerQuestion(
        gameId: state.gameId!,
        questionId: currentQ.questionId,
        selectedOption: selectedOption,
      );

      final newMyScore = result.isCorrect ? state.myScore + 1 : state.myScore;

      state = state.copyWith(
        totalScore: result.totalScore, 
        isGameOver: result.isGameOver,
        currentIndex: state.currentIndex + 1,

        myScore: newMyScore,
      );

      return result.isCorrect;
    } catch (e) {
      print("Error answering: $e");
      return false;
    }
  }

  void onGameOverBySocket() {
    state = state.copyWith(isGameOver: true);
  }
}

final gameProvider = StateNotifierProvider.autoDispose<GameNotifier, GameState>(
  (ref) {
    final service = ref.watch(gameServiceProvider);
    return GameNotifier(service);
  },
);
