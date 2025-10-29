import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class DsOtpField extends StatelessWidget {
  const DsOtpField({
    super.key,
    this.length = 6,
    required this.label,
    this.required = false,
    this.supportText,
  });

  final int length;
  final String label;
  final bool required;
  final String? supportText;

  @override
  Widget build(BuildContext context) {
    // ✅ คืนค่า Widget เสมอ
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label + required
        RichText(
          text: TextSpan(
            text: label,
            style: DefaultTextStyle.of(context).style.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            children: required
                ? const [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 8),

        // แถวช่อง OTP (UI/demo)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(length, (index) {
            return Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.inputBorder),
              ),
              alignment: Alignment.center,
              child: const Text(
                '',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            );
          }),
        ),

        if (supportText != null) ...[
          const SizedBox(height: 8),
          Text(
            supportText!,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ],
    );
  }
}
