/// Model สำหรับข้อมูล Match
/// ใช้กับ GET /api/v1/matches
class Match {
  final String matchId;
  final String partnerId;
  final String partnerName;
  final String? partnerImage;
  final String type; // "new" or "old"
  final DateTime? matchedAt; // วันที่ Match
  final bool isViewed; // ดูแล้วหรือยัง
  final bool hasMessages; // มีข้อความหรือยัง (ถ้ามี = ย้ายไปหมวด CHAT)

  Match({
    required this.matchId,
    required this.partnerId,
    required this.partnerName,
    this.partnerImage,
    this.type = 'old',
    this.matchedAt,
    this.isViewed = false,
    this.hasMessages = false,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    final type = json['type'] ?? 'old';
    final matchedAtRaw = json['matchedAt'] ?? json['createdAt'];
    return Match(
      matchId: json['matchId'] ?? '',
      partnerId: json['partnerId'] ?? '',
      partnerName: json['partnerName'] ?? '',
      partnerImage: json['partnerImage'],
      type: type,
      matchedAt: matchedAtRaw != null ? DateTime.tryParse(matchedAtRaw) : null,
      isViewed: json['isViewed'] ?? false,
      hasMessages: json['hasMessages'] ?? (type == 'old'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matchId': matchId,
      'partnerId': partnerId,
      'partnerName': partnerName,
      'partnerImage': partnerImage,
      'type': type,
      'matchedAt': matchedAt?.toIso8601String(),
      'isViewed': isViewed,
      'hasMessages': hasMessages,
    };
  }

  /// คำนวณระยะเวลาตั้งแต่ Match มา
  String get matchDuration {
    if (matchedAt == null) return 'Match!';

    final now = DateTime.now();
    final diff = now.difference(matchedAt!);

    if (diff.inMinutes < 1) {
      return 'Match เมื่อสักครู่';
    } else if (diff.inMinutes < 60) {
      return 'Match ${diff.inMinutes} นาทีที่แล้ว';
    } else if (diff.inHours < 24) {
      return 'Match ${diff.inHours} ชั่วโมงที่แล้ว';
    } else if (diff.inDays < 7) {
      return 'Match ${diff.inDays} วันที่แล้ว';
    } else if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return 'Match $weeks สัปดาห์ที่แล้ว';
    } else {
      final months = (diff.inDays / 30).floor();
      return 'Match $months เดือนที่แล้ว';
    }
  }

  /// ตรวจสอบว่าเป็น Match ใหม่หรือไม่ (ยังไม่ได้ดู)
  bool get isNewMatch => type == 'new' && !isViewed;
}
