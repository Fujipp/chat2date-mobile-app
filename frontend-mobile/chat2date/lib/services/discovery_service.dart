import 'dart:convert';

import 'package:chat2date/config/backend_base.dart';
import 'package:chat2date/models/dto/discovery_dto.dart';
import 'package:chat2date/models/dto/feedback_response_dto.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class DiscoveryService {
  final String? accessToken;

  DiscoveryService({this.accessToken});

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

  Future<FeedbackResponseDto> submitFeedback({
    required String userId,
    required String targetUserId,
    required String action,
  }) async {
    final uri = Uri.parse(
      '${ApiBase.baseUrl}/discovery/feedback',
    ).replace(queryParameters: {'userId': userId});

    final body = {'targetUserId': targetUserId, 'action': action};

    print('➡️ [Feedback] POST $uri');
    print(
      '   headers: ${{'Content-Type': 'application/json', if (accessToken != null) 'Authorization': 'Bearer $accessToken'}}',
    );
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

    final Map<String, dynamic> json = jsonDecode(res.body);
    return FeedbackResponseDto.fromJson(json);
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
  final bool hasLoadedOnce;
  final bool isInitializing;

  DiscoveryState({
    this.candidates = const [],
    this.isLoading = false,
    this.error,
    this.currentIndex = 0,
    this.hasLoadedOnce = false,
    this.isInitializing = true,
  });

  DiscoveryState copyWith({
    List<DiscoveryResponse>? candidates,
    bool? isLoading,
    String? error,
    int? currentIndex,
    bool? hasLoadedOnce,
    bool? isInitializing,
  }) {
    return DiscoveryState(
      candidates: candidates ?? this.candidates,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentIndex: currentIndex ?? this.currentIndex,
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
      isInitializing: isInitializing ?? this.isInitializing,
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

  // ✅ เพิ่ม flag เพื่อป้องกันการเรียก API ซ้ำซ้อน
  bool _isLoadingInProgress = false;

  DiscoveryNotifier(this._service, this.userId) : super(DiscoveryState());

  /// โหลด candidates ใหม่
  Future<void> loadCandidates({
    int minDistance = 1,
    int maxDistance = 1800,
  }) async {
    // ✅ ถ้ากำลังโหลดอยู่แล้ว ข้ามไป
    if (_isLoadingInProgress) {
      print('⚠️ Load already in progress, skipping...');
      return;
    }

    // ✅ เช็คว่า notifier ยัง mount อยู่หรือไม่
    if (!mounted) {
      print('⚠️ Notifier disposed, skipping load');
      return;
    }

    _isLoadingInProgress = true;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final candidates = await _service.getCandidates(
        userId: userId,
        minDistance: minDistance,
        maxDistance: maxDistance,
      );

      // ✅ เช็คอีกครั้งหลัง await
      if (!mounted) {
        print('⚠️ Notifier disposed after load, discarding results');
        return;
      }

      print('✅ Loaded ${candidates.length} candidates');

      if (candidates.isEmpty) {
        state = state.copyWith(
          candidates: candidates,
          currentIndex: 0,
          hasLoadedOnce: true,
          isLoading: false,
          isInitializing: false,
        );
      } else {
        state = state.copyWith(
          candidates: candidates,
          isLoading: false,
          currentIndex: 0,
          hasLoadedOnce: true,
          isInitializing: false,
        );
      }
    } catch (e) {
      print('❌ Error in loadCandidates: $e');

      if (!mounted) {
        print('⚠️ Notifier disposed during error handling');
        return;
      }

      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        hasLoadedOnce: true,
        isInitializing: false, // ✅ เซ็ต false แม้จะ error
      );
    } finally {
      _isLoadingInProgress = false;
    }
  }

  /// ไปหน้า candidate ถัดไป
  void nextCandidate() {
    if (!mounted) return;
    print(state.hasMore);
    if (state.hasMore) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
      print(
        '📍 Current index: ${state.currentIndex}/${state.candidates.length - 1}',
      );
    } else {
      state = state.copyWith(currentIndex: 0, candidates: []);
    }
  }

  /// Like candidate ปัจจุบัน
  Future<FeedbackResponseDto?> likeCurrentCandidate() async {
    if (!mounted) return null;

    final candidate = state.currentCandidate;
    if (candidate == null) return null;

    try {
      final feedback = await _service.submitFeedback(
        userId: userId,
        targetUserId: candidate.userId,
        action: 'LIKE',
      );

      if (!mounted) return null;

      print('👍 Liked: ${candidate.nickname}');
      nextCandidate();

      return feedback; // ✅ คืน feedback ออกไปให้ UI ใช้เช็ค matched
    } catch (e) {
      print('❌ Like error: $e');
      return null;
    }
  }

  /// Unlike candidate ปัจจุบัน
  Future<void> unlikeCurrentCandidate() async {
    if (!mounted) return;

    final candidate = state.currentCandidate;
    if (candidate == null) return;

    try {
      await _service.submitFeedback(
        userId: userId,
        targetUserId: candidate.userId,
        action: 'DISLIKE',
      );

      if (!mounted) return;

      print('👎 Unliked: ${candidate.nickname}');
    } catch (e) {
      print('❌ Unlike error: $e');
    }

    nextCandidate();
  }

  /// Refresh candidates
  Future<void> refresh({int minDistance = 1, int maxDistance = 1800}) async {
    if (!mounted) return;

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
