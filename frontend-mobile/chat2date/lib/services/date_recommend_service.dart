import 'dart:convert';
import 'package:chat2date/config/backend_base.dart';
import 'package:chat2date/models/dto/date_recommend_dto.dart';
import 'package:chat2date/models/dto/place_dto.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ ต้องเป็นตัวนี้
import 'package:http/http.dart' as http;

// ✅ นี่คือ Provider ที่คุณต้องใช้เรียกในหน้า UI
final dateRecommendProvider = Provider<DateRecommendService>((ref) {
  return DateRecommendService(ref);
});

class DateRecommendService {
  final Ref ref;
  DateRecommendService(this.ref);

  Future<DateRecommendationResponse> getRecommendations({
    required String? roomId,
    String? mode = 'MIDPOINT',
    String? userTarget,
    required int range,
    bool forceRefresh = false,
  }) async {
    final userState = ref.read(userStoreProvider);
    final accessToken = "${userState['accessToken']}";
    final queryParams = {
      'mode': mode,
      'range': range.toString(),
      'forceRefresh': forceRefresh.toString(),
    };
    if (userTarget != null) queryParams['userTarget'] = userTarget;

    final uri = Uri.parse(
      '${ApiBase.baseUrl}/dates/recommendations/$roomId',
    ).replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // คืนค่าเป็น List ของสถานที่
      final Map<String, dynamic> jsonData = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      return DateRecommendationResponse.fromJson(jsonData);
    } else {
      throw Exception('Failed to load recommendations');
    }
  }

  Future<void> confirmPlace({
    required String? roomId,
    required String placeName,
    required String action,
    String mode = 'MIDPOINT',
    String? userTarget,
  }) async {
    final userState = ref.read(userStoreProvider);
    final accessToken = "${userState['accessToken']}";

    final url = Uri.parse(
      '${ApiBase.baseUrl}/dates/recommendations/$roomId/confirm',
    );

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'placeName': placeName,
        'action': action,
        'mode': mode,
        'userTarget': userTarget,
      }),
    );

    if (response.statusCode != 200) {
      // คุณสามารถสร้าง Exception เฉพาะตัวได้ เช่น NotFoundException
      throw Exception('Failed to confirm place: ${response.body}');
    }
  }

  Future<String?> checkConfirmPlace({required String? roomId}) async {
    final userState = ref.read(userStoreProvider);
    final accessToken = "${userState['accessToken']}";

    final url = Uri.parse(
      '${ApiBase.baseUrl}/dates/recommendations/$roomId/confirm',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      return data['status']?.toString();
    } else {
      throw Exception('Failed to confirm place: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> checkStatusSpin({
    required String? roomId,
  }) async {
    final userState = ref.read(userStoreProvider);
    final accessToken = "${userState['accessToken']}";

    final url = Uri.parse(
      '${ApiBase.baseUrl}/dates/recommendations/$roomId/spin-status',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        final bool canSpin = data['canSpin'] ?? false;
        final int unlockTimestamp = data['unlockTimestamp'] ?? 0;
        int cooldownDays = 0;

        if (!canSpin && unlockTimestamp > 0) {
          final nowMs = DateTime.now().millisecondsSinceEpoch;
          final remainingMs = unlockTimestamp - nowMs;

          if (remainingMs > 0) {
            cooldownDays = (remainingMs / (1000 * 60 * 60 * 24)).ceil();
          }
        }

        return {
          'canSpin': canSpin,
          'cooldownDays': cooldownDays,
          'isLockedByAppointment':
              !canSpin &&
              cooldownDays == 0, // ล็อคเพราะสถานะ SELECTED/SCHEDULED
        };
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print("Error in checkStatusSpin: $e");
      throw Exception('Failed to check spin status: $e');
    }
  }
}
