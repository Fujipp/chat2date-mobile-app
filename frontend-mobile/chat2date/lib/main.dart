import 'package:chat2date/app/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';

/// Handle FCM notification tap to navigate to chat
void _handleNotificationNavigation(RemoteMessage message) {
  final data = message.data;
  final roomId = data['roomId'] as String?;
  final targetUserId = data['targetUserId'] as String?;
  final userName = data['userName'] as String?;
  final avatarUrl = data['avatarUrl'] as String?;

  if (roomId != null && roomId.isNotEmpty) {
    // Navigate to chat screen
    MyApp.navigatorKey.currentState?.pushNamed(
      '/chat',
      arguments: {
        'roomId': roomId,
        'targetUserId': targetUserId,
        'userName': userName,
        'avatarUrl': avatarUrl,
      },
    );
  }
}

Future<void> main() async {
  // ต้องเรียกก่อนใช้ async ใน main เสมอ
  WidgetsFlutterBinding.ensureInitialized();

  // โหลด .env
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Setup FCM message handlers
  _setupFcmHandlers();
  _forceDisableDebugPaint();

  runApp(const ProviderScope(child: MyApp()));
}

void _forceDisableDebugPaint() {
  assert(() {
    void disableFlags(Duration _) {
      debugPaintBaselinesEnabled = false;
      debugPaintSizeEnabled = false;
      debugPaintPointersEnabled = false;
      debugRepaintRainbowEnabled = false;
      debugPaintLayerBordersEnabled = false;
      SchedulerBinding.instance.scheduleFrameCallback(disableFlags);
    }

    disableFlags(Duration.zero);
    return true;
  }());
}

void _setupFcmHandlers() {
  final messaging = FirebaseMessaging.instance;

  // Handle notification tap when app is in background
  FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationNavigation);

  // Handle notification tap when app was terminated
  messaging.getInitialMessage().then((message) {
    if (message != null) {
      // Delay navigation until app is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNotificationNavigation(message);
      });
    }
  });
}
