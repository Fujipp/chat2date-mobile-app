import 'dart:async';
import 'dart:convert';

import 'package:chat2date/config/backend_base.dart';
import 'package:chat2date/main.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'authenticated_client.g.dart';

@Riverpod(keepAlive: true)
http.Client authenticatedClient(Ref ref) {
  return AuthenticatedClient(http.Client(), ref);
}

class AuthenticatedClient extends http.BaseClient {
  final http.Client _inner;
  final Ref ref;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isRefreshing = false;
  Future<bool>? _refreshFuture;

  AuthenticatedClient(this._inner, this.ref);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // 1. อัปเดต Authorization Header ก่อนยิงเสมอ (เฉพาะ URL ของ Backend ของเรา)
    if (request.url.toString().startsWith(ApiBase.baseUrl)) {
      final accessToken = await _storage.read(key: "access_token");
      if (accessToken != null) {
        request.headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    // 2. ส่ง Request ครั้งแรก
    final response = await _inner.send(request);

    // 3. จัดการกรณี 401 Unauthorized
    if (response.statusCode == 401 && request.url.toString().startsWith(ApiBase.baseUrl)) {
      debugPrint('⚠️ [AuthenticatedClient] 401 Unauthorized encountered. Attempting refresh for ${request.url}');
      
      final isSuccess = await _handleTokenRefresh();
      
      if (isSuccess) {
        // อัปเดต Token ใน Header
        final newAccessToken = await _storage.read(key: "access_token");
        if (newAccessToken != null) {
          debugPrint('🔄 [AuthenticatedClient] Refresh successful! Retrying request...');
          final retryRequest = _copyRequest(request);
          retryRequest.headers['Authorization'] = 'Bearer $newAccessToken';
          
          return _inner.send(retryRequest);
        }
      } else {
        // กรณี Refresh ไม่ผ่าน ให้บังคับล็อกเอาท์ หรือพากลับไปหน้า Login
        debugPrint('❌ [AuthenticatedClient] Refresh failed. Forcing user to login.');
        _forceLogout();
      }
    }

    return response;
  }

  /// ฟังก์ชันจัดการ Refresh Token (ป้องกัน Request หลายตัวยิงเรียก Refresh ซ้ำซ้อน)
  Future<bool> _handleTokenRefresh() async {
    if (_isRefreshing) {
      if (_refreshFuture != null) {
        return await _refreshFuture!;
      }
    }
    
    _isRefreshing = true;
    final completer = Completer<bool>();
    _refreshFuture = completer.future;

    try {
      final refreshToken = await _storage.read(key: "refreshToken");
      if (refreshToken == null) {
        completer.complete(false);
        return false;
      }

      final res = await http.post(
        Uri.parse("${ApiBase.baseUrl}/auth/refresh-token"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refreshToken": refreshToken}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final newAccessToken = data["accessToken"];

        await _storage.write(key: "access_token", value: newAccessToken);
        
        // บาง Backend จะคืน refreshToken ใหม่มาด้วยเมื่อทำการ refresh
        if (data["refreshToken"] != null) {
          await _storage.write(key: "refreshToken", value: data["refreshToken"]);
        }

        try {
          ref.read(userStoreProvider.notifier).setAccessToken(newAccessToken);
        } catch (_) {}

        completer.complete(true);
        return true;
      } else {
        // อาจจะเป็น 403 ถูกระงับบัญชี หรือ Token หมดอายุเกลี้ยงจริงๆ
        debugPrint('❌ [AuthenticatedClient] Refresh token failed with status ${res.statusCode}: ${res.body}');
        completer.complete(false);
        return false;
      }
    } catch (e) {
      debugPrint('❌ [AuthenticatedClient] Refresh token error: $e');
      completer.complete(false);
      return false;
    } finally {
      _isRefreshing = false;
      _refreshFuture = null;
    }
  }

  /// คัดลอก Request เดิมเพื่อยิงซ้ำ (http package จะ throws error ถ้านำ StreamedRequest ที่ยิงไปแล้วมายิงซ้ำ)
  http.BaseRequest _copyRequest(http.BaseRequest request) {
    if (request is http.Request) {
      return http.Request(request.method, request.url)
        ..headers.addAll(request.headers)
        ..bodyBytes = request.bodyBytes
        ..encoding = request.encoding
        ..followRedirects = request.followRedirects
        ..maxRedirects = request.maxRedirects
        ..persistentConnection = request.persistentConnection;
    } else if (request is http.MultipartRequest) {
      return http.MultipartRequest(request.method, request.url)
        ..headers.addAll(request.headers)
        ..fields.addAll(request.fields)
        ..files.addAll(request.files);
    }
    // ถ้าเป็นกรณีอื่นๆ ที่ซับซ้อน (เช่น StreamedRequest โดยตรง) การคัดลอกอาจจะเป็นไปได้ยาก 
    // แต่สำหรับ REST API ส่วนใหญ่แล้ว ไม่ Request ก็ MultipartRequest
    return request;
  }

  /// เตะกลับไปหน้า Login
  void _forceLogout() {
    _storage.delete(key: "access_token");
    _storage.delete(key: "refreshToken");
    
    // เคลียร์ UI State
    try {
      ref.read(userStoreProvider.notifier).state = {
        'user': null,
        'accessToken': null,
        'cardFaceBytes': null,
        'profile': null,
        'preferences': null,
      };
    } catch (_) {}

    // เตะกลับไปที่หน้า AuthCheckPage เพื่อไปเช็ค/แสดง Dialog / พาไปหน้า Login อย่างปลอดภัย
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil('/auth', (route) => false);
    });
  }
}
