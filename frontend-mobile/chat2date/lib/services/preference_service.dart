import 'dart:convert';
import 'package:chat2date/models/dto/preference_dto.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:chat2date/core/config/backend_base.dart';
import 'package:chat2date/core/utils/authenticated_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final preferenceServiceProvider = Provider(
  (ref) => PreferenceService(ref),
);

class PreferenceService{
  final Ref ref;
  static String get _base => ApiBase.baseUrl;
  PreferenceService(this.ref);

  Future<PreferenceDto> getPreference() async {
    final client = ref.read(authenticatedClientProvider);
    final uri = Uri.parse('$_base/preferences');
    
    final res = await client.get(uri);
    
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