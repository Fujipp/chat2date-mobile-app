import 'dart:convert';
import 'dart:io';

import 'package:chat2date/config/backend_base.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:chat2date/services/authenticated_client.dart';

final photoVerificationServiceProvider = Provider(
  (ref) => PhotoVerificationService(ref),
);

class PhotoVerificationService {
  final Ref ref;
  PhotoVerificationService(this.ref);

  Future<Map<String, dynamic>> verifyAndUpload({
    required String userId,
    required List<File> profileImages,
    required String idCardBase64,
  }) async {
    final client = ref.read(authenticatedClientProvider);

    final uri = Uri.parse('${ApiBase.baseUrl}/identity/verify-face');
    final request = http.MultipartRequest('POST', uri);

    for (var file in profileImages) {
      request.files.add(
        await http.MultipartFile.fromPath('profile_images', file.path),
      );
    }

    request.fields['id_card_base64'] = idCardBase64;
    request.fields['userId'] = userId;

    final streamedResponse = await client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Upload failed: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  Future<void> removePhoto({
    required String userId,
    required List<String> imageUrls,
  }) async {
    final client = ref.read(authenticatedClientProvider);

    final uri = Uri.parse('${ApiBase.baseUrl}/users/$userId/photo').replace(
      queryParameters: {
        "imageUrl": imageUrls, // ⚡ ส่งหลายค่าแบบ array
      },
    );

    final response = await client.delete(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 204) {
      throw Exception('Delete failed: ${response.body}');
    }
  }
}
