import 'dart:convert';
import 'package:chat2date/models/dto/preference_dto.dart';
import 'package:chat2date/services/user_service.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:http/http.dart' as http;
import 'package:chat2date/core/config/backend_base.dart'; // << เพิ่มบรรทัดนี้
import 'package:flutter_riverpod/flutter_riverpod.dart';

final preferenceServiceProvider = Provider(
  (ref) => PreferenceService(ref),
);

class PreferenceService{
  final Ref ref;
  static String get _base => ApiBase.baseUrl; // << ใช้จากไฟล์ใหม่
  //static const _headers = {'Content-Type': 'application/json'};
  PreferenceService(this.ref);

  Future<PreferenceDto> getPreference() async {
    final uri = Uri.parse('$_base/preferences');
    final res = await http
        .get(uri);
    if (res.statusCode != 200) throw 'HTTP ${res.statusCode}: ${res.body}';

    final jsonBody = jsonDecode(res.body);
    final prefs = PreferenceDto.fromJson(jsonBody);

    ref.read(userStoreProvider.notifier).setPreferences({
      'travelStyles': prefs.travelStyles,
      'lifeStyles': prefs.lifeStyles,
      'interests': prefs.interests,
      'tags': prefs.tags,
    });
    
    return PreferenceDto.fromJson(jsonBody);
  }
}