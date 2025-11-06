import 'dart:convert';
import 'package:http/http.dart' as http;

class KycApi {
  final String base; // เช่น http://127.0.0.1:8080
  const KycApi(this.base);

  Future<void> submitIdentity({
    required String fullName,
    required DateTime birthDate,
    required int age,
    required String gender, // "ชาย" | "หญิง" | "อื่นๆ"
  }) async {
    final uri = Uri.parse('$base/api/kyc/identity');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': fullName,
        'birthDate': birthDate.toIso8601String(),
        'age': age,
        'gender': gender,
      }),
    );
    if (res.statusCode != 200) {
      throw 'Submit KYC failed: HTTP ${res.statusCode} ${res.body}';
    }
  }
}
