class Appointment {
  final int appointmentId;
  final int roomId;
  final String placeId;
  final String placeName;
  final DateTime? dateTime; // เป็น null ได้ตาม backend entity
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Appointment({
    required this.appointmentId,
    required this.roomId,
    required this.placeId,
    required this.placeName,
    this.dateTime,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  static DateTime? _parseUtcDateTime(dynamic value) {
    if (value == null) return null;

    final raw = value as String;
    final normalized = (raw.endsWith('Z') || raw.contains('+')) ? raw : '${raw}Z';
    return DateTime.parse(normalized).toUtc();
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      appointmentId: json['appointmentId'] as int,
      roomId: json['roomId'] as int,
      // placeId / placeName อาจเป็น null ได้จาก backend
      placeId: (json['placeId'] as String?) ?? '',
      placeName: (json['placeName'] as String?) ?? '',
      // dateTime เป็น null ได้ (ยังไม่ได้นัด)
      dateTime: _parseUtcDateTime(json['dateTime']),
      // backend default คือ PLACE_SELECTED ไม่ใช่ SCHEDULED
      status: (json['status'] as String?) ?? 'PLACE_SELECTED',
      createdAt: _parseUtcDateTime(json['createdAt']),
      updatedAt: _parseUtcDateTime(json['updatedAt']),
    );
  }

  static String? _toUtcPayload(DateTime? dateTime) {
    if (dateTime == null) return null;
    return dateTime.toUtc().toIso8601String().replaceFirst('Z', '');
  }

  Map<String, dynamic> toJson() {
    return {
      'appointmentId': appointmentId,
      'roomId': roomId,
      'placeId': placeId,
      'placeName': placeName,
      'dateTime': _toUtcPayload(dateTime),
      'status': status,
    };
  }
}
