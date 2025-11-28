import 'package:chat2date/models/user.dart';
import 'package:chat2date/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

final authControllerProvider = riverpod.Provider<AuthController>(
  (ref) => AuthController(ref),
);

class NavigationResult {
  final String route;
  final Map<String, dynamic>? arguments;

  NavigationResult(this.route, {this.arguments});
}

class AuthController {
  final riverpod.Ref ref;
  AuthController(this.ref);

  Future<NavigationResult> handleGoogleLogin({required bool onLogin}) async {
    final auth = ref.read(authServiceProvider);
    final userMap = await auth.loginWithGoogle();
    final user = User.fromJson(userMap);

    return determineRoute(user, onLogin);
  }

  NavigationResult determineRoute(User user, bool onLogin) {
    switch (user.accountStatus) {
      case AccountStatus.PENDING:
        if (onLogin) {
          return NavigationResult('/policy', arguments: {"goKyc": true});
        }
        return NavigationResult('/kyc-id-ocr');

      case AccountStatus.ACTIVE:
        return NavigationResult('/discovery');

      case AccountStatus.SUSPENDED:
        throw Exception('บัญชีถูกระงับ');

      default:
        throw Exception('สถานะบัญชีไม่ถูกต้อง');
    }
  }
}
