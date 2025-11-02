import 'package:flutter/material.dart';
import 'ds_button_schemes.dart';

/// ชนิดปุ่มตามดีไซน์
enum DsButtonVariant {
  primary,
  secondary,
  error,
  accentOutline,
  accentFilled,
  outlinePrimary,
}

/// ขนาดปุ่มหลัก ๆ (คงชื่อเดิม + เพิ่ม xs)
enum DsButtonSize { xs, sm, md, lg }

/// ปุ่มมาตรฐานของดีไซน์ (รองรับ leading/trailing, ขนาด, มุมโค้ง, padding)
class DsButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final DsButtonVariant variant;
  final DsButtonSize size;
  final double radius; // มุมโค้ง (ดีฟอลต์ 12 ตาม Figma)
  final FontWeight fontWeight; // น้ำหนักฟอนต์
  final String? fontFamily; // ระบุชื่อฟอนต์ (เช่น 'Inter')
  final Widget? leading; // ไอคอน/วิดเจ็ตด้านซ้าย
  final Widget? trailing; // ไอคอน/วิดเจ็ตด้านขวา
  final EdgeInsets? padding; // override padding เฉพาะกิจ

  const DsButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = DsButtonVariant.primary,
    this.size = DsButtonSize.md, // เดิมใช้ md ก็ยังได้เหมือนเดิม
    this.radius = 12,
    this.fontWeight = FontWeight.w600,
    this.fontFamily,
    this.leading,
    this.trailing,
    this.padding,
  });

  DsButtonScheme get _scheme {
    switch (variant) {
      case DsButtonVariant.primary:
        return DsButtonSchemes.primary;
      case DsButtonVariant.secondary:
        return DsButtonSchemes.secondary;
      case DsButtonVariant.error:
        return DsButtonSchemes.error;
      case DsButtonVariant.accentOutline:
        return DsButtonSchemes.accentOutline;
      case DsButtonVariant.accentFilled:
        return DsButtonSchemes.accentFilled;
      case DsButtonVariant.outlinePrimary:
        return DsButtonSchemes.outlinePrimary;
    }
  }

  /// mapping: (width, height, fontSize, padding)
  (double, double, double, EdgeInsets) _metrics() {
    switch (size) {
      case DsButtonSize.xs: // 39px (สั้นมาก)
        return (
          39,
          40,
          12,
          const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        );
      case DsButtonSize.sm: // 100px
        return (
          100,
          40,
          12,
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        );
      case DsButtonSize.md: // 231px
        return (
          231,
          40,
          16,
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        );
      case DsButtonSize.lg: // 310px
        return (
          310,
          40,
          14,
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (w, h, fs, pad) = _metrics();
    final resolvedPad = padding ?? pad;

    final ButtonStyle style = ButtonStyle(
      // บังคับความกว้าง/สูงตาม preset
      fixedSize: WidgetStateProperty.all(Size(w, h)),
      padding: WidgetStateProperty.all(resolvedPad),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
      backgroundColor: WidgetStateProperty.resolveWith(_scheme.resolveBg),
      foregroundColor: WidgetStateProperty.resolveWith(_scheme.resolveFg),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      side: WidgetStateProperty.resolveWith((states) {
        final c = _scheme.resolveBorder(states);
        return BorderSide(color: c, width: c == Colors.transparent ? 0 : 1.5);
      }),
      elevation: WidgetStateProperty.all(0),
    );

    final text = Text(
      label,
      style: TextStyle(
        fontSize: fs,
        fontWeight: fontWeight,
        fontFamily: fontFamily, // ถ้ากำหนดในธีมไว้แล้วไม่ต้องส่งก็ได้
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      softWrap: false,
    );

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 8)],
        Flexible(child: text),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );

    return ElevatedButton(
      style: style,
      onPressed: onPressed, // null => disabled (ใช้สีจาก scheme)
      child: child,
    );
  }
}
