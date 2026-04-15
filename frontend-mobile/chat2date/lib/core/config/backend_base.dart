// lib/config/backend_base.dart
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

class ApiBase {
  // ============================================
  // 🔧 SWITCH: เปลี่ยนเป็น true เพื่อใช้ Backend บนเครื่อง
  // ============================================
  static const bool useLocalBackend = false;
  
  // URLs สำหรับ Local Backend (บนเครื่อง)
  // 🔧 เปลี่ยน IP นี้เป็น IP ของ Mac เมื่อรันบนเครื่องจริง
  static const String _localIp = '192.168.1.41'; // IP ของ Mac (ใช้กับ iPhone/Android จริง)
  static const String _localUrl = 'http://$_localIp:8080/api/v1';
  // static const String _localUrlAndroid =
  //     'http://10.0.2.2:8080/api/v1'; // สำหรับ Android Emulator
  static const String _localWsUrl = 'ws://$_localIp:8080';
  // static const String _localWsUrlAndroid = 'ws://10.0.2.2:8080';

  static const String _localUrlAndroid = 'http://$_localIp:8080/api/v1';
  static const String _localWsUrlAndroid = 'ws://$_localIp:8080';

  // URLs สำหรับ Server จริง
  static const String _serverUrl = 'https://cp25ssi2.sit.kmutt.ac.th/api/v1';
  static const String _serverWsUrl = 'ws://cp25ssi2.sit.kmutt.ac.th:8080';

  // อนุญาต override จาก --dart-define=API_BASE=http://...
  static const String _defined = String.fromEnvironment('API_BASE');
  
  // อนุญาต override path ของ WebSocket เช่น '/ws' หรือ '/api/v1/ws'
  static const String _wsPathDefined = String.fromEnvironment(
    'WS_PATH',
    defaultValue: '/api/v1/ws',
  );

  static String get baseUrl {
    // ถ้ามี dart-define ให้ใช้ค่านั้น
    if (_defined.isNotEmpty) return _defined;

    // ใช้ Local Backend
    if (useLocalBackend) {
      if (kIsWeb) return 'http://127.0.0.1:8080/api/v1';
      if (Platform.isAndroid) return _localUrlAndroid;
      if (Platform.isIOS) return _localUrl;
      return _localUrl;
    }

    // ใช้ Server จริง
    return _serverUrl;
  }

  static String get websocketBase {
    if (_defined.isNotEmpty && _defined.startsWith('http')) {
      final uri = Uri.parse(_defined);
      final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
      final wsUri = Uri(
        scheme: scheme,
        host: uri.host,
        port: uri.hasPort ? uri.port : null,
      );
      return wsUri.toString();
    }

    // ใช้ Local Backend
    if (useLocalBackend) {
      if (kIsWeb) return 'ws://127.0.0.1:8080';
      if (Platform.isAndroid) return _localWsUrlAndroid;
      if (Platform.isIOS) return _localWsUrl;
      return _localWsUrl;
    }

    // ใช้ Server จริง
    return _serverWsUrl;
  }

  // ให้ path สำหรับ WebSocket (configurable ผ่าน --dart-define=WS_PATH)
  static String get websocketPath {
    var p = _wsPathDefined.trim();
    if (p.isEmpty) p = '/ws';
    if (!p.startsWith('/')) p = '/$p';
    if (p.endsWith('/')) p = p.substring(0, p.length - 1);
    return p;
  }
}

