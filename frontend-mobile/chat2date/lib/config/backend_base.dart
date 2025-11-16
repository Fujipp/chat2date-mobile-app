// lib/config/backend_base.dart
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

class ApiBase {
  // อนุญาต override จาก --dart-define=API_BASE=http://...
  static const String _defined = String.fromEnvironment(
    'API_BASE',
    defaultValue: '/api/v1',
  );

  static String get baseUrl {
    if (_defined.isNotEmpty) return _defined;

    if (kIsWeb) return 'http://127.0.0.1:8080'; // web dev
    if (Platform.isAndroid) return 'http://10.0.2.2:8080'; // Android emulator
    if (Platform.isIOS) return 'http://127.0.0.1:8080'; // iOS simulator

    // เครื่องจริง (ตั้งค่าตามแลนของ Dev ทีหลัง)
    return 'http://localhost:8080';
  }
}
