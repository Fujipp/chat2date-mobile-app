// lib/config/backend_base.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiBase {
  /// ใช้ override จาก --dart-define=API_BASE=...
  /// ถ้าไม่ส่งมา จะเป็นค่าว่างเพื่อให้ไปใช้ fallback ตามแพลตฟอร์ม
  static const String _override = String.fromEnvironment(
    'API_BASE',
    defaultValue: '',
  );

  // Fallback ต่อแพลตฟอร์ม
  static const String _webDev = 'http://127.0.0.1:8080'; // Flutter Web
  static const String _iosSim = 'http://127.0.0.1:8080'; // iOS Simulator
  static const String _androidEmu = 'http://10.0.2.2:8080'; // Android Emulator
  static const String _lanFallback =
      'http://192.168.1.34:8080'; // อุปกรณ์จริง/เดสก์ท็อป

  /// baseUrl สุดท้ายที่แอปจะใช้
  static String get baseUrl {
    // 1) ถ้า Dev ใส่ --dart-define มาก็ใช้ทันที (รองรับ http/https/ngrok)
    if (_override.isNotEmpty) return _override;

    // 2) เลือกตามแพลตฟอร์มตอนรัน
    if (kIsWeb) return _webDev;
    if (Platform.isAndroid) return _androidEmu;
    if (Platform.isIOS) return _iosSim;

    // 3) กรณี Desktop หรืออุปกรณ์จริง ให้ยิงไปที่ LAN/IP ของ Backend
    return _lanFallback;
  }

  /// true ถ้า baseUrl เป็น https (เช่นเวลาชี้ ngrok)
  static bool get isHttps => baseUrl.startsWith('https://');

  /// สร้าง WebSocket URL โดยดูจาก baseUrl อัตโนมัติ (ws/wss)
  /// เช่น ApiBase.wsUrl(path: '/ws/kyc')
  static String wsUrl({String path = '/'}) {
    final uri = Uri.parse(baseUrl);
    final scheme = (uri.scheme == 'https') ? 'wss' : 'ws';
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return Uri(
      scheme: scheme,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
      path: cleanPath,
    ).toString();
  }
}
