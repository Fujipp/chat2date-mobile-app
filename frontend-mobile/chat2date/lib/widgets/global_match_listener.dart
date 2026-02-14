import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat2date/models/dto/match_event_dto.dart';
import 'package:chat2date/models/user.dart';
import 'package:chat2date/screens/match/match_success_screen.dart';
import 'package:chat2date/services/match_socket_service.dart';
import 'package:chat2date/stores/user_store.dart';

/// Global listener สำหรับ match events
/// Widget นี้จะ listen WebSocket match events ตลอดเวลาและ navigate ไปหน้า match success
/// ไม่ว่า user จะอยู่หน้าไหนก็ตาม
class GlobalMatchListener extends ConsumerStatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState>? navigatorKey;

  const GlobalMatchListener({
    super.key,
    required this.child,
    this.navigatorKey,
  });

  @override
  ConsumerState<GlobalMatchListener> createState() => _GlobalMatchListenerState();
}

class _GlobalMatchListenerState extends ConsumerState<GlobalMatchListener> {
  static const _duplicateWindow = Duration(seconds: 30);

  bool _isNavigatingToMatch = false;
  String? _lastEventKey;
  DateTime? _lastEventAt;

  String _buildEventKey(MatchEventDto event) {
    return '${event.matchId ?? ''}|${event.selfUserId}|${event.partnerUserId}|${event.matchedAt?.toIso8601String() ?? ''}';
  }

  bool _isDuplicateEvent(String eventKey) {
    if (_lastEventKey != eventKey || _lastEventAt == null) return false;
    return DateTime.now().difference(_lastEventAt!) <= _duplicateWindow;
  }

  void _handleMatchEvent(MatchEventDto event) {
    if (_isNavigatingToMatch) {
      print('[GlobalMatchListener] navigation in progress, skip duplicate event');
      return;
    }

    final eventKey = _buildEventKey(event);
    if (_isDuplicateEvent(eventKey)) {
      print('[GlobalMatchListener] duplicate match event ignored: $eventKey');
      return;
    }

    _isNavigatingToMatch = true;
    _lastEventKey = eventKey;
    _lastEventAt = DateTime.now();

    // ใช้ addPostFrameCallback เพื่อป้องกัน setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        _isNavigatingToMatch = false;
        return;
      }

      final navigator = widget.navigatorKey?.currentState;
      if (navigator == null) {
        // ถ้า navigatorKey ยังไม่มี state แสดงว่ายังหา navigator ไม่เจอ ป้องกัน exception
        print('[GlobalMatchListener] navigator not ready, skip navigation');
        _isNavigatingToMatch = false;
        return;
      }

      navigator
          .pushNamed(
            MatchSuccessScreen.routeName,
            arguments: MatchSuccessArgs(
              matchId: event.matchId,
              partnerUserId: event.partnerUserId,
              myName: event.selfName,
              partnerName: event.partnerName,
              myAvatarUrl: event.selfAvatarUrl,
              partnerAvatarUrl: event.partnerAvatarUrl,
            ),
          )
          .whenComplete(() {
            _isNavigatingToMatch = false;
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    // ดึง userId จาก userStore
    final userState = ref.watch(userStoreProvider);
    final user = userState['user'] as User?;
    final userId = user?.userId;

    // ถ้าไม่มี userId (ยังไม่ได้ login) ไม่ต้อง listen
    if (userId == null || userId.isEmpty) {
      return widget.child;
    }

    // Listen match events
    ref.listen<AsyncValue<MatchEventDto>>(
      matchSocketStreamProvider(userId),
      (previous, next) {
        final event = next.valueOrNull;
        if (event == null) return;

        print('[GlobalMatchListener] Match event received: ${event.selfName} <-> ${event.partnerName}');
        _handleMatchEvent(event);
      },
    );

    return widget.child;
  }
}
