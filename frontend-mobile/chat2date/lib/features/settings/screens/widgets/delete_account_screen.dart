import 'package:chat2date/components/dialogs/restore_account_dialog.dart';
import 'package:chat2date/components/toasts/toast.dart';
import 'package:chat2date/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ใช้ใน OTP/Google Login
/// เมื่อได้ response ที่มี error: "ACCOUNT_DELETED"
void handleDeletedAccountResponse(
  BuildContext context,
  WidgetRef ref,
  Map<String, dynamic> data,
) {
  if (data['error'] == 'ACCOUNT_DELETED' && data['canRestore'] == true) {
    // ✅ เปลี่ยนจาก showRestoreAccountDialog เป็น:
    RestoreAccountDialog.show(
      context,
      userId: data['userId'],
      daysRemaining: data['daysRemaining'],
    );
  } else if (data['error'] == 'ACCOUNT_PERMANENTLY_DELETED') {
    showPermanentlyDeletedDialog(context);
  }
}

/// Dialog แสดงว่าบัญชีหมดอายุแล้ว (เกิน 30 วัน)
void showPermanentlyDeletedDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('บัญชีถูกลบถาวร'),
        content: const Text(
          'บัญชีของคุณถูกลบถาวรแล้ว (เกิน 30 วัน)\n'
          'กรุณาสมัครสมาชิกใหม่',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            child: const Text('ตกลง'),
          ),
        ],
      );
    },
  );
}

void showDeleteAccountModal(BuildContext context, WidgetRef ref) {
  final TextEditingController confirmController = TextEditingController();
  final ValueNotifier<bool> isConfirmed = ValueNotifier(false);

  showDialog(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight:
                MediaQuery.of(context).size.height *
                0.75, // ✅ ลดจาก 0.8 เหลือ 0.75
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
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
                        color: Color(0xFFFFEBEE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        size: 36,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    const Text(
                      'ยืนยันการลบบัญชี',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 18,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Warning Message
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
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 20,
                                color: Color(0xFFFF8C00),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'ข้อมูลสำคัญ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF8C00),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '• บัญชีจะถูกระงับชั่วคราว\n' // ✅ ตัดคำ "ของคุณ" ออก
                            '• กู้คืนได้ภายใน 30 วัน\n' // ✅ ตัดคำ "คุณสามารถ" ออก
                            '• หลังจาก 30 วัน จะลบถาวร', // ✅ ตัดคำ "ข้อมูล" ออก
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF78350F),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16), // ✅ ลดจาก 10 เหลือ 16
                    // Confirmation Input
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'พิมพ์ "ลบบัญชี" เพื่อยืนยัน',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: confirmController,
                          onChanged: (value) {
                            isConfirmed.value = value == 'ลบบัญชี';
                          },
                          decoration: InputDecoration(
                            hintText: 'พิมพ์ "ลบบัญชี" ที่นี่',
                            hintStyle: const TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFEF4444),
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20), // ✅ ลดจาก 24 เหลือ 20
                    // Buttons
                    Row(
                      children: [
                        // Cancel Button
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(dialogContext);
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFE5E7EB),
                                ),
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

                        // Delete Button
                        Expanded(
                          child: ValueListenableBuilder<bool>(
                            valueListenable: isConfirmed,
                            builder: (context, confirmed, child) {
                              return SizedBox(
                                height: 44,
                                child: ElevatedButton(
                                  onPressed: confirmed
                                      ? () async {
                                          Navigator.pop(dialogContext);

                                          final navigator = Navigator.of(
                                            context,
                                          );

                                          final userService = ref.read(
                                            userServiceProvider,
                                          );

                                          final res = await userService
                                              .deleteUser();

                                          if (res) {
                                            if (context.mounted) {
                                              Toast.show(
                                                context,
                                                type: ToastType.success,
                                                title: 'แจ้งเตือน',
                                                message:
                                                    'บัญชีของคุณถูกระงับแล้ว กู้คืนได้ภายใน 30 วัน',
                                                durationSeconds: 6,
                                              );
                                            }

                                            navigator.pushNamedAndRemoveUntil(
                                              '/login',
                                              (route) => false,
                                            );
                                          } else {
                                            if (context.mounted) {
                                              Toast.show(
                                                context,
                                                type: ToastType.error,
                                                title: 'แจ้งเตือน',
                                                message:
                                                    'ไม่สามารถลบบัญชีได้ กรุณาลองใหม่อีกครั้ง',
                                                durationSeconds: 6,
                                              );
                                            }
                                          }
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: confirmed
                                        ? const Color(0xFFEF4444)
                                        : const Color(0xFFE5E7EB),
                                    disabledBackgroundColor: const Color(
                                      0xFFE5E7EB,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'ลบบัญชี',
                                    style: TextStyle(
                                      color: confirmed
                                          ? Colors.white
                                          : const Color(0xFF94A3B8),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
