import 'dart:convert';
import 'package:chat2date/models/dto/preference_dto.dart';
import 'package:http/http.dart' as http;
import 'package:chat2date/config/backend_base.dart'; // << เพิ่มบรรทัดนี้

class PreferenceService{
  static String get _base => ApiBase.baseUrl; // << ใช้จากไฟล์ใหม่
  //static const _headers = {'Content-Type': 'application/json'};

  static Future<PreferenceDto> getPreference() async {
    final uri = Uri.parse('$_base/preferences');
    final res = await http
        .get(uri);
    if (res.statusCode != 200) throw 'HTTP ${res.statusCode}: ${res.body}';

    final jsonBody = jsonDecode(res.body);
    
    return PreferenceDto.fromJson(jsonBody);
  }
}