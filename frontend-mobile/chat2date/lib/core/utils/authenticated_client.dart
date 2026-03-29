// lib/core/utils/authenticated_client.dart
//
// HTTP Client ที่ auto-refresh access token เมื่อได้รับ 401
// ทุก service ที่ต้องการ auth ให้ใช้ authenticatedClientProvider แทน http โดยตรง

import 'dart:convert';
import 'dart:io';

import 'package:chat2date/features/auth/screens/auth_check_screen.dart';
import 'package:chat2date/services/auth_service.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'authenticated_client.g.dart';

@riverpod
AuthenticatedClient authenticatedClient(Ref ref) {
  return AuthenticatedClient(ref);
}

class AuthenticatedClient {
  final Ref ref;

  AuthenticatedClient(this.ref);

  // ──────────────────────────────────────────────
  // GET
  // ──────────────────────────────────────────────
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final response = await http.get(url, headers: await _buildHeaders(headers));
    return _handleUnauthorized(
      response: response,
      retry: () async => http.get(url, headers: await _buildHeaders(headers)),
    );
  }

  // ──────────────────────────────────────────────
  // POST
  // ──────────────────────────────────────────────
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final response = await http.post(
      url,
      headers: await _buildHeaders(headers),
      body: body,
      encoding: encoding,
    );
    return _handleUnauthorized(
      response: response,
      retry: () async => http.post(
        url,
        headers: await _buildHeaders(headers),
        body: body,
        encoding: encoding,
      ),
    );
  }

  // ──────────────────────────────────────────────
  // PUT
  // ──────────────────────────────────────────────
  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final response = await http.put(
      url,
      headers: await _buildHeaders(headers),
      body: body,
      encoding: encoding,
    );
    return _handleUnauthorized(
      response: response,
      retry: () async => http.put(
        url,
        headers: await _buildHeaders(headers),
        body: body,
        encoding: encoding,
      ),
    );
  }

  // ──────────────────────────────────────────────
  // PATCH
  // ──────────────────────────────────────────────
  Future<http.Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final response = await http.patch(
      url,
      headers: await _buildHeaders(headers),
      body: body,
      encoding: encoding,
    );
    return _handleUnauthorized(
      response: response,
      retry: () async => http.patch(
        url,
        headers: await _buildHeaders(headers),
        body: body,
        encoding: encoding,
      ),
    );
  }

  // ──────────────────────────────────────────────
  // DELETE
  // ──────────────────────────────────────────────
  Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final response = await http.delete(
      url,
      headers: await _buildHeaders(headers),
      body: body,
      encoding: encoding,
    );
    return _handleUnauthorized(
      response: response,
      retry: () async => http.delete(
        url,
        headers: await _buildHeaders(headers),
        body: body,
        encoding: encoding,
      ),
    );
  }

  // ──────────────────────────────────────────────
  // private: build headers พร้อม Authorization
  // ──────────────────────────────────────────────
  Future<Map<String, String>> _buildHeaders(
    Map<String, String>? extra,
  ) async {
    final token = ref.read(userStoreProvider.notifier).accessToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?extra,
    };
  }

  // ──────────────────────────────────────────────
  // private: จัดการ 401 → refresh แล้ว retry
  // ──────────────────────────────────────────────
  Future<http.Response> _handleUnauthorized({
    required http.Response response,
    required Future<http.Response> Function() retry,
  }) async {
    if (response.statusCode != HttpStatus.unauthorized) return response;

    // ลอง refresh token
    final result = await tryRefresh(ref);

    if (result['success'] != true) {
      // Refresh fail → force logout
      _forceLogout();
      return response; // ส่ง 401 response กลับไปให้ caller รู้
    }

    // ได้ accessToken ใหม่แล้ว → retry request เดิม
    return retry();
  }

  // ──────────────────────────────────────────────
  // private: เคลียร์ state แล้ว navigate ไป Login
  // ──────────────────────────────────────────────
  void _forceLogout() {
    try {
      // เรียกใช้ signOut เพื่อเคลียร์ข้อมูลอย่างถูกต้อง
      ref.read(authServiceProvider).signOut();
    } catch (_) {}
  }
}
