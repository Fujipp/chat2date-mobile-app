import 'dart:convert';
import 'dart:io';

import 'package:chat2date/config/backend_base.dart';
import 'package:chat2date/models/report_request.dart';
import 'package:chat2date/models/report_response.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:chat2date/services/authenticated_client.dart';
import 'package:http_parser/http_parser.dart';

/// Provider for ReportService
final reportServiceProvider = Provider<ReportService>((ref) {
  return ReportService(ref);
});

class ReportService {
  final Ref ref;
  ReportService(this.ref);

  /// สร้าง report พร้อม optional evidence files
  /// 
  /// [request] - ข้อมูล report (userId, targetUserId, reason, etc.)
  /// [evidenceFiles] - รายการ File ของหลักฐาน (รูปภาพ/วิดีโอ)
  Future<ReportResponse> createReport(
    ReportRequest request, {
    List<File>? evidenceFiles,
  }) async {
    final client = ref.read(authenticatedClientProvider);

    // สร้าง multipart request
    final uri = Uri.parse('${ApiBase.baseUrl}/report');
    final multipartRequest = http.MultipartRequest('POST', uri);

    // เพิ่ม data part (JSON)
    multipartRequest.files.add(
      http.MultipartFile.fromString(
        'data',
        request.toJsonString(),
        contentType: MediaType('application', 'json'),
      ),
    );

    // เพิ่ม evidence files (ถ้ามี)
    if (evidenceFiles != null && evidenceFiles.isNotEmpty) {
      for (final file in evidenceFiles) {
        final fileName = file.path.split('/').last;
        final mimeType = _getMimeType(fileName);
        
        multipartRequest.files.add(
          await http.MultipartFile.fromPath(
            'evidence',
            file.path,
            contentType: mimeType,
          ),
        );
      }
    }

    // ส่ง request
    final streamedResponse = await client.send(multipartRequest);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return ReportResponse.fromJson(data);
    }

    // Handle error cases
    switch (response.statusCode) {
      case 400:
        throw Exception('ข้อมูลไม่ถูกต้อง: ${response.body}');
      case 404:
        throw Exception('ไม่พบผู้ใช้ที่ต้องการรายงาน');
      case 409:
        throw Exception('คุณได้รายงานผู้ใช้คนนี้แล้ว');
      case 413:
        throw Exception('ไฟล์มีขนาดใหญ่เกินไป (สูงสุด 10MB)');
      case 415:
        throw Exception('ประเภทไฟล์ไม่รองรับ');
      default:
        throw Exception('เกิดข้อผิดพลาด: ${response.body}');
    }
  }

  /// กำหนด MIME type จากนามสกุลไฟล์
  MediaType _getMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      case 'mp4':
        return MediaType('video', 'mp4');
      case 'mov':
        return MediaType('video', 'quicktime');
      default:
        return MediaType('application', 'octet-stream');
    }
  }
}

