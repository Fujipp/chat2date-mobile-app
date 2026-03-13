import 'dart:convert';

import 'package:chat2date/config/backend_base.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final emergencyCallServiceProvider = Provider<EmergencyCallService>((ref) {
  return EmergencyCallService(ref);
});

class EmergencyCallService {
  final Ref ref;
  EmergencyCallService(this.ref);

  Future<List<String>> getEmergencyCalls() async {
    final userState = ref.read(userStoreProvider);
    final accessToken = "${userState['accessToken']}";

    final url = Uri.parse('${ApiBase.baseUrl}/users/emergency-calls');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(
          utf8.decode(response.bodyBytes),
        );
        final List<dynamic> numbersList = data['phoneNumber'] ?? [];
        return numbersList.map((number) => number.toString()).toList();
      }

      if (response.statusCode == 401) {
        throw Exception('กรุณาเข้าสู่ระบบใหม่');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(
          utf8.decode(response.bodyBytes),
        );
        final List<dynamic> numbersList = data['phoneNumber'] ?? [];
        return numbersList.map((number) => number.toString()).toList();
      }

      if (response.statusCode == 401) {
        throw Exception('กรุณาเข้าสู่ระบบใหม่');
      }

      if (response.statusCode == 404) {
        return [];
      }

      throw Exception('ไม่สามารถดึงเบอร์โทรฉุกเฉินได้: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching emergency calls: $e');
    }
  }

  Future<bool> updateEmergencyCalls(List<String> phoneNumbers) async {
    final userState = ref.read(userStoreProvider);
    final accessToken = "${userState['accessToken']}";

    final url = Uri.parse('${ApiBase.baseUrl}/users/emergency-calls');

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'phoneNumbers': phoneNumbers}),
      );

      if (response.statusCode == 200) {
        return true;
      }

      if (response.statusCode == 401) {
        throw Exception('กรุณาเข้าสู่ระบบใหม่');
      }

      final errorData = json.decode(utf8.decode(response.bodyBytes));
      throw Exception(errorData['message'] ?? 'บันทึกไม่สำเร็จ');
    } catch (e) {
      if (e.toString().contains('ต้องมีเบอร์โทร') ||
          e.toString().contains('สูงสุด')) {
        rethrow;
      }
      throw Exception('Error updating emergency calls: $e');
    }
  }
}
