import 'dart:convert';

import 'package:chat2date/core/config/backend_base.dart';
import 'package:chat2date/core/utils/authenticated_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sosServiceProvider = Provider<SosService>((ref) {
  return SosService(ref);
});

class SosService {
  final Ref ref;
  SosService(this.ref);

  Future<bool> triggerSos({
    required int appointmentId,
    required double latitude,
    required double longitude,
    required String calledNumber,
  }) async {
    final client = ref.read(authenticatedClientProvider);
    final url = Uri.parse('${ApiBase.baseUrl}/sos/incidents');

    try {
      final response = await client.post(
        url,
        body: json.encode({
          'appointmentId': appointmentId,
          'latitude': latitude,
          'longitude': longitude,
          'calledNumber': calledNumber,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      }

      if (response.statusCode == 401) {
        throw Exception('กรุณาเข้าสู่ระบบใหม่');
      }

      final errorData = json.decode(utf8.decode(response.bodyBytes));
      throw Exception(errorData['message'] ?? 'ไม่สามารถส่งข้อมูล SOS ได้');
    } catch (e) {
      if (e.toString().contains('Exception: ')) {
        rethrow;
      }
      throw Exception('Error triggering SOS: $e');
    }
  }
}
