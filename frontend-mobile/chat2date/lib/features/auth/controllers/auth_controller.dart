import 'package:chat2date/models/user.dart';
import 'package:chat2date/features/auth/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

final authControllerProvider = riverpod.Provider<AuthController>(
  (ref) => AuthController(ref),
);

class NavigationResult {
  final String? route;
  final Map<String, dynamic>? arguments;
  final bool isError;
  final String? errorMessage;

  NavigationResult(
    this.route, {
    this.arguments,
    this.isError = false,
    this.errorMessage,
  });

  // Named constructor สำหรับ error
  NavigationResult.error(String message)
    : route = null,
      arguments = null,
      isError = true,
      errorMessage = message;

  // Named constructor สำหรับ account deleted
  NavigationResult.accountDeleted()
    : route = null,
      arguments = null,
      isError = true,
      errorMessage = 'ACCOUNT_DELETED';
}

class AuthController {
  final riverpod.Ref ref;
  AuthController(this.ref);

  Future<NavigationResult> handleGoogleLogin({
    required BuildContext context,
    required bool onLogin,
  }) async {
    try {
      final auth = ref.read(authServiceProvider);
      final userMap = await auth.loginWithGoogle(context);

      // ✅ เช็คว่าเป็น error หรือไม่
      if (userMap['error'] == 'ACCOUNT_DELETED') {
        // Dialog กู้คืนถูกแสดงแล้วใน auth_service
        return NavigationResult.accountDeleted();
      }

      final user = User.fromJson(userMap);
      return determineRoute(user, onLogin);
    } catch (e) {
      return NavigationResult.error(e.toString());
    }
  }

  NavigationResult determineRoute(User user, bool onLogin) {
    switch (user.accountStatus) {
      case AccountStatus.pending:
        if (onLogin) {
          return NavigationResult('/policy', arguments: {"goKyc": true});
        }
        return NavigationResult('/kyc-id-ocr');

      case AccountStatus.active:
        return NavigationResult('/main');

      case AccountStatus.suspended:
        return NavigationResult.error('บัญชีถูกระงับ');

      default:
        return NavigationResult.error('สถานะบัญชีไม่ถูกต้อง');
    }
  }
}
