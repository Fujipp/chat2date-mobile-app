class SwipeQuotaDto {
  final int currentCount;
  final int? remainingCount;
  final bool isRestricted;
  final DateTime? unlockAt;
  final String? message;

  SwipeQuotaDto({
    required this.currentCount,
    this.remainingCount,
    required this.isRestricted,
    this.unlockAt,
    this.message,
  });

  factory SwipeQuotaDto.fromJson(Map<String, dynamic> json) {
    return SwipeQuotaDto(
      currentCount: json['currentCount'] ?? 0,
      remainingCount: json['remainingCount'] ?? 0,
      isRestricted: json['isRestricted'] ?? false,
      unlockAt: json['unlockAt'] != null 
          ? DateTime.parse(json['unlockAt']) 
          : null,
      message: json['message'],
    );
  }
}