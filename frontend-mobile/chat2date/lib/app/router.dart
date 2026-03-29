// lib/app/router.dart
// รวม route ทั้งหมดไว้ที่เดียว — แยกตาม feature group

import 'package:chat2date/features/auth/screens/index.dart';
import 'package:chat2date/features/chat/screens/chat_list_screen.dart';
import 'package:chat2date/features/chat/screens/inside_chat_screen.dart';
import 'package:chat2date/features/discovery/screens/component_test_screen.dart';
import 'package:chat2date/features/discovery/screens/main_tabs.dart';
import 'package:chat2date/features/discovery/screens/ui_showcase_screen.dart';
import 'package:chat2date/features/game/screens/guessing_game_screen.dart';
import 'package:chat2date/features/match/screens/match_success_screen.dart';
import 'package:chat2date/features/menu/screens/profile_screen.dart';
import 'package:chat2date/features/profile/screens/all_selection_screen.dart';
import 'package:chat2date/features/profile/screens/match_preference_screen.dart';
import 'package:chat2date/features/profile/screens/profile_setup_screen.dart';
import 'package:chat2date/features/profile/screens/user_picture_screen.dart';
import 'package:chat2date/features/report/screens/user_report_screen.dart';
import 'package:chat2date/features/settings/screens/settings_screen.dart';
import 'package:chat2date/features/settings/screens/widgets/account_screen.dart';
import 'package:chat2date/features/settings/screens/widgets/about_screen.dart';
import 'package:chat2date/features/settings/screens/widgets/contact_screen.dart';
import 'package:flutter/material.dart';

/// Route แรกที่เข้ามา
const String initialRoute = '/login';

/// สร้าง route map ทั้งหมดของแอป
Map<String, WidgetBuilder> buildAppRoutes() {
  return {
    // ─── Auth Flow ───────────────────────────────────
    '/login': (context) => const HomeLoginPage(),
    '/policy': (context) => const PolicyPage(),
    '/phone': (context) => const PhonePage(),
    '/otp': (context) => const OtpPage(),
    '/auth': (context) => const AuthCheckPage(),
    '/kyc-id-ocr': (context) => const IdOcrScreen(),
    '/face-scan': (context) => const FaceVerifyScreen(),
    '/kyc-loading': (context) => const KycLoadingScreen(),
    '/kyc-result-success': (context) => const KycResultSuccessScreen(),
    '/kyc-result-fail': (context) => const KycResultFailScreen(),

    // ─── Main (หลัง Login สำเร็จ) ────────────────────
    '/main': (context) => const MainTabs(),

    // ─── Profile / Setup ─────────────────────────────
    '/profileSetup': (context) => const ProfileSetupScreen(),
    '/lifestylesSelection': (context) => LifestylesSelectionScreen(),
    '/interestsSelection': (context) => InterestsSelectionScreen(),
    '/tagsSelection': (context) => TagsSelectionScreen(),
    '/matchPreference': (context) => MatchPreferenceScreen(),
    '/userPicture': (context) => const UserPictureScreen(),
    '/profile': (context) => const ProfileScreen(),

    // ─── Chat ────────────────────────────────────────
    '/chatList': (context) => const ChatListScreen(),
    '/chat': (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return InsideChatScreen(
        roomId: args?['roomId'],
        targetUserId: args?['targetUserId'],
        userName: args?['userName'],
        avatarUrl: args?['avatarUrl'],
      );
    },

    // ─── Game ────────────────────────────────────────
    '/guessingGame': (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return GuessingGameScreen(roomId: args?['roomId']);
    },

    // ─── Settings ────────────────────────────────────
    '/settings': (context) => const SettingsScreen(),
    '/account-settings': (context) => const AccountSettingsScreen(),
    '/about': (context) => const AboutScreen(),
    '/contact': (context) => const ContactScreen(),

    // ─── Report ──────────────────────────────────────
    '/report': (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return UserReportScreen(
        roomId: args?['roomId'],
        targetUserId: args?['targetUserId'],
        userName: args?['userName'],
        avatarUrl: args?['avatarUrl'],
      );
    },

    // ─── Match ───────────────────────────────────────
    MatchSuccessScreen.routeName: (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as MatchSuccessArgs;
      return MatchSuccessScreen(args: args);
    },

    // ─── Dev / Test ──────────────────────────────────
    '/test': (context) => const ComponentTestScreen(),
    '/ui': (context) => const UiShowcaseScreen(),
  };
}
