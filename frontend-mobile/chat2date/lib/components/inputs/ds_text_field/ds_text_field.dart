import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart'; // ใช้สีจาก Figma (ถ้าไม่มี ให้เปลี่ยนเป็นสีในธีมหรือ Colors.grey)

// ✅ TextField แบบ Design System: รองรับ label, required, enabled, hint, prefix/suffix, supportText
class DsTextField extends StatelessWidget {
  const DsTextField({
    super.key,
    required this.label,
    this.required = false,
    this.enabled = true,
    this.hintText,
    this.suffixIcon,
    this.prefixIcon,
    this.supportText,
    this.controller,
    this.onSuffixTap,
  });

  final String label;
  final bool required;
  final bool enabled;
  final String? hintText;
  final IconData? suffixIcon;
  final IconData? prefixIcon;
  final String? supportText;
  final TextEditingController? controller;
  final VoidCallback? onSuffixTap;

  @override
  Widget build(BuildContext context) {
    // ✅ คืนค่า Widget เสมอ
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label + required mark
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
          const SizedBox(height: 6),

          // ตัว TextField
          TextField(
            enabled: enabled,
            controller: controller,
            style: TextStyle(
              color: enabled ? AppColors.textPrimary : AppColors.textMuted,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: AppColors.inputPlaceholder),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: AppColors.textSecondary)
                  : null,
              suffixIcon: suffixIcon != null
                  ? InkWell(
                      onTap: onSuffixTap,
                      child: Icon(suffixIcon, color: AppColors.infoIcon),
                    )
                  : null,
              filled: true,
              fillColor: enabled
                  ? AppColors.inputBg
                  : AppColors.inputDisabledBg,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.inputBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.inputBorderFocus,
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.inputBorder),
              ),
            ),
          ),

          // Support text (optional)
          if (supportText != null) ...[
            const SizedBox(height: 4),
            Text(
              supportText!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}
