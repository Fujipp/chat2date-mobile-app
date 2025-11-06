// ignore_for_file: constant_identifier_names

// lib/services/azure_face_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
// import 'package:permission_handler/permission_handler.dart';

/// ⚠️ อย่า commit คีย์จริงขึ้น Git; ภายหลังย้ายไป --dart-define หรือ dotenv
const _FACE_ENDPOINT = 'https://chat2date.cognitiveservices.azure.com/';
const _FACE_API_KEY =
    '5PGF0Yc9tG1UJ1Ii5XILQe1q3F4vv5m1TsqFuXnTapXigJHaAVBxJQQJ99BKACqBBLyXJ3w3AAAKACOGZWBg';

class AzureFaceService {
  final String endpoint; // e.g. https://<res>.cognitiveservices.azure.com
  final String apiKey;
  const AzureFaceService({required this.endpoint, required this.apiKey});

  const AzureFaceService.defaultInstance()
    : endpoint = _FACE_ENDPOINT,
      apiKey = _FACE_API_KEY;

  /// Detect -> รับ faceId จาก bytes ของรูป
  Future<String> detectFaceIdFromBytes(Uint8List bytes) async {
    final uri = Uri.parse(
      '$endpoint/face/v1.0/detect?returnFaceId=true&detectionModel=detection_03',
    );
    final res = await http.post(
      uri,
      headers: {
        'Ocp-Apim-Subscription-Key': apiKey,
        'Content-Type': 'application/octet-stream',
      },
      body: bytes,
    );
    if (res.statusCode != 200) {
      throw 'Azure Detect HTTP ${res.statusCode}: ${res.body}';
    }
    final arr = jsonDecode(res.body) as List;
    if (arr.isEmpty) throw 'ไม่พบใบหน้าในภาพ';
    final map = arr.first as Map<String, dynamic>;
    return map['faceId'] as String;
  }

  /// Verify -> คืน (isIdentical, confidence)
  Future<(bool, double)> verify(String faceId1, String faceId2) async {
    final uri = Uri.parse('$endpoint/face/v1.0/verify');
    final res = await http.post(
      uri,
      headers: {
        'Ocp-Apim-Subscription-Key': apiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'faceId1': faceId1, 'faceId2': faceId2}),
    );
    if (res.statusCode != 200) {
      throw 'Azure Verify HTTP ${res.statusCode}: ${res.body}';
    }
    final j = jsonDecode(res.body) as Map<String, dynamic>;
    final ok = (j['isIdentical'] ?? false) as bool;
    // 🔧 จุดที่พัง: แปลงเป็น double เสมอ
    final conf = (j['confidence'] as num?)?.toDouble() ?? 0.0;
    return (ok, conf);
  }
}
