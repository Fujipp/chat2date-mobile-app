import 'dart:convert';

class ReportRequest {
  final String userId;
  final String targetUserId;
  final String reason;
  final String? anotherReason;
  final String? description;

  ReportRequest({
    required this.userId,
    required this.targetUserId,
    required this.reason,
    this.anotherReason,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'targetUserId': targetUserId,
      'reason': reason,
      if (anotherReason != null) 'anotherReason': anotherReason,
      if (description != null) 'description': description,
    };
  }

  String toJsonString() => jsonEncode(toJson());
}
