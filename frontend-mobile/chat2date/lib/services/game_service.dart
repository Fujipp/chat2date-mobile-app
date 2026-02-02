import 'dart:convert';

import 'package:chat2date/config/backend_base.dart';
import 'package:chat2date/models/dto/game_dto.dart'; 
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class GameService {
  final String? accessToken;

  GameService({this.accessToken});

  Future<GameCheckResponseDto> checkGameStatus(int roomId) async {
    final uri = Uri.parse('${ApiBase.baseUrl}/games/check/$roomId');
    final response = await _get(uri);
    return GameCheckResponseDto.fromJson(jsonDecode(response.body));
  }

  Future<GameInfoResponseDto> createGame(int roomId) async {
    final uri = Uri.parse('${ApiBase.baseUrl}/games/question');
    final response = await _post(uri, {'roomId': roomId});

    return GameInfoResponseDto.fromJson(jsonDecode(response.body));
  }

  Future<GameInfoResponseDto> getGameInfo(String gameId) async {
    final uri = Uri.parse('${ApiBase.baseUrl}/games/$gameId');
    final response = await _get(uri);
    return GameInfoResponseDto.fromJson(jsonDecode(response.body));
  }

  Future<GameAnswerResponseDto> answerQuestion({
    required String gameId,
    required String questionId,
    required String selectedOption,
  }) async {
    final uri = Uri.parse('${ApiBase.baseUrl}/games/answer');
    final response = await _post(uri, {
      'gameId': gameId,
      'questionId': questionId,
      'selectedOption': selectedOption,
    });
    return GameAnswerResponseDto.fromJson(jsonDecode(response.body));
  }

  // --- Helper Methods ---
  Future<http.Response> _get(Uri uri) async {
    print('🌐 GET: $uri');
    final response = await http.get(uri, headers: _headers());
    _checkError(response);
    return response;
  }

  Future<http.Response> _post(Uri uri, Map<String, dynamic> body) async {
    print('🌐 POST: $uri');
    final response = await http.post(
      uri,
      headers: _headers(),
      body: jsonEncode(body),
    );
    _checkError(response);
    return response;
  }

  Map<String, String> _headers() => {
    'Content-Type': 'application/json',
    if (accessToken != null) 'Authorization': 'Bearer $accessToken',
  };

  void _checkError(http.Response response) {
    if (response.statusCode >= 400) {
      print('❌ Error ${response.statusCode}: ${response.body}');
      throw Exception('API Error: ${response.statusCode}');
    }
  }
}

final gameServiceProvider = Provider<GameService>((ref) {
  final userStore = ref.watch(userStoreProvider);
  final accessToken = userStore['accessToken'] as String?;
  if (accessToken == null) throw Exception('Access token not found');
  return GameService(accessToken: accessToken);
});
