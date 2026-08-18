class ReportResponse {
  final int reportId;
  final String reporterId;
  final String targetUserId;
  final String reason;
  final String status;
  final DateTime createdAt;

  ReportResponse({
    required this.reportId,
    required this.reporterId,
    required this.targetUserId,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory ReportResponse.fromJson(Map<String, dynamic> json) {
    return ReportResponse(
      reportId: json['reportId'] as int,
      reporterId: json['reporterId'] as String,
      targetUserId: json['targetUserId'] as String,
      reason: json['reason'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
