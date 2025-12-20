import 'package:chat2date/screens/match/match_success_screen.dart';
import 'package:chat2date/theme/app_theme.dart';
import 'package:chat2date/widgets/global_match_listener.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'screens/index.dart';
import 'screens/main_tabs.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  // ต้องเรียกก่อนใช้ async ใน main เสมอ
  WidgetsFlutterBinding.ensureInitialized();

  // โหลด .env
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return GlobalMatchListener(
      navigatorKey: navigatorKey,
      child: MaterialApp(
        title: 'Component Test',
        theme: buildLightTheme(),
        navigatorKey: navigatorKey,
        initialRoute: '/home', //เวลาโค้ดเปลี่ยนเป็น path ตัวเองเอาไว้แสดง
        routes: {
          //Test
          '/test': (context) => const ComponentTestScreen(),
          // '/test-match': (context) => const MatchSuccessScreen(
          //   args: MatchSuccessArgs(
          //     myName: 'คุณ',
          //     partnerName: 'แมทช์',
          //     myAvatarUrl: null,
          //     partnerAvatarUrl: null,
          //   ),
          // ),

          //Amp
          '/profileSetup': (context) => const ProfileSetupScreen(),
          '/lifestylesSelection': (context) => LifestylesSelectionScreen(),
          '/interestsSelection': (context) => InterestsSelectionScreen(),
          '/tagsSelection': (context) => TagsSelectionScreen(),
          '/matchPreference': (context) => MatchPreferenceScreen(),
          '/userPicture': (context) => const UserPictureScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/auth': (context) => const AuthCheckPage(),
          '/chat': (context) => const ChatScreen(),

          //Hutch
          '/discovery': (context) => const DiscoveryScreen(),
          '/main': (context) => const MainTabs(),

          //Fuji
          '/home': (context) => const HomeLoginPage(),
          '/policy': (context) => const PolicyPage(),
          '/phone': (context) => const PhonePage(),
          '/otp': (context) => const OtpPage(),
          '/kyc-id-ocr': (context) => const IdOcrScreen(),
          '/face-scan': (context) => const FaceVerifyScreen(),
          '/kyc-loading': (context) => const KycLoadingScreen(),
          '/kyc-result-success': (context) => const KycResultSuccessScreen(),
          '/kyc-result-fail': (context) => const KycResultFailScreen(),

          MatchSuccessScreen.routeName: (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments as MatchSuccessArgs;
            return MatchSuccessScreen(args: args);
          },
        },
        builder: (context, child) {
          return Stack(
            children: [
              child ?? const SizedBox(),
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton(
                  onPressed: () {
                    final nav = navigatorKey.currentState!;
                    if (nav.canPop()) {
                      nav.pop(); // 🔹 ถ้ามีหน้าก่อนหน้า -> กลับ
                    } else {
                      nav.pushNamed('/test');
                    }
                  },
                  backgroundColor: Colors.blueAccent,
                  heroTag: 'globalTestBtn',
                  child: const Icon(Icons.help, color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
