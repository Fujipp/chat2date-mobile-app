// lib/models/face_scan_args.dart
import 'dart:typed_data';

class FaceScanArgs {
  final Uint8List cardFaceBytes;
  final String fullName;
  final DateTime dob;
  final String gender;

  const FaceScanArgs({
    required this.cardFaceBytes,
    required this.fullName,
    required this.dob,
    required this.gender,
  });
}
