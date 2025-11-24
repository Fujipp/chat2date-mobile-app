import 'dart:convert';

import 'package:chat2date/config/backend_base.dart';
import 'package:chat2date/models/dto/discovery_dto.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class DiscoveryService {
  final String? accessToken;

  DiscoveryService({this.accessToken});

  /// ดึงรายชื่อ candidates สำหรับ discovery
  Future<List<DiscoveryResponse>> getCandidates({
    required String userId,
    int minDistance = 1,
    int maxDistance = 1800,
  }) async {
    try {
      final queryParams = {
        'userId': userId,
        'minDistance': minDistance.toString(),
        'maxDistance': maxDistance.toString(),
      };

      final uri = Uri.parse(
        '${ApiBase.baseUrl}/discovery',
      ).replace(queryParameters: queryParams);

      print('🌐 Fetching: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('✅ Loaded ${data.length} candidates');
        return data.map((json) => DiscoveryResponse.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load candidates: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching candidates: $e');
      rethrow;
    }
  }

  Future<void> submitFeedback({
  required String userId,
  required String targetUserId,
  required String action, // "LIKE" / "DISLIKE"
}) async {
  final uri = Uri.parse('${ApiBase.baseUrl}/discovery/feedback')
      .replace(queryParameters: {'userId': userId});

  final body = {
    'targetUserId': targetUserId,
    'action': action,
  };

  print('➡️ [Feedback] POST $uri');
  print('   headers: ${{
    'Content-Type': 'application/json',
    if (accessToken != null) 'Authorization': 'Bearer $accessToken',
  }}');
  print('   body   : ${jsonEncode(body)}');

  final res = await http.post(
    uri,
    headers: {
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    },
    body: jsonEncode(body),
  );

  print('⬅️ [Feedback] status: ${res.statusCode}');
  print('   response body: ${res.body}');

  if (res.statusCode != 201) {
    throw Exception('Feedback failed: ${res.statusCode} ${res.body}');
  }
}

}

final discoveryServiceProvider = Provider<DiscoveryService>((ref) {
  final userStore = ref.watch(userStoreProvider);
  final accessToken = userStore['accessToken'] as String?;

  if (accessToken == null) {
    throw Exception('Access token not found');
  }

  return DiscoveryService(accessToken: accessToken);
});

class DiscoveryState {
  final List<DiscoveryResponse> candidates;
  final bool isLoading;
  final String? error;
  final int currentIndex;

  DiscoveryState({
    this.candidates = const [],
    this.isLoading = false,
    this.error,
    this.currentIndex = 0,
  });

  DiscoveryState copyWith({
    List<DiscoveryResponse>? candidates,
    bool? isLoading,
    String? error,
    int? currentIndex,
  }) {
    return DiscoveryState(
      candidates: candidates ?? this.candidates,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  DiscoveryResponse? get currentCandidate {
    if (candidates.isEmpty || currentIndex >= candidates.length) {
      return null;
    }
    return candidates[currentIndex];
  }

  bool get hasMore => currentIndex < candidates.length - 1;
  bool get isEmpty => candidates.isEmpty;
}

class DiscoveryNotifier extends StateNotifier<DiscoveryState> {
  final DiscoveryService _service;
  final String userId;

  DiscoveryNotifier(this._service, this.userId) : super(DiscoveryState());

  /// โหลด candidates ใหม่
  Future<void> loadCandidates({
    int minDistance = 1,
    int maxDistance = 1800,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final candidates = await _service.getCandidates(
        userId: userId,
        minDistance: minDistance,
        maxDistance: maxDistance,
      );

      print('✅ Loaded ${candidates.length} candidates');

      state = state.copyWith(
        candidates: candidates,
        isLoading: false,
        currentIndex: 0,
      );
    } catch (e) {
      print('❌ Error in loadCandidates: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// ไปหน้า candidate ถัดไป
  void nextCandidate() {
    if (state.hasMore) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
      print(
        '📍 Current index: ${state.currentIndex}/${state.candidates.length - 1}',
      );
    } else {
      print('⚠️ No more candidates');
    }
  }

  /// Like candidate ปัจจุบัน
  Future<void> likeCurrentCandidate() async {
  final candidate = state.currentCandidate;
  if (candidate == null) return;

  try {
    await _service.submitFeedback(
      userId: userId,
      targetUserId: candidate.userId,   // ต้องมี field นี้ใน DiscoveryResponse
      action: 'LIKE',
    );
    print('👍 Liked: ${candidate.nickname}');
  } catch (e) {
    print('❌ Like error: $e');
  }

  nextCandidate();
}

  /// Unlike candidate ปัจจุบัน
  Future<void> unlikeCurrentCandidate() async {
  final candidate = state.currentCandidate;
  if (candidate == null) return;

  try {
    await _service.submitFeedback(
      userId: userId,
      targetUserId: candidate.userId,
      action: 'DISLIKE',
    );
    print('👎 Unliked: ${candidate.nickname}');
  } catch (e) {
    print('❌ Unlike error: $e');
  }

  nextCandidate();
}


  /// Refresh candidates
  Future<void> refresh({int minDistance = 1, int maxDistance = 1800}) async {
    print('🔄 Refreshing candidates...');
    await loadCandidates(minDistance: minDistance, maxDistance: maxDistance);
  }
}

/// Provider สำหรับ DiscoveryNotifier
final discoveryProvider =
    StateNotifierProvider.family<DiscoveryNotifier, DiscoveryState, String>((
      ref,
      userId,
    ) {
      final service = ref.watch(discoveryServiceProvider);
      return DiscoveryNotifier(service, userId);
    });
