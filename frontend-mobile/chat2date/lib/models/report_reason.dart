class ReportReason {
  final int id;
  final String report;

  ReportReason({required this.id, required this.report});

  factory ReportReason.fromJson(Map<String, dynamic> json) {
    return ReportReason(id: json['id'], report: json['report']);
  }
}