import 'dart:convert';

import 'package:chat2date/core/config/backend_base.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final reviewServiceProvider = Provider((ref) => ReviewService(ref));

class ReviewService {
  final Ref ref;
  ReviewService(this.ref);

  Future<bool> checkReviewStatus(int appointmentId) async {
    final userState = ref.read(userStoreProvider);
    final accessToken = "${userState['accessToken']}";

    final url = Uri.parse('${ApiBase.baseUrl}/dates/reviews/$appointmentId');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return data['isReviewed'] ?? false;
    }
    return true;
  }

  Future<void> submitReview({
    required int appointmentId,
    required String targetUserId,
    required bool isSatisfied,
    bool? wantToContinue,
    bool? wantToUnmatch,
  }) async {
    final userState = ref.read(userStoreProvider);
    final accessToken = "${userState['accessToken']}";

    final url = Uri.parse('${ApiBase.baseUrl}/dates/reviews/$appointmentId');

    final body = <String, dynamic>{
      'partnerId': targetUserId,
      'is_satisfied': isSatisfied,
    };
    if (wantToContinue != null) body['want_to_continue'] = wantToContinue;
    if (wantToUnmatch != null) body['want_to_unmatch'] = wantToUnmatch;

    print("📤 POST $url");
    print("📦 body: $body");

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    print("📥 status: ${response.statusCode}");
    print("📥 body: ${response.body}");

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('ไม่สามารถส่งรีวิวได้');
    }
  }
}
