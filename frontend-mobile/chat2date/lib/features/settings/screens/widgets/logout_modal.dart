import 'package:chat2date/components/design_system/feedback/ds_action_modal.dart';
import 'package:chat2date/components/toasts/toast.dart';
import 'package:chat2date/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as ref;

void showLogoutModal(BuildContext context, ref.WidgetRef ref) {
  DsActionModal.show(
    context,
    child: DsChoiceModal(
      title: 'ออกจากระบบ',
      description: 'คุณอยากที่จะออกจากระบบหรือไม่?',
      negativeLabel: 'ยกเลิก',
      positiveLabel: 'ยืนยัน',
      onNegativePressed: () => Navigator.of(context).pop(),
      onPositivePressed: () async {
        try {
          await ref.read(authServiceProvider).signOut();

          if (context.mounted) {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          }
        } catch (e) {
          if (context.mounted) {
            Navigator.of(context).pop();
            Toast.show(
              context,
              type: ToastType.error,
              title: 'เกิดข้อผิดพลาด',
              message: 'ไม่สามารถออกจากระบบได้ โปรดลองอีกครั้ง',
            );
          }
        }
      },
    ),
  );
}
