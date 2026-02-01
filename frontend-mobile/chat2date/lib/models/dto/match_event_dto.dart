class MatchEventDto {
  final int? matchId;  // roomId for navigating to chat
  final String selfUserId;
  final String selfName;
  final String? selfAvatarUrl;
  final String partnerUserId;
  final String partnerName;
  final String? partnerAvatarUrl;
  final DateTime? matchedAt;

  MatchEventDto({
    this.matchId,
    required this.selfUserId,
    required this.selfName,
    this.selfAvatarUrl,
    required this.partnerUserId,
    required this.partnerName,
    this.partnerAvatarUrl,
    this.matchedAt,
  });

  factory MatchEventDto.fromJson(Map<String, dynamic> json) {
    return MatchEventDto(
      matchId: json['matchId'] as int?,
      selfUserId: json['selfUserId']?.toString() ?? '',
      selfName: json['selfName']?.toString() ?? '',
      selfAvatarUrl: json['selfAvatarUrl'] as String?,
      partnerUserId: json['partnerUserId']?.toString() ?? '',
      partnerName: json['partnerName']?.toString() ?? '',
      partnerAvatarUrl: json['partnerAvatarUrl'] as String?,
      matchedAt: json['matchedAt'] != null
          ? DateTime.tryParse(json['matchedAt'].toString())
          : null,
    );
  }
}
