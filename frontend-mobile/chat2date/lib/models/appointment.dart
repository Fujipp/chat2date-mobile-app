class Appointment {
  final int appointmentId;
  final int roomId;
  final String placeId;
  final String placeName;
  final DateTime dateTime;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Appointment({
    required this.appointmentId,
    required this.roomId,
    required this.placeId,
    required this.placeName,
    required this.dateTime,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      appointmentId: json['appointmentId'] as int,
      roomId: json['roomId'] as int,
      placeId: json['placeId'] as String,
      placeName: json['placeName'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      status: json['status'] as String? ?? 'SCHEDULED',
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
      'dateTime': dateTime.toIso8601String(),
      'status': status,
    };
  }
}
