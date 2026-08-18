import 'package:chat2date/components/design_system/feedback/ds_action_modal.dart';
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
  DsActionModal.show(
    context,
    child: DsDeleteAccountModal(
      controller: confirmController,
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: () async {
        Navigator.of(context).pop();

        final navigator = Navigator.of(context);
        final userService = ref.read(userServiceProvider);
        final res = await userService.deleteUser();

        if (res) {
          if (context.mounted) {
            Toast.show(
              context,
              type: ToastType.success,
              title: 'แจ้งเตือน',
              message: 'บัญชีของคุณถูกระงับแล้ว กู้คืนได้ภายใน 30 วัน',
              durationSeconds: 6,
            );
          }

          navigator.pushNamedAndRemoveUntil('/login', (route) => false);
        } else {
          if (context.mounted) {
            Toast.show(
              context,
              type: ToastType.error,
              title: 'แจ้งเตือน',
              message: 'ไม่สามารถลบบัญชีได้ กรุณาลองใหม่อีกครั้ง',
              durationSeconds: 6,
            );
          }
        }
      },
    ),
  );
}
