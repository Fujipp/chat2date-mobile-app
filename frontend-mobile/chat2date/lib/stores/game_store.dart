import 'package:chat2date/models/dto/game_dto.dart';
import 'package:chat2date/services/game_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameState {
  final bool isLoading;
  final String? error;

  final bool isImReady;
  final bool isPartnerReady;
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
    this.isImReady = false,
    this.isPartnerReady = false,
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
    bool? isImReady,
    bool? isPartnerReady,
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
      isImReady: isImReady ?? this.isImReady,
      isPartnerReady: isPartnerReady ?? this.isPartnerReady,
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

  void socketMessage(Map<String, dynamic> payload, String userId) {
    final type = payload['type'];

    print("📩 Socket Message Type: $type");
    print("📩 Payload: $payload");

    if (type == 'PLAYER_READY') {
      final List<dynamic> readyPlayerIds = payload['readyPlayerIds'] ?? [];
      final int readyCount = payload['readyCount'] ?? 0;

      print("👥 Ready Players: $readyPlayerIds");
      print("🆔 My User ID: $userId");

      final bool isImReady = readyPlayerIds.any(
        (id) => id.toString() == userId.toString(),
      );

      final bool isMyPartnerReady = readyPlayerIds.any(
        (id) => id.toString() != userId.toString(),
      );

      print("✅ Am I Ready? $isImReady");
      print("✅ Is Partner Ready? $isMyPartnerReady");

      state = state.copyWith(
        isImReady: isImReady,
        isPartnerReady: isMyPartnerReady,
        hasStartedGame: state.hasStartedGame, // ห้าม override
      );
    }

    if (type == 'GAME_START') {
      print("🎮 🎮 🎮 Received GAME_START via Socket!");
      state = state.copyWith(hasStartedGame: true, isLoading: false);
    }

    if (type == 'SCORE_UPDATE') {
      final bool isGameTrulyOver =
          payload['isGameOver'] ?? false; // รับค่าจาก Backend
      final int roomTotalScore = payload['roomTotalScore'] ?? state.totalScore;
      final int partnerScore =
          payload['partnerScore'] ?? state.partnerScore; // ถ้ามีส่งมา

      state = state.copyWith(
        totalScore: roomTotalScore,
        isGameOver:
            isGameTrulyOver, // 🔥 จบเกมพร้อมกันเมื่อ Socket สั่งเท่านั้น
      );
    }
  }

  Future<void> initGame({int? roomId, String? resumeGameId}) async {
    // state = state.copyWith(isLoading: true, error: null);
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
      final bool finalHasStarted =
          state.hasStartedGame || shouldStartImmediately;

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
        hasStartedGame: finalHasStarted,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> sendReady() async {
    try {
      if (state.gameId == null) return;
      await _service.sendPlayerReady(state.gameId!);
    } catch (e) {
      print("Error sending ready: $e");
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
        isGameOver: false,
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
