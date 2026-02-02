class RelationshipBar {
  final int relationshipId;
  final int score;
  final int streakDays;
  final bool isFirstMessageBonus;
  final int dailyMessageCount;
  final bool isDailyMessagesBonus;
  final DateTime dailyDate;

  RelationshipBar({
    required this.relationshipId,
    required this.score,
    required this.streakDays,
    required this.isFirstMessageBonus,
    required this.dailyMessageCount,
    required this.isDailyMessagesBonus,
    required this.dailyDate,
  });

  factory RelationshipBar.fromJson(Map<String, dynamic> json) {
    return RelationshipBar(
      relationshipId: json['relationshipId'] as int,
      score: json['score'] as int,
      streakDays: json['streakDays'] as int,
      isFirstMessageBonus: json['isFirstMessageBonus'] as bool,
      dailyMessageCount: json['dailyMessageCount'] as int,
      isDailyMessagesBonus: json['isDailyMessagesBonus'] as bool,
      dailyDate: DateTime.parse(json['dailyDate'] as String),
    );
  }
}