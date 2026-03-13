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
    String mode = 'MIDPOINT',
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
      final Map<String, dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      return DateRecommendationResponse.fromJson(jsonData);
    } else {
      throw Exception('Failed to load recommendations');
    }
  }
}
