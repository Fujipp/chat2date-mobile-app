// lib/screens/auth/face_verify_screen.dart
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'face_verify_screen_android.dart';
import 'face_verify_screen_ios.dart';

class FaceVerifyScreen extends ConsumerWidget {
  const FaceVerifyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (Platform.isIOS) {
      return const FaceVerifyScreenIos();
    }
    // default = Android (หรือ platform อื่น ๆ)
    return const FaceVerifyScreenAndroid();
  }
}
