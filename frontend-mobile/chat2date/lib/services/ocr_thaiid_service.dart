// lib/services/ocr_thaiid_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ThaiIdOcrConfig {
  final String endpoint; // ชี้ไปที่ iApp API: /v3/store/ekyc/thai-national-id-card/front
  final String apiKey;
  const ThaiIdOcrConfig({
    required this.endpoint,
    required this.apiKey,
  });
}

class ThaiIdOcrResult {
  final String fullName;
  final String thFname;
  final String thLname;
  final String cardId;
  final DateTime birthDate;
  final String gender;
  final Uint8List? cardFaceBytes;

  ThaiIdOcrResult({
    required this.fullName,
    required this.thFname,
    required this.thLname,
    required this.cardId,
    required this.birthDate,
    required this.gender,
    this.cardFaceBytes,
  });

  int get age {
    final now = DateTime.now();
    var a = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      a--;
    }
    return a;
  }
}

class ThaiIdOcrService {
  static Future<ThaiIdOcrResult> ocr({
    required ThaiIdOcrConfig cfg,
    required File imageFile,
  }) async {
    // 1) สร้าง MultipartRequest ตามตัวอย่าง Dart ของ iApp
    final uri = Uri.parse(cfg.endpoint);
    final request = http.MultipartRequest('POST', uri);

    // header: apikey
    request.headers['apikey'] = cfg.apiKey;

    // แนบไฟล์บัตร
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    // ถ้าอยากได้ image/ bbox เพิ่ม สามารถเพิ่ม options ได้
    // request.fields['options'] = 'get_bbox,get_image';

    // 2) ส่ง request
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode != 200) {
      throw 'OCR HTTP ${res.statusCode}: ${res.body}';
    }

    final Map<String, dynamic> json = jsonDecode(res.body);

    // ตรวจ error_message ตาม doc
    final err = (json['error_message'] ?? '') as String;
    if (err.isNotEmpty) {
      throw 'OCR error: $err';
    }

    // ===== ดึงข้อมูลตาม field ของ iApp =====
    final thName = (json['th_name'] ?? '') as String;
    final thF = (json['th_fname'] ?? '') as String;
    final thL = (json['th_lname'] ?? '') as String;
    final enName = (json['en_name'] ?? '') as String;
    final enF = (json['en_fname'] ?? '') as String;
    final enL = (json['en_lname'] ?? '') as String;

    final fullName = [
      thName,
      (thF.isNotEmpty || thL.isNotEmpty) ? '$thF $thL'.trim() : '',
      enName,
      (enF.isNotEmpty || enL.isNotEmpty) ? '$enF $enL'.trim() : '',
    ].firstWhere((s) => s.trim().isNotEmpty, orElse: () => '');

    // DOB
    final thDobRaw = (json['th_dob'] ?? '') as String;
    final enDobRaw = (json['en_dob'] ?? '') as String;
    final dob = _parseThaiOrEnglishDob(thDobRaw, enDobRaw);

    // เพศ
    final g = ((json['gender'] ?? '') as String).trim().toLowerCase();
    final gender = switch (g) {
      'male' => 'ชาย',
      'female' => 'หญิง',
      _ => 'อื่นๆ',
    };

    // รูปหน้า base64
    Uint8List? faceBytes;
    final faceB64 = (json['face'] ?? '') as String;
    if (faceB64.isNotEmpty) {
      try {
        faceBytes = base64Decode(faceB64);
      } catch (_) {}
    }

    final cardId = (json['id_number'] ?? '') as String;

    return ThaiIdOcrResult(
      fullName: fullName,
      thFname: thF,
      thLname: thL,
      cardId: cardId,
      birthDate: dob,
      gender: gender,
      cardFaceBytes: faceBytes,
    );
  }

  // ======= helpers เดิมใช้ต่อได้ =======
  static DateTime _parseThaiOrEnglishDob(String thDob, String enDob) {
    if (thDob.trim().isNotEmpty) {
      return _parseThaiDob(thDob);
    }
    if (enDob.trim().isNotEmpty) {
      try {
        return DateFormat('dd MMM yyyy', 'en').parse(enDob);
      } catch (_) {}
    }
    throw 'ไม่พบวันเกิดจาก OCR';
  }

  static DateTime _parseThaiDob(String raw) {
    final s = raw.trim().replaceAll(RegExp(r'\s+'), ' ');

    final ddmmyyyy = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$');
    final m1 = ddmmyyyy.firstMatch(s);
    if (m1 != null) {
      final d = int.parse(m1.group(1)!);
      final mo = int.parse(m1.group(2)!);
      final be = int.parse(m1.group(3)!);
      return DateTime(be - 543, mo, d);
    }

    final months = <String, int>{
      'ม.ค.': 1,
      'มกราคม': 1,
      'ก.พ.': 2,
      'กุมภาพันธ์': 2,
      'มี.ค.': 3,
      'มีนาคม': 3,
      'เม.ย.': 4,
      'เมษายน': 4,
      'พ.ค.': 5,
      'พฤษภาคม': 5,
      'มิ.ย.': 6,
      'มิถุนายน': 6,
      'ก.ค.': 7,
      'กรกฎาคม': 7,
      'ส.ค.': 8,
      'สิงหาคม': 8,
      'ก.ย.': 9,
      'กันยายน': 9,
      'ต.ค.': 10,
      'ตุลาคม': 10,
      'พ.ย.': 11,
      'พฤศจิกายน': 11,
      'ธ.ค.': 12,
      'ธันวาคม': 12,
    };

    final cleaned = s.replaceAll('.', '');
    final parts = cleaned.split(' ');
    if (parts.length >= 3) {
      final day = int.tryParse(parts[0]) ?? 1;
      final mo = months.entries
          .firstWhere(
            (e) => e.key.replaceAll('.', '') == parts[1],
            orElse: () => const MapEntry('?', 0),
          )
          .value;
      final be = int.tryParse(parts[2]) ?? 2540;
      if (mo >= 1 && mo <= 12) {
        return DateTime(be - 543, mo, day);
      }
    }

    try {
      final dt = DateTime.parse(s);
      final nowYear = DateTime.now().year;
      if (dt.year > nowYear + 1) {
        return DateTime(dt.year - 543, dt.month, dt.day);
      }
      return dt;
    } catch (_) {}

    throw 'อ่านรูปแบบวันเกิด (th_dob) ไม่สำเร็จ: $raw';
  }
}
