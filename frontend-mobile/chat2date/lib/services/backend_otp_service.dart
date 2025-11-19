import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chat2date/config/backend_base.dart'; // << เพิ่มบรรทัดนี้

class BackendOtpService {
  static String get _base => ApiBase.baseUrl; // << ใช้จากไฟล์ใหม่
  static const _headers = {'Content-Type': 'application/json'};
  static const _timeout = Duration(seconds: 15);

  static Future<String> sendOtp(String phoneNumber) async {
    final uri = Uri.parse('$_base/auth/request-otp');
    final res = await http
        .post(uri, headers: _headers, body: jsonEncode({'phoneNumber': phoneNumber}))
        .timeout(_timeout);
    if (res.statusCode != 200) throw 'HTTP ${res.statusCode}: ${res.body}';
    // final token = (jsonDecode(res.body)['token'] ?? '') as String;
    // if (token.isEmpty) throw 'No token from backend';
    // return token;
    return "true";
  }

  static Future<Map<String, dynamic>> validateOtp({
    required String token,
    required String code,
    required String phone
  }) async {
    final uri = Uri.parse('$_base/auth/verify-otp');
    final res = await http
        .post(
          uri,
          headers: _headers,
          body: jsonEncode({'token': token, 'otpCode': code, 'phoneNumber': phone}),
        )
        .timeout(_timeout);
    return {'statusCode': res.statusCode, 'body': jsonDecode(res.body)};
  }
}
