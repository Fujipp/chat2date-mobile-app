// lib/services/kyc_remote_service.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:chat2date/config/backend_base.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final kycRemoteServiceProvider = Provider(
  (ref) => KycRemoteService(ref as WidgetRef),
);

class KycRemoteService {
  final WidgetRef ref;
  KycRemoteService(this.ref);

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

  Future<Map<String, dynamic>> verifyFaceBytesVsIdFaceBase642({
    required String selfieBytes,
    required String idFaceBase64,
  }) async {
    final uri = Uri.parse(
      'https://api.iapp.co.th/v3/store/ekyc/face-verification',
    );

    try {
      // สร้าง MultipartRequest
      final request = http.MultipartRequest('POST', uri);

      // ดึง API Key จาก header
      final userState = ref.read(userStoreProvider);
      request.headers['apikey'] = dotenv.env['IAPP_FACE_VERIFY_API_KEY'] ?? '';

      // แปลง selfieBytes และ idFaceBase64 จาก Base64 string เป็น Uint8List
      final selfieDecoded = base64Decode(selfieBytes);
      final idFaceDecoded = base64Decode(idFaceBase64);

      // เพิ่มไฟล์ลงใน MultipartRequest
      request.files.add(
        http.MultipartFile.fromBytes(
          'file1',
          selfieDecoded,
          filename: 'selfie.jpg',
          contentType: http.MediaType('image', 'jpeg'),
        ),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'file2',
          idFaceDecoded,
          filename: 'id_face.jpg',
          contentType: http.MediaType('image', 'jpeg'),
        ),
      );

      // แสดงข้อมูล log สำหรับดีบัก
      debugPrint('[KYC] POST $uri');
      debugPrint(
        '[KYC] selfieBytes.length=${selfieDecoded.length}, idFaceBase64.length=${idFaceDecoded.length}',
      );

      // ส่งคำขอ
      final res = await request.send();

      if (res.statusCode == 200) {
        // อ่านผลลัพธ์จาก response
        final responseBody = await res.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody) as Map<String, dynamic>;
        return jsonResponse;
      } else {
        throw 'Verify face failed: HTTP ${res.statusCode}';
      }
    } catch (error) {
      debugPrint('[KYC] Error: $error');
      rethrow; // โยน error เพื่อให้มีการจัดการเพิ่มเติมที่อื่น ๆ
    }
  }
}
