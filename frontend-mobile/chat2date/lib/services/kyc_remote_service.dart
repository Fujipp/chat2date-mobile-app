import 'dart:typed_data';

class KycRemoteService {
  final String baseUrl;
  KycRemoteService(this.baseUrl);

  Future<Map<String, dynamic>> completeLivenessWithSelfie(
    Uint8List? selfieBytes,
  ) async {
    // TODO: เรียกจริงด้วย http
    await Future.delayed(const Duration(milliseconds: 400));
    return {'liveness': 'pass'}; // mock
  }

  Future<Map<String, dynamic>> cropFaceFromIdFront(String idFrontBase64) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {'idFaceBase64': idFrontBase64}; // mock: ส่งกลับเดิม
  }

  Future<Map<String, dynamic>> verifyFaceBytesVsIdFaceBase64({
    required Uint8List? selfieBytes,
    required String idFaceBase64,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // mock: ให้ผ่านเสมอ
    return {'match': true, 'score': 0.95};
  }
}
