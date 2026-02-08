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

  final int partnerAnsweredCount;

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
    this.partnerAnsweredCount = 0, 
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
    int? partnerAnsweredCount, 
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
      partnerAnsweredCount:
          partnerAnsweredCount ?? this.partnerAnsweredCount, 
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

      final bool isImReady = readyPlayerIds.any(
        (id) => id.toString() == userId.toString(),
      );

      final bool isMyPartnerReady = readyPlayerIds.any(
        (id) => id.toString() != userId.toString(),
      );

      state = state.copyWith(
        isImReady: isImReady,
        isPartnerReady: isMyPartnerReady,
        hasStartedGame: state.hasStartedGame,
      );
    }

    if (type == 'GAME_START') {
      print("🎮 🎮 🎮 Received GAME_START via Socket!");
      state = state.copyWith(hasStartedGame: true, isLoading: false);
    }

    if (type == 'SCORE_UPDATE') {
      final Map<String, dynamic> scores = payload['scores'] ?? {};

      final String myUserIdStr = userId.toString();

      final int myNewScore = scores[myUserIdStr] ?? state.myScore;

      final String partnerId = scores.keys.firstWhere(
        (id) => id.toString() != myUserIdStr,
        orElse: () => "",
      );
      final int partnerNewScore = (partnerId.isNotEmpty)
          ? (scores[partnerId] ?? state.partnerScore)
          : state.partnerScore;

      final String answeredBy = payload['answeredBy'] ?? "";
      int newPartnerAnsweredCount = state.partnerAnsweredCount;

      if (answeredBy.toString() != myUserIdStr) {
        newPartnerAnsweredCount =
            payload['answeredCount'] ?? state.partnerAnsweredCount;
      }

      print("🔢 Updating Scores from Socket:");
      print("   My Score: $myNewScore");
      print("   Partner Score: $partnerNewScore");
      print("   Total Score: ${payload['roomTotalScore']}");
      print("   Partner Answered Count: $newPartnerAnsweredCount"); 

      state = state.copyWith(
        totalScore: payload['roomTotalScore'],
        myScore: myNewScore,
        partnerScore: partnerNewScore,
        partnerAnsweredCount: newPartnerAnsweredCount, 
        isGameOver: (payload['isGameOver'] ?? false) || state.isGameOver,
      );
    }
  }

  Future<void> initGame({int? roomId, String? resumeGameId}) async {
    try {
      GameInfoResponseDto data;

      if (resumeGameId != null) {
        data = await _service.getGameInfo(resumeGameId);
      } else if (roomId != null) {
        data = await _service.createGame(roomId);
      } else {
        throw Exception("Missing roomId or gameId");
      }

      print("📦 API Response:");
      print("   relationshipScore: ${data.relationshipScore}");
      print("   myScore: ${data.myScore}");
      print("   partnerScore: ${data.partnerScore}");
      print("   totalScore: ${data.totalScore}");
      print("   status: ${data.status}");

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

      final bool currentGameOverStatus = state.isGameOver;

      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        isGameOver: currentGameOverStatus,
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
