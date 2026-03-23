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

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      appointmentId: json['appointmentId'] as int,
      roomId: json['roomId'] as int,
      // placeId / placeName อาจเป็น null ได้จาก backend
      placeId: (json['placeId'] as String?) ?? '',
      placeName: (json['placeName'] as String?) ?? '',
      // dateTime เป็น null ได้ (ยังไม่ได้นัด)
      dateTime: json['dateTime'] != null
          ? DateTime.parse(json['dateTime'] as String)
          : null,
      // backend default คือ PLACE_SELECTED ไม่ใช่ SCHEDULED
      status: (json['status'] as String?) ?? 'PLACE_SELECTED',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointmentId': appointmentId,
      'roomId': roomId,
      'placeId': placeId,
      'placeName': placeName,
      'dateTime': dateTime?.toIso8601String(),
      'status': status,
    };
  }
}
