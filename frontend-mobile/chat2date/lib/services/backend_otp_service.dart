import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chat2date/config/backend_base.dart'; // << เพิ่มบรรทัดนี้

class BackendOtpService {
  static String get _base => ApiBase.baseUrl; // << ใช้จากไฟล์ใหม่
  static const _headers = {'Content-Type': 'application/json'};
  static const _timeout = Duration(seconds: 15);

  static Future<String> sendOtp(String phone08) async {
    final uri = Uri.parse('$_base/api/otp/send');
    final res = await http
        .post(uri, headers: _headers, body: jsonEncode({'phone': phone08}))
        .timeout(_timeout);
    if (res.statusCode != 200) throw 'HTTP ${res.statusCode}: ${res.body}';
    final token = (jsonDecode(res.body)['token'] ?? '') as String;
    if (token.isEmpty) throw 'No token from backend';
    return token;
  }

  static Future<bool> validateOtp({
    required String token,
    required String code,
  }) async {
    final uri = Uri.parse('$_base/api/otp/validate');
    final res = await http
        .post(
          uri,
          headers: _headers,
          body: jsonEncode({'token': token, 'otp_code': code}),
        )
        .timeout(_timeout);
    if (res.statusCode != 200) return false;
    return (jsonDecode(res.body)['valid'] == true);
  }
}
