import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// ปุ่ม SVG ที่สลับ asset ได้ (A/B) และมี Glow ตอน hover/กดค้าง
class DsSvgSwapButton extends StatefulWidget {
  /// asset ปกติ (เช่น 'assets/icons/ic_heart.svg')
  final String assetA;

  /// asset สลับสี/hover (เช่น 'assets/icons/ic_heart_hover.svg')
  final String assetB;

  /// ขนาดกรอบกด (กดง่าย) — ถ้าอยากให้ “เห็นเฉพาะ SVG” ให้ตั้งเป็น 0
  final double padding; // default 8 = มีพื้นที่กด

  /// ขนาดตัว SVG
  final double iconSize;

  /// สถานะพรีวิว (เช่นโชว์ภาพ B ตลอด) ใช้ในจอเดโม
  final bool previewHoverLook;

  /// Glow ตอน hover/กด
  final double glowBlur;
  final Color glowColor;

  /// Callback
  final VoidCallback? onPressed;

  const DsSvgSwapButton({
    super.key,
    required this.assetA,
    required this.assetB,
    this.onPressed,
    this.padding = 8,
    this.iconSize = 28,
    this.previewHoverLook = false,
    this.glowBlur = 20,
    this.glowColor = const Color(0x33000000),
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

    // ใช้ assetB เมื่อ (กด/hover) หรือ previewHoverLook = true
    final useHoverLook =
        !disabled && (widget.previewHoverLook || _hovered || _pressed);
    final asset = useHoverLook ? widget.assetB : widget.assetA;

    final glow = (!disabled && (useHoverLook || _hovered))
        ? [BoxShadow(blurRadius: widget.glowBlur, color: widget.glowColor)]
        : const <BoxShadow>[];

    final core = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      padding: EdgeInsets.all(widget.padding),
      decoration: BoxDecoration(boxShadow: glow),
      child: SvgPicture.asset(
        asset,
        width: widget.iconSize,
        height: widget.iconSize,
        // ไม่ใส่ colorFilter เพื่อ “คงสีจากไฟล์ SVG ตรงเป๊ะ”
      ),
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

    return widget.onPressed == null
        ? Opacity(opacity: 0.6, child: core)
        : gesture;
  }
}
