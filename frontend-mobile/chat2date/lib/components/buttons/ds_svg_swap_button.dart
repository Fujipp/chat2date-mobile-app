import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// ปุ่ม SVG ที่สลับ asset (normal / active) พร้อม animation ลื่น ๆ
/// - assetA = icon ปกติ  (60x60)
/// - assetB = icon active (77x77 / 80x80 + glow ในไฟล์)
class DsSvgSwapButton extends StatefulWidget {
  final String assetA;
  final String assetB;

  /// ขนาด SVG ปกติ (จากไฟล์)
  final double iconSize;

  /// ขนาด SVG ตอน active (จากไฟล์)
  final double activeIconSize;

  /// ขนาดกล่อง hit area (ถ้าไม่ส่ง จะ auto = activeIconSize + 20)
  final double? hitSize;

  /// padding เพิ่มรอบ ๆ icon ภายในกล่อง (ปกติใช้ 0 ก็ได้)
  final double padding;

  /// ให้โชว์ state active ตลอด (ใช้ในหน้า demo)
  final bool previewHoverLook;

  /// ระยะเวลา animation
  final Duration duration;

  /// สี glow เพิ่มเติม (นอกเหนือจากที่อยู่ใน SVG)
  final Color glowColor;

  /// ความฟุ้งของ glow
  final double glowBlur;

  final VoidCallback? onPressed;

  const DsSvgSwapButton({
    super.key,
    required this.assetA,
    required this.assetB,
    this.onPressed,
    this.iconSize = 60,
    this.activeIconSize = 60,
    this.hitSize,
    this.padding = 0,
    this.previewHoverLook = false,
    this.duration = const Duration(milliseconds: 200),
    this.glowColor = const Color(0x33000000),
    this.glowBlur = 24,
  });

  @override
  State<DsSvgSwapButton> createState() => _DsSvgSwapButtonState();
}

class _DsSvgSwapButtonState extends State<DsSvgSwapButton> {
  bool _hovered = false;
  bool _pressed = false;

  void _setHovered(bool v) {
    if (widget.onPressed == null) return;
    setState(() => _hovered = v);
  }

  void _setPressed(bool v) {
    if (widget.onPressed == null) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;

    // mobile จะมีแค่ pressed, web/desktop มี hover ด้วย
    final bool isActive =
        widget.previewHoverLook || (!disabled && (_hovered || _pressed));

    final double normalSize = widget.iconSize;
    final double activeSize = widget.activeIconSize;

    // กล่อง hit area ใหญ่กว่าหน่อย เพื่อให้กดติดง่าย
    final double outerSize = widget.hitSize ?? (widget.activeIconSize + 20);

    final core = TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: isActive ? 1 : 0),
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      builder: (context, t, _) {
        // t: 0 = normal, 1 = active
        final double innerSize = ui.lerpDouble(normalSize, activeSize, t)!;

        // glow ยิ่ง active ยิ่งแรง
        final double blur = widget.glowBlur * t;
        final Color glowColor = widget.glowColor.withValues(alpha: widget.glowColor.a * t);

        return SizedBox(
          width: outerSize,
          height: outerSize,
          child: Center(
            child: Container(
              width: innerSize,
              height: innerSize,
              padding: EdgeInsets.all(widget.padding),
              decoration: BoxDecoration(
                // extra glow นอกเหนือจาก glow ที่อยู่ใน SVG
                boxShadow: t > 0
                    ? [BoxShadow(color: glowColor, blurRadius: blur)]
                    : const [],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // normal SVG ค่อย ๆ จาง
                  Opacity(
                    opacity: 1 - t,
                    child: SvgPicture.asset(widget.assetA),
                  ),
                  // active SVG ค่อย ๆ โผล่
                  Opacity(opacity: t, child: SvgPicture.asset(widget.assetB)),
                ],
              ),
            ),
          ),
        );
      },
    );

    final gesture = MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: widget.onPressed,
        child: core,
      ),
    );

    // ถ้า disabled + ไม่ได้ preview ให้จางลงเฉย ๆ
    if (disabled && !widget.previewHoverLook) {
      return Opacity(opacity: 0.6, child: core);
    }

    return gesture;
  }
}
