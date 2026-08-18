import 'dart:async';

import 'package:chat2date/components/common/modal_component.dart';
import 'package:chat2date/models/user.dart';
import 'package:chat2date/services/auth_service.dart';
import 'package:chat2date/services/user_socket_service.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GlobalUserListener extends ConsumerStatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const GlobalUserListener({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  @override
  ConsumerState<GlobalUserListener> createState() => _GlobalUserListenerState();
}

class _GlobalUserListenerState extends ConsumerState<GlobalUserListener> {
  UserSocketService? _socketService;
  StreamSubscription? _subscription;
  String? _currentUserId; // track ว่า connect ให้ userId ไหนอยู่

  @override
  void dispose() {
    _subscription?.cancel();
    _socketService?.dispose();
    super.dispose();
  }

  // เรียกทุกครั้งที่ build — ถ้า userId เปลี่ยน (login/logout) จะ reconnect
  void _syncSocket(String? userId, String? accessToken) {
    if (userId == _currentUserId) return;

    // cleanup ของเก่า
    _subscription?.cancel();
    _socketService?.dispose();
    _socketService = null;
    _currentUserId = userId;

    if (userId == null || userId.isEmpty) return; // logout แล้ว ไม่ต้อง connect

    _socketService = UserSocketService(
      userId: userId,
      accessToken: accessToken,
    );
    _socketService!.connect();
    _subscription = _socketService!.stream.listen(_handleEvent);
  }

  void _handleEvent(Map<String, dynamic> payload) {
    final type = payload['type'];
    if (type == 'BEHAVIOR_BANNED') {
      _showBannedDialog();
    }
  }

  Future<void> _showBannedDialog() async {
    final context = widget.navigatorKey.currentContext;
    if (context == null) return;

    // แสดง dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Dialog(
        backgroundColor: Colors.transparent,
        child: ModalComponent(
          svgPath: 'assets/icons/ui/icon_banning.svg',
          heightSvg: 68,
          widthSvg: 77,
          topic: 'คุณถูกแบน',
          description:
              'เนื่องจากคุณโดนรายงาน และตรวจสอบแล้วว่าผิดจริง\n'
              'ทำให้คะแนนความประพฤติต่ำกว่าเกณฑ์ที่กำหนด\n'
              'คุณจะไม่สามารถใช้บัญชีนี้ได้อีกต่อไปและไม่สามารถ\n'
              'สร้างบัญชีใหม่ของคุณได้อีก',
        ),
      ),
    );

    // รอ 5 วิ แล้ว signOut + เด้งออก
    await Future.delayed(const Duration(seconds: 5));

    if (widget.navigatorKey.currentContext != null) {
      Navigator.of(widget.navigatorKey.currentContext!).pop(); // ปิด dialog
    }

    await ref.read(authServiceProvider).signOut();

    widget.navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userStoreProvider);
    final user = userState['user'] as User?;
    final accessToken = userState['accessToken'] as String?;

    // sync socket ทุกครั้งที่ userId เปลี่ยน
    _syncSocket(user?.userId, accessToken);

    return widget.child;
  }
}
