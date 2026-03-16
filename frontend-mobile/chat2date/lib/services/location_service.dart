// lib/services/location_service.dart
import 'dart:convert';

import 'package:chat2date/config/backend_base.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

final locationServiceProvider = Provider((ref) => LocationService(ref));

class LocationService {
  final Ref ref;
  LocationService(this.ref);

  /// เช็ค + ขออนุญาต และคืน Position ปัจจุบัน
  Future<Position> _getCurrentPosition() async {
    // 1) เช็คว่าเปิด Location Service ไหม
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    // 2) เช็ค/ขอ Permission
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // ต้องให้ user ไปเปิดเองใน Settings
      throw Exception('Location permission permanently denied');
    }

    // 3) ดึงตำแหน่ง
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return pos;
  }

  /// เรียกใช้ตอนเข้า Discovery หรือกดปุ่มเมนู
  /// - ดึง user + accessToken จาก user_store
  /// - ขอ location
  /// - ยิงไปที่ /location/update
  Future<void> updateLocation() async {
    final userState = ref.read(userStoreProvider);
    final user = userState['user'];
    final accessToken = userState['accessToken'] as String?;

    if (user == null || accessToken == null) {
      throw Exception('User not logged in');
    }

    // user เป็น type User จาก models
    final userId = (user as dynamic).userId;

    final pos = await _getCurrentPosition();

    final body = {
      'userId': userId,
      'latitude': pos.latitude,
      'longtitude': pos.longitude, // ตามสะกดฝั่ง backend
      'accuracy': pos.accuracy, // ถ้า backend รับได้เป็น double
    };

    final uri = Uri.parse('${ApiBase.baseUrl}/location/update');
    debugPrint('[Location] POST $uri body=$body');

    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      debugPrint('[Location] Failed: ${res.statusCode} ${res.body}');
      try {
        final data = jsonDecode(res.body);
        throw Exception(data['message'] ?? 'Failed to update location');
      } catch (_) {
        throw Exception('Failed to update location: HTTP ${res.statusCode}');
      }
    }

    debugPrint('[Location] Update success');
  }

  /// เวอร์ชันไม่ throw error (ไว้ใช้เวลาอยากให้ UI เงียบ ๆ)
  Future<void> tryUpdateLocationSilently() async {
    try {
      await updateLocation();
    } catch (e) {
      debugPrint('[Location] Silent error: $e');
    }
  }

  Future<String> shareLocation({
    required double latitude,
    required double longitude,
  }) async {
    final userState = ref.read(userStoreProvider);
    final accessToken = "${userState['accessToken']}";

    final url = Uri.parse('${ApiBase.baseUrl}/dates/share-location');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({'latitude': latitude, 'longitude': longitude}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      // ส่ง shareUrl กลับไปให้หน้าแชต
      return data['shareUrl'] ?? '';
    } else {
      throw Exception('ไม่สามารถสร้างลิงก์แชร์พิกัดได้');
    }
  }
}
