class GameQuestionDto {
  final String questionId;
  final String text;
  final String? correct;
  final List<String> options;

  GameQuestionDto({
    required this.questionId,
    required this.text,
    this.correct,
    required this.options,
  });

  factory GameQuestionDto.fromJson(Map<String, dynamic> json) {
    return GameQuestionDto(
      questionId: json['questionId'] ?? '',
      text: json['question'] ?? '',
      correct: json['correct'],
      options: List<String>.from(json['options'] ?? []),
    );
  }
}

class GameCheckResponseDto {
  final bool canPlay;
  final String gameStatus; // NEW, RESUME, COOLDOWN
  final String? gameId;
  final int? remainingSeconds;

  GameCheckResponseDto({
    required this.canPlay,
    required this.gameStatus,
    this.gameId,
    this.remainingSeconds,
  });

  factory GameCheckResponseDto.fromJson(Map<String, dynamic> json) {
    return GameCheckResponseDto(
      canPlay: json['canPlay'] ?? false,
      gameStatus: json['gameStatus'] ?? 'NEW',
      gameId: json['gameId'],
      remainingSeconds: json['remainingSeconds'],
    );
  }
}

class GameInfoResponseDto {
  final String gameId;
  final String status; // ACTIVE, COMPLETED
  final int myScore;
  final int partnerScore;
  final int totalScore;
  final List<GameQuestionDto> questions;
  final List<String> myAnsweredQuestionIds;
  final String myAvatar;
  final String partnerAvatar;
  final int relationshipScore;

  GameInfoResponseDto({
    required this.gameId,
    required this.status,
    required this.myScore,
    required this.partnerScore,
    required this.totalScore,
    required this.questions,
    required this.myAnsweredQuestionIds,
    required this.myAvatar,
    required this.partnerAvatar,
    required this.relationshipScore,
  });

  factory GameInfoResponseDto.fromJson(Map<String, dynamic> json) {
    return GameInfoResponseDto(
      gameId: json['gameId'] ?? '',
      status: json['status'] ?? 'ACTIVE',
      myScore: json['myScore'] ?? 0,
      partnerScore: json['partnerScore'] ?? 0,
      totalScore: json['totalScore'] ?? 0,
      questions:
          (json['questions'] as List?)
              ?.map((e) => GameQuestionDto.fromJson(e))
              .toList() ??
          [],
      myAnsweredQuestionIds:
          (json['myAnsweredQuestionIds'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      myAvatar: json['myAvatar'] ?? '',
      partnerAvatar: json['partnerAvatar'] ?? '',
      relationshipScore: json['relationshipScore'] ?? 0,
    );
  }
}

class GameAnswerResponseDto {
  final bool isCorrect;
  final String correctAnswer;
  final int totalScore;
  final bool isGameOver;

  GameAnswerResponseDto({
    required this.isCorrect,
    required this.correctAnswer,
    required this.totalScore,
    required this.isGameOver,
  });

  factory GameAnswerResponseDto.fromJson(Map<String, dynamic> json) {
    return GameAnswerResponseDto(
      isCorrect: json['isCorrect'] ?? false,
      correctAnswer: json['correctAnswer'] ?? '',
      totalScore: json['totalScore'] ?? 0,
      isGameOver: json['isGameOver'] ?? false,
    );
  }
}
