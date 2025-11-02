import 'package:flutter/material.dart';

/// Label Component - แสดงแค่ label เหมือน DsTextField
class DsLabel extends StatelessWidget {
  final String label;
  final bool required;
  final double bottomSpacing;

  const DsLabel({
    super.key,
    required this.label,
    this.required = false,
    this.bottomSpacing = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomSpacing),
      child: RichText(
        text: TextSpan(
          text: label,
          style: DefaultTextStyle.of(context).style.copyWith(
            color: const Color(0xFF0F172A), // AppColors.textPrimary
            fontWeight: FontWeight.w500,
            fontSize: 16,
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
    );
  }
}
