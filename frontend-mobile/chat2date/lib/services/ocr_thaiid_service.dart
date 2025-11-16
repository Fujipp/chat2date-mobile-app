// lib/services/ocr_thaiid_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // ✅ เพิ่ม

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

const ocrCfg = ThaiIdOcrConfig(
  endpoint: 'https://api.iapp.co.th/thai-national-id-card/v3.5/front',
  apiKey: 'Z0XVt18RSoFlZAkRnhGy9U3u5J8MlrZA', // เดโมเท่านั้น ห้าม commit จริง
);

class ThaiIdOcrConfig {
  final String endpoint; // iApp endpoint (front/back)
  final String apiKey; // iApp apikey
  const ThaiIdOcrConfig({required this.endpoint, this.apiKey = ''});
}

class ThaiIdOcrResult {
  final String fullName; // ชื่อ-นามสกุล (ไทยถ้ามี)
  final String thFname;
  final String thLname;
  final String cardId;
  final DateTime birthDate; // วันเกิด (ค.ศ.)
  final String gender; // ชาย | หญิง | อื่นๆ
  final Uint8List? cardFaceBytes; // ✅ รูปหน้า (มาจาก field face ของ iApp)

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
    final uri = Uri.parse(cfg.endpoint);
    final req = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    if (cfg.apiKey.isNotEmpty) {
      req.headers['apikey'] = cfg.apiKey; // ✅ iApp ใช้ apikey
    }

    final res = await http.Response.fromStream(await req.send());
    if (res.statusCode != 200) {
      throw 'OCR HTTP ${res.statusCode}: ${res.body}';
    }

    final Map<String, dynamic> json = jsonDecode(res.body);

    // iApp: error_message ว่างเมื่อสำเร็จ
    final err = (json['error_message'] ?? '') as String;
    if (err.isNotEmpty) {
      throw 'OCR error: $err';
    }

    // ===== Fullname (ไทยก่อน, สำรองด้วยการประกอบ) =====
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

    // ===== DOB: ใช้ th_dob เป็นหลัก, สำรอง en_dob =====
    final thDobRaw = (json['th_dob'] ?? '') as String;
    final enDobRaw = (json['en_dob'] ?? '') as String;
    final dob = _parseThaiOrEnglishDob(thDobRaw, enDobRaw);

    // ===== เพศ -> ไทย =====
    final g = ((json['gender'] ?? '') as String).trim().toLowerCase();
    final gender = switch (g) {
      'male' => 'ชาย',
      'female' => 'หญิง',
      _ => 'อื่นๆ',
    };

    // ===== รูปหน้า (Base64) จาก iApp =====
    Uint8List? faceBytes;
    final faceB64 = (json['face'] ?? '') as String;
    if (faceB64.isNotEmpty) {
      try {
        faceBytes = base64Decode(faceB64);
      } catch (_) {
        // ไม่ให้แครช ถ้าถอด base64 ไม่ได้ ก็ปล่อยให้เป็น null
      }
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

  /// พยายาม parse วันเกิดจาก th_dob ก่อน แล้วค่อย fallback ไป en_dob
  static DateTime _parseThaiOrEnglishDob(String thDob, String enDob) {
    if (thDob.trim().isNotEmpty) {
      return _parseThaiDob(thDob);
    }
    if (enDob.trim().isNotEmpty) {
      // ตัวอย่าง "26 Mar 2003"
      try {
        return DateFormat('dd MMM yyyy', 'en').parse(enDob);
      } catch (_) {
        /* fallthrough */
      }
    }
    throw 'ไม่พบวันเกิดจาก OCR';
  }

  /// รองรับ: "26 พ.ย. 2546", "26 พฤศจิกายน 2546", "26/11/2546"
  static DateTime _parseThaiDob(String raw) {
    final s = raw.trim().replaceAll(RegExp(r'\s+'), ' ');

    // case: dd/MM/yyyy (BE)
    final ddmmyyyy = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$');
    final m1 = ddmmyyyy.firstMatch(s);
    if (m1 != null) {
      final d = int.parse(m1.group(1)!);
      final mo = int.parse(m1.group(2)!);
      final be = int.parse(m1.group(3)!);
      return DateTime(be - 543, mo, d);
    }

    // case: dd <เดือนไทย(ย่อ/เต็ม)> yyyy(BE)
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

    // ตัดจุดออก (เช่น พ.ย. -> พย)
    final cleaned = s.replaceAll('.', '');
    final parts = cleaned.split(' ');
    if (parts.length >= 3) {
      final day = int.tryParse(parts[0]) ?? 1;
      final mo = months.entries
          .firstWhere(
            // เทียบแบบลบจุดออกทั้งสองฝั่ง
            (e) => e.key.replaceAll('.', '') == parts[1],
            orElse: () => const MapEntry('?', 0),
          )
          .value;
      final be = int.tryParse(parts[2]) ?? 2540;
      if (mo >= 1 && mo <= 12) {
        return DateTime(be - 543, mo, day);
      }
    }

    // ลอง ISO เผื่ออนาคต provider เปลี่ยนรูปแบบ
    try {
      final dt = DateTime.parse(s);
      // ถ้าเป็น BE เผลอใส่มาเป็นปีใหญ่เกิน ให้ลด 543
      final nowYear = DateTime.now().year;
      if (dt.year > nowYear + 1) {
        return DateTime(dt.year - 543, dt.month, dt.day);
      }
      return dt;
    } catch (_) {}

    throw 'อ่านรูปแบบวันเกิด (th_dob) ไม่สำเร็จ: $raw';
  }
}
