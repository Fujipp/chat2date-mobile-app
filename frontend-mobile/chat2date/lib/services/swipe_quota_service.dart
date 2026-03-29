import 'dart:convert';
import 'package:chat2date/core/config/backend_base.dart';
import 'package:chat2date/core/utils/authenticated_client.dart';
import 'package:chat2date/models/dto/swipe_quota_dto.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final swipeQuotaProvider = Provider<SwipeQuotaService>((ref) {
  return SwipeQuotaService(ref);
});

class SwipeQuotaService {
  final Ref ref;
  static String get _base => ApiBase.baseUrl;
  SwipeQuotaService(this.ref);

  // --- เช็คสถานะโควตา ---
  Future<SwipeQuotaDto> checkSwipeStatus() async {
    final client = ref.read(authenticatedClientProvider);
    final url = Uri.parse('$_base/swipe/check-status');

    final response = await client.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      return SwipeQuotaDto.fromJson(jsonData);
    } else {
      throw Exception('ไม่สามารถดึงข้อมูลโควตาได้');
    }
  }

  // --- ส่งคำสั่งปัดการ์ด (Update Count) ---
  Future<SwipeQuotaDto> processSwipe() async {
    final client = ref.read(authenticatedClientProvider);
    final url = Uri.parse('$_base/swipe/process');

    final response = await client.put(url);

    // รับได้ทั้ง 200 (สำเร็จ) และ 403 (โดนจำกัดแล้ว) เพราะทั้งคู่คืน SwipeQuotaDto เหมือนกัน
    if (response.statusCode == 200 || response.statusCode == 403) {
      final Map<String, dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      return SwipeQuotaDto.fromJson(jsonData);
    } else {
      throw Exception('การเชื่อมต่อผิดพลาด');
    }
  }
}