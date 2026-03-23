import 'dart:convert';

import 'package:chat2date/config/backend_base.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final contactServiceProvider = Provider((ref) => ContactService(ref));

class ContactService {
  final Ref ref;
  ContactService(this.ref);

  Future<int> sendContactMessage({
    required String contactName,
    required String contactEmail,
    required String subject,
    required String message,
  }) async {
    final userState = ref.read(userStoreProvider);
    final accessToken = "${userState['accessToken']}";

    final url = Uri.parse('${ApiBase.baseUrl}/contact');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'contactName': contactName,
        'contactEmail': contactEmail,
        'subject': subject,
        'message': message,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return data['contactId'];
    }
    throw Exception('ไม่สามารถส่งข้อความได้');
  }
}
