// lib/models/dto/feedback_response_dto.dart
class FeedbackResponseDto {
  final String status;
  final bool matched;
  final String targetUserId;
  final String targetName;

  FeedbackResponseDto({
    required this.status,
    required this.matched,
    required this.targetUserId,
    required this.targetName,
  });

  factory FeedbackResponseDto.fromJson(Map<String, dynamic> json) {
    return FeedbackResponseDto(
      status: json['status']?.toString() ?? '',
      matched: json['matched'] == true,
      targetUserId: json['targetUserId']?.toString() ?? '',
      targetName: json['targetName']?.toString() ?? '',
    );
  }
}
