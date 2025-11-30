import 'package:flutter/material.dart';
import 'ds_button_schemes.dart';

enum DsButtonVariant {
  primary,
  secondary,
  error,
  accentOutline,
  accentFilled,
  outlinePrimary,
}

/// คงชื่อเดิม + เพิ่ม xs
/// - xs -> w:39  | h:32 | font:12 | vPad:8
/// - sm -> w:100 | h:40 | font:14 | vPad:10
/// - md -> w:231 | h:40 | font:16 | vPad:10
/// - lg -> w:310 | h:40 | font:16 | vPad:10
enum DsButtonSize { xs, sm, md, lg }

class DsButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final DsButtonVariant variant;
  final DsButtonSize size;
  final double radius;
  final FontWeight fontWeight;
  final String? fontFamily;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsets? padding;

  const DsButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = DsButtonVariant.primary,
    this.size = DsButtonSize.md,
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
      case DsButtonSize.xs: // 39px | font 12 | h=32
        return (
          39,
          32,
          12,
          const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        );
      case DsButtonSize.sm: // 100px | font 14 | h=40
        return (
          100,
          40,
          14,
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        );
      case DsButtonSize.md: // 231px | font 16 | h=40
        return (
          231,
          45,
          16,
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        );
      case DsButtonSize.lg: // 310px | font 16 | h=40
        return (
          310,
          40,
          16,
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (w, h, fs, pad) = _metrics();
    final resolvedPad = padding ?? pad;

    final ButtonStyle style = ButtonStyle(
      fixedSize: WidgetStateProperty.all(Size(w, h)), // ความกว้าง/สูงตายตัว
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
      alignment: Alignment.center,
      visualDensity: VisualDensity.standard, // กันแน่นเกินไป
    );

    final text = Text(
      label,
      style: TextStyle(
        fontSize: fs, // 12 / 14 / 16 / 16 ตามที่กำหนด
        fontWeight: fontWeight,
        fontFamily: fontFamily,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      softWrap: false,
      textHeightBehavior: const TextHeightBehavior(
        applyHeightToFirstAscent: true,
        applyHeightToLastDescent: true,
      ),
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

    return ElevatedButton(style: style, onPressed: onPressed, child: child);
  }
}
