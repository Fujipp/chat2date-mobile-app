import 'package:flutter/foundation.dart';
import 'dart:convert';

import 'package:chat2date/core/config/backend_base.dart';
import 'package:chat2date/core/utils/authenticated_client.dart';
import 'package:chat2date/models/dto/discovery_dto.dart';
import 'package:chat2date/models/dto/feedback_response_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiscoveryService {
  final Ref ref;

  DiscoveryService(this.ref);

  Future<List<DiscoveryResponse>> getCandidates({
    required String userId,
    int minDistance = 1,
    int maxDistance = 160,
  }) async {
    final client = ref.read(authenticatedClientProvider);

    try {
      final queryParams = {
        'userId': userId,
        'minDistance': minDistance.toString(),
        'maxDistance': maxDistance.toString(),
      };

      final uri = Uri.parse(
        '${ApiBase.baseUrl}/discovery',
      ).replace(queryParameters: queryParams);

      debugPrint('🌐 Fetching: $uri');

      final response = await client.get(uri);

      debugPrint('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        debugPrint('✅ Loaded ${data.length} candidates');
        return data.map((json) => DiscoveryResponse.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load candidates: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching candidates: $e');
      rethrow;
    }
  }

  Future<FeedbackResponseDto> submitFeedback({
    required String userId,
    required String targetUserId,
    required String action,
  }) async {
    final client = ref.read(authenticatedClientProvider);

    final uri = Uri.parse(
      '${ApiBase.baseUrl}/discovery/feedback',
    ).replace(queryParameters: {'userId': userId});

    final body = {'targetUserId': targetUserId, 'action': action};

    debugPrint('➡️ [Feedback] POST $uri');
    debugPrint('   body   : ${jsonEncode(body)}');

    final res = await client.post(
      uri,
      body: jsonEncode(body),
    );

    debugPrint('⬅️ [Feedback] status: ${res.statusCode}');
    debugPrint('   response body: ${res.body}');

    if (res.statusCode != 201) {
      throw Exception('Feedback failed: ${res.statusCode} ${res.body}');
    }

    final Map<String, dynamic> json = jsonDecode(res.body);
    return FeedbackResponseDto.fromJson(json);
  }
}

final discoveryServiceProvider = Provider<DiscoveryService>((ref) {
  return DiscoveryService(ref);
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
  static const Duration _minimumLoadingDuration = Duration(milliseconds: 3200);
  static const int _prefetchThreshold = 4;

  // ✅ เพิ่ม flag เพื่อป้องกันการเรียก API ซ้ำซ้อน
  bool _isLoadingInProgress = false;
  bool _isPrefetchInProgress = false;
  int? _pendingMinDistance;
  int? _pendingMaxDistance;
  int _lastMinDistance = 1;
  int _lastMaxDistance = 160;

  DiscoveryNotifier(this._service, this.userId) : super(DiscoveryState());

  /// โหลด candidates ใหม่
  Future<void> loadCandidates({
    int minDistance = 1,
    int maxDistance = 160,
  }) async {
    if (_isLoadingInProgress) {
      if (_pendingMinDistance == minDistance &&
          _pendingMaxDistance == maxDistance) {
        return;
      }
      return;
    }

    // ✅ เช็คว่า notifier ยัง mount อยู่หรือไม่
    if (!mounted) {
      debugPrint('⚠️ Notifier disposed, skipping load');
      return;
    }

    _isLoadingInProgress = true;
    _pendingMinDistance = minDistance;
    _pendingMaxDistance = maxDistance;
    _lastMinDistance = minDistance;
    _lastMaxDistance = maxDistance;
    state = state.copyWith(isLoading: true, error: null);
    final stopwatch = Stopwatch()..start();

    try {
      final candidates = await _service.getCandidates(
        userId: userId,
        minDistance: minDistance,
        maxDistance: maxDistance,
      );

      final remaining = _minimumLoadingDuration - stopwatch.elapsed;
      if (remaining > Duration.zero) {
        await Future.delayed(remaining);
      }

      // ✅ เช็คอีกครั้งหลัง await
      if (!mounted) {
        debugPrint('⚠️ Notifier disposed after load, discarding results');
        return;
      }

      debugPrint('✅ Loaded ${candidates.length} candidates');

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
        _prefetchCandidatesIfNeeded();
      }
    } catch (e) {
      debugPrint('❌ Error in loadCandidates: $e');

      final remaining = _minimumLoadingDuration - stopwatch.elapsed;
      if (remaining > Duration.zero) {
        await Future.delayed(remaining);
      }

      if (!mounted) {
        debugPrint('⚠️ Notifier disposed during error handling');
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
      _pendingMinDistance = null;
      _pendingMaxDistance = null;
    }
  }

  /// ไปหน้า candidate ถัดไป
  void nextCandidate() {
    if (!mounted) return;
    debugPrint(state.hasMore.toString());
    if (state.hasMore) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
      debugPrint(
        '📍 Current index: ${state.currentIndex}/${state.candidates.length - 1}',
      );
      _prefetchCandidatesIfNeeded();
    } else {
      state = state.copyWith(currentIndex: 0, candidates: []);
    }
  }

  Future<void> _prefetchCandidatesIfNeeded() async {
    if (!mounted || _isPrefetchInProgress || _isLoadingInProgress) return;

    final remaining = state.candidates.length - state.currentIndex - 1;
    if (remaining > _prefetchThreshold) return;

    _isPrefetchInProgress = true;

    try {
      final nextBatch = await _service.getCandidates(
        userId: userId,
        minDistance: _lastMinDistance,
        maxDistance: _lastMaxDistance,
      );

      if (!mounted || nextBatch.isEmpty) return;

      final existingIds = state.candidates.map((e) => e.userId).toSet();
      final uniqueNewCandidates = nextBatch
          .where((candidate) => !existingIds.contains(candidate.userId))
          .toList();

      if (uniqueNewCandidates.isEmpty) return;

      state = state.copyWith(
        candidates: [...state.candidates, ...uniqueNewCandidates],
      );
    } catch (_) {
      // ignore prefetch failures to avoid interrupting current swipe flow
    } finally {
      _isPrefetchInProgress = false;
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

      debugPrint('👍 Liked: ${candidate.nickname}');
      nextCandidate();

      return feedback; // ✅ คืน feedback ออกไปให้ UI ใช้เช็ค matched
    } catch (e) {
      debugPrint('❌ Like error: $e');
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

      debugPrint('👎 Unliked: ${candidate.nickname}');
    } catch (e) {
      debugPrint('❌ Unlike error: $e');
    }

    nextCandidate();
  }

  /// Refresh candidates
  Future<void> refresh({int minDistance = 1, int maxDistance = 160}) async {
    if (!mounted) return;

    debugPrint('🔄 Refreshing candidates...');
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
