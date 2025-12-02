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
class GlobalMatchListener extends ConsumerWidget {
  final Widget child;
  final GlobalKey<NavigatorState>? navigatorKey;

  const GlobalMatchListener({
    super.key,
    required this.child,
    this.navigatorKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ดึง userId จาก userStore
    final userState = ref.watch(userStoreProvider);
    final user = userState['user'] as User?;
    final userId = user?.userId;

    // ถ้าไม่มี userId (ยังไม่ได้ login) ไม่ต้อง listen
    if (userId == null || userId.isEmpty) {
      return child;
    }

    // Listen match events
    ref.listen<AsyncValue<MatchEventDto>>(
      matchSocketStreamProvider(userId),
      (previous, next) {
        final event = next.valueOrNull;
        if (event == null) return;

        print('[GlobalMatchListener] Match event received: ${event.selfName} <-> ${event.partnerName}');

        // Navigate to match success screen
        // ใช้ addPostFrameCallback เพื่อป้องกัน setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;

          final navigator = navigatorKey?.currentState;

          if (navigator == null) {
            // ถ้า navigatorKey ยังไม่มี state แสดงว่ายังหา navigator ไม่เจอ ป้องกัน exception
            print('[GlobalMatchListener] navigator not ready, skip navigation');
            return;
          }

          navigator.pushNamed(
            MatchSuccessScreen.routeName,
            arguments: MatchSuccessArgs(
              myName: event.selfName,
              partnerName: event.partnerName,
              myAvatarUrl: event.selfAvatarUrl,
              partnerAvatarUrl: event.partnerAvatarUrl,
            ),
          );
        });
      },
    );

    return child;
  }
}
