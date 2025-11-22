import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class DsTextField extends StatelessWidget {
  const DsTextField({
    super.key,
    this.label,
    this.required = false,
    this.enabled = true,
    this.readOnly = false,
    this.hintText,
    this.suffixIcon,
    this.prefixIcon,
    this.supportText,
    this.controller,
    this.onSuffixTap,
    this.labelFontSize,
    this.inputFontSize,
    this.keyboardType, // ✅ เพิ่ม
    this.onChanged, // ✅ เพิ่ม
  });

  final String? label;
  final bool required;
  final bool enabled;
  final String? hintText;
  final IconData? suffixIcon;
  final IconData? prefixIcon;
  final String? supportText;
  final TextEditingController? controller;
  final VoidCallback? onSuffixTap;
  final TextInputType? keyboardType; // ✅ เพิ่ม
  final ValueChanged<String>? onChanged; // ✅ เพิ่ม
  final bool readOnly;

  final double? labelFontSize;
  final double? inputFontSize;

  @override
  Widget build(BuildContext context) {
    final hasLabel = label != null && label!.isNotEmpty;
    final labelSize = labelFontSize ?? 14.0;
    final inputSize = inputFontSize ?? 14.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasLabel)
            RichText(
              text: TextSpan(
                text: label,
                style: DefaultTextStyle.of(context).style.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: labelSize,
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
          if (hasLabel) const SizedBox(height: 6),

          TextField(
            enabled: enabled,
            controller: controller,
            keyboardType: keyboardType, // ✅ ใช้งานจริง
            onChanged: onChanged, // ✅ ใช้งานจริง
            readOnly: readOnly,
            style: TextStyle(
              color: enabled ? AppColors.textPrimary : AppColors.textMuted,
              fontSize: inputSize,
            ),
            decoration: InputDecoration(
              hintText: hasLabel ? hintText : supportText ?? '',
              hintStyle: TextStyle(
                color: AppColors.inputPlaceholder,
                fontSize: inputSize,
              ),
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

          if (supportText != null && hasLabel) ...[
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
