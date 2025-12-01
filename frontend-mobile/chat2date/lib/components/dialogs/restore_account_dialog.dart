import 'package:chat2date/components/toasts/toast.dart';
import 'package:chat2date/config/backend_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// Shared Component สำหรับแสดง Dialog กู้คืนบัญชี
class RestoreAccountDialog {
  static Future<void> show(
    BuildContext context, {
    required String userId,
    required int daysRemaining,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(24),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color: Colors.black.withOpacity(0.10),
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 20,
                  offset: Offset(20, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0F2F1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.restore_rounded,
                    size: 36,
                    color: Color(0xFF00897B),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'บัญชีของคุณถูกระงับ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 18,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                // Info Message
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFB020)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Color(0xFFFF8C00),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'ข้อมูลสำคัญ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF8C00),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• บัญชีของคุณถูกระงับชั่วคราว\n'
                        '• คุณสามารถกู้คืนบัญชีได้อีก $daysRemaining วัน\n'
                        '• ต้องการกู้คืนบัญชีหรือไม่?',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF78350F),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/home',
                              (route) => false,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'ยกเลิก',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Restore Button
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.of(dialogContext).pop();
                            await _handleRestore(context, userId);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00897B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'กู้คืนบัญชี',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Logic กู้คืนบัญชี
  static Future<void> _handleRestore(
    BuildContext context,
    String userId,
  ) async {
    // แสดง loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final storage = const FlutterSecureStorage();
      final accessToken = await storage.read(key: 'access_token');

      final response = await http.post(
        Uri.parse('${ApiBase.baseUrl}/users/$userId/restore'),
        headers: {
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      // ปิด loading
      if (context.mounted) Navigator.of(context).pop();

      if (response.statusCode == 200) {
        // ✅ ลบ tokens ออก
        await storage.delete(key: 'access_token');
        await storage.delete(key: 'refreshToken');

        // ✅ แสดง Toast สำเร็จ
        if (context.mounted) {
          Toast.show(
            context,
            type: ToastType.success,
            title: 'กู้คืนบัญชีสำเร็จ',
            message: 'กรุณาเข้าสู่ระบบใหม่',
            durationSeconds: 3,
          );

          // รอให้ Toast แสดงแล้วไปหน้า Login
        }
      } else {
        // ❌ กู้คืนไม่สำเร็จ
        if (context.mounted) {
          Toast.show(
            context,
            type: ToastType.error,
            title: 'เกิดข้อผิดพลาด',
            message: 'ไม่สามารถกู้คืนบัญชีได้ กรุณาลองใหม่อีกครั้ง',
          );
        }
      }
    } catch (e) {
      // ปิด loading
      if (context.mounted) Navigator.of(context).pop();

      // แสดง error
      if (context.mounted) {
        Toast.show(
          context,
          type: ToastType.error,
          title: 'เกิดข้อผิดพลาด',
          message: 'ไม่สามารถกู้คืนบัญชีได้: $e',
        );
      }
    }
  }
}
