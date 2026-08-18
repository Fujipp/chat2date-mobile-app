// lib/models/face_scan_args.dart
import 'dart:typed_data';

class FaceScanArgs {
  /// ใบหน้าที่ตัดมาจากบัตร (เป็น bytes)
  final Uint8List? cardFaceBytes;

  /// ข้อมูลประกอบ (จาก OCR) — ใช้โชว์/เก็บ Log ภายหลังได้
  final String? fullName;
  final DateTime? dob;
  final String? gender;

  const FaceScanArgs({
    this.cardFaceBytes,
    this.fullName,
    this.dob,
    this.gender,
  });
}
