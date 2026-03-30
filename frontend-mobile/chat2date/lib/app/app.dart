// lib/app/app.dart
// MyApp widget — แยกออกจาก main.dart เพื่อให้ clean

import 'package:chat2date/app/router.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:chat2date/core/theme/app_theme.dart';
import 'package:chat2date/core/widgets/global_match_listener.dart';
import 'package:chat2date/core/widgets/global_user_listener.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlobalUserListener(
      navigatorKey: navigatorKey,
      child: GlobalMatchListener(
        navigatorKey: navigatorKey,
        child: MaterialApp(
          title: 'Chat2Date',
          theme: buildLightTheme(),
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQuery.copyWith(textScaler: TextScaler.noScaling),
              child: CupertinoTheme(
                data: const CupertinoThemeData(
                  primaryColor: AppColors.brandPrimary,
                ),
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
          navigatorKey: navigatorKey,
          initialRoute: initialRoute,
          routes: buildAppRoutes(),
        ),
      ),
    );
  }
}
