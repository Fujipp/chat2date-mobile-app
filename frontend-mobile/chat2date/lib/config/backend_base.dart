// lib/config/backend_base.dart
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

class ApiBase {
  // อนุญาต override จาก --dart-define=API_BASE=http://...
  static const String _defined = String.fromEnvironment(
    'API_BASE',
    // defaultValue: 'http://10.250.103.196:8080/api/v1',
    defaultValue: 'http://cp25ssi2.sit.kmutt.ac.th:8080/api/v1',
  );
  // อนุญาต override path ของ WebSocket เช่น '/ws' หรือ '/api/v1/ws'
  static const String _wsPathDefined = String.fromEnvironment(
    'WS_PATH',
    defaultValue: '/api/v1/ws',
  );

  static String get baseUrl {
    if (_defined.isNotEmpty) return _defined;

    if (kIsWeb) return 'http://127.0.0.1:8080'; // web dev
    if (Platform.isAndroid) return 'http://10.0.2.2:8080'; // Android emulator
    if (Platform.isIOS) return 'http://127.0.0.1:8080'; // iOS simulator

    // เครื่องจริง (ตั้งค่าตามแลนของ Dev ทีหลัง)
    // return 'http://10.250.103.196:8080';
    return 'http://cp25ssi2.sit.kmutt.ac.th:8080';
  }

  static String get websocketBase {
    if (_defined.startsWith('http')) {
      final uri = Uri.parse(_defined);
      final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
      // สร้าง URI ใหม่สำหรับ WebSocket โดยไม่พก path/query/fragment เพื่อหลีกเลี่ยง '?#/ws'
      final wsUri = Uri(
        scheme: scheme,
        host: uri.host,
        port: uri.hasPort ? uri.port : null,
      );
      return wsUri.toString();
    }

    if (kIsWeb) {
      final base = Uri.base;
      if (base.host.isNotEmpty) {
        final scheme = base.scheme == 'https' ? 'wss' : 'ws';
        return Uri(
          scheme: scheme,
          host: base.host,
          port: base.hasPort ? base.port : null,
        ).toString();
      }
      return 'ws://127.0.0.1:8080';
    }
    if (Platform.isAndroid) return 'ws://10.0.2.2:8080';
    if (Platform.isIOS) return 'ws://127.0.0.1:8080';
    // return 'ws://10.250.103.196:8080';
    return 'ws://cp25ssi2.sit.kmutt.ac.th:8080';
  }

  // ให้ path สำหรับ WebSocket (configurable ผ่าน --dart-define=WS_PATH)
  static String get websocketPath {
    // normalize: ensure leading '/', no trailing '/'
    var p = _wsPathDefined.trim();
    if (p.isEmpty) p = '/ws';
    if (!p.startsWith('/')) p = '/$p';
    if (p.endsWith('/')) p = p.substring(0, p.length - 1);
    return p;
  }
}
