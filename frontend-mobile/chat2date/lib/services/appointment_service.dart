import 'dart:convert';

import 'package:chat2date/core/config/backend_base.dart';
import 'package:chat2date/models/appointment.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// Provider for AppointmentService
final appointmentServiceProvider = Provider<AppointmentService>((ref) {
  return AppointmentService(ref);
});

class AppointmentService {
  final Ref ref;
  AppointmentService(this.ref);

  String _accessToken() {
    final userState = ref.read(userStoreProvider);
    return '${userState['accessToken']}';
  }

  Map<String, String> get _headers => {
    'Authorization': 'Bearer ${_accessToken()}',
    'Content-Type': 'application/json',
  };

  String _utcPayloadDateTime(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String().replaceFirst('Z', '');
  }

  /// POST /api/v1/dates/appointments
  /// Creates a new appointment for the given room
  Future<Appointment> createAppointment({
    required int roomId,
    required String placeId,
    required String placeName,
    required DateTime dateTime,
  }) async {
    final uri = Uri.parse('${ApiBase.baseUrl}/dates/appointments');
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'roomId': roomId,
        'placeId': placeId,
        'placeName': placeName,
        // ส่งเป็น UTC เพื่อให้ DB เก็บเวลาแบบไม่บวก +7
        'dateTime': _utcPayloadDateTime(dateTime),
      }),
    );

    if (response.statusCode == 201) {
      return Appointment.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    if (response.statusCode == 401) throw Exception('กรุณาเข้าสู่ระบบใหม่');
    throw Exception(
      'ไม่สามารถสร้างนัดหมายได้: ${response.statusCode} ${response.body}',
    );
  }

  /// GET /api/v1/dates/appointments/{roomId}
  /// Returns all appointments for a room. Returns empty list if none.
  Future<List<Appointment>> getAppointments(int roomId) async {
    final uri = Uri.parse('${ApiBase.baseUrl}/dates/appointments/$roomId');
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> list = data['appointments'] ?? [];
      return list
          .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (response.statusCode == 401) throw Exception('กรุณาเข้าสู่ระบบใหม่');
    if (response.statusCode == 404) return [];
    throw Exception(
      'ไม่สามารถดึงข้อมูลนัดหมายได้: ${response.statusCode} ${response.body}',
    );
  }

  /// PUT /api/v1/dates/appointments/{appointmentId}
  /// Updates the dateTime of an existing appointment
  Future<Appointment> updateAppointment({
    required int appointmentId,
    required DateTime dateTime,
  }) async {
    final uri = Uri.parse(
      '${ApiBase.baseUrl}/dates/appointments/$appointmentId',
    );
    print(dateTime.toUtc().toIso8601String());
    final response = await http.put(
      uri,
      headers: _headers,
      body: jsonEncode({
        // ส่งเป็น UTC เพื่อให้ DB เก็บเวลาแบบไม่บวก +7
        'dateTime': _utcPayloadDateTime(dateTime),
      }),
    );

    if (response.statusCode == 200) {
      return Appointment.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    if (response.statusCode == 401) throw Exception('กรุณาเข้าสู่ระบบใหม่');
    throw Exception(
      'ไม่สามารถแก้ไขนัดหมายได้: ${response.statusCode} ${response.body}',
    );
  }

  /// DELETE /api/v1/dates/appointments/{appointmentId}
  /// Deletes an existing appointment
  Future<void> deleteAppointment(int appointmentId) async {
    final uri = Uri.parse(
      '${ApiBase.baseUrl}/dates/appointments/$appointmentId',
    );
    final response = await http.delete(uri, headers: _headers);

    if (response.statusCode == 200) return;
    if (response.statusCode == 401) throw Exception('กรุณาเข้าสู่ระบบใหม่');
    throw Exception(
      'ไม่สามารถลบนัดหมายได้: ${response.statusCode} ${response.body}',
    );
  }
}
