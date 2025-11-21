// lib/services/kyc_remote_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:chat2date/config/backend_base.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
part 'kyc_remote_service.g.dart';

@riverpod
KycRemoteService kycRemoteService(Ref ref) {
  return kycRemoteService(ref);
}

class KycRemoteService {
  final Ref ref;
  KycRemoteService(this.ref);
  // final String baseUrl; // ควรเป็นแบบ http://10.0.2.2:8080/api/v1
  // KycRemoteService(this.baseUrl);

  Future<Map<String, dynamic>> completeLivenessWithSelfie(
    Uint8List? selfieBytes,
  ) async {
    return {'liveness': 'pass'};
  }

  Future<Map<String, dynamic>> cropFaceFromIdFront(String idFrontBase64) async {
    final uri = Uri.parse('${ApiBase.baseUrl}/kyc/ocr/crop-id-face');
    debugPrint('[KYC] POST $uri');

    final userState = ref.read(userStoreProvider);
    final accessToken = "${userState['accessToken']}";

    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': accessToken,
      },
      body: jsonEncode({'idFrontBase64': idFrontBase64}),
    );

    debugPrint('[KYC] status=${res.statusCode} body=${res.body}');

    if (res.statusCode != 200) {
      throw 'Crop ID face failed: HTTP ${res.statusCode} ${res.body}';
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return json;
  }

  /// เรียก BE: /kyc/verify-face → ใช้ Azure เทียบ selfie vs idFaceBase64
   Future<Map<String, dynamic>> verifyFaceBytesVsIdFaceBase64({
    required Uint8List? selfieBytes,
    required String idFaceBase64,
  }) async {
    if (selfieBytes == null) {
      throw 'selfieBytes is null';
    }

    final uri = Uri.parse('${ApiBase.baseUrl}/kyc/verify-face');
    final selfieB64 = base64Encode(selfieBytes);
    final userState = ref.read(userStoreProvider);
    final accessToken = "${userState['accessToken']}";

    debugPrint('[KYC] POST $uri');
    debugPrint(
      '[KYC] selfieB64.length=${selfieB64.length}, idFace.length=${idFaceBase64.length}',
    );

    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': accessToken,
      },
      body: jsonEncode({
        'selfieBase64': selfieB64,
        'idFaceBase64': idFaceBase64,
      }),
    );

    debugPrint('[KYC] status=${res.statusCode} body=${res.body}');

    if (res.statusCode != 200) {
      throw 'Verify face failed: HTTP ${res.statusCode} ${res.body}';
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    // backend ส่ง VerifyFaceResponse { match, score }
    return json;
  }
}
