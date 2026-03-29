import 'dart:convert';

import 'package:chat2date/core/config/backend_base.dart';
import 'package:chat2date/core/utils/authenticated_client.dart';
import 'package:chat2date/models/dto/game_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class GameService {
  final Ref ref;

  GameService({required this.ref});

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

  Future<http.Response> sendPlayerReady(String gameId) async {
    final client = ref.read(authenticatedClientProvider);
    final uri = Uri.parse('${ApiBase.baseUrl}/games/ready/$gameId');
    final response = await client.post(uri);
    _checkError(response);
    return response as http.Response; // Since authenticated client extends http.BaseClient
  }

  Future<void> sendTimeout(String gameId) async {
    final client = ref.read(authenticatedClientProvider);
    final uri = Uri.parse('${ApiBase.baseUrl}/games/timeout/$gameId');
    await client.post(uri);
  }

  // --- Helper Methods ---
  Future<http.Response> _get(Uri uri) async {
    print('🌐 GET: $uri');
    final client = ref.read(authenticatedClientProvider);
    final response = await client.get(uri);
    _checkError(response);
    return response as http.Response;
  }

  Future<http.Response> _post(Uri uri, Map<String, dynamic> body) async {
    print('🌐 POST: $uri');
    final client = ref.read(authenticatedClientProvider);
    final response = await client.post(
      uri,
      body: jsonEncode(body),
    );
    _checkError(response);
    return response as http.Response;
  }

  void _checkError(http.Response response) {
    if (response.statusCode >= 400) {
      print('❌ Error ${response.statusCode}: ${response.body}');
      throw Exception('API Error: ${response.statusCode}');
    }
  }
}

final gameServiceProvider = Provider<GameService>((ref) {
  return GameService(ref: ref);
});
