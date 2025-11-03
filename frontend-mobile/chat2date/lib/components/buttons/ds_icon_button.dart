import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum DsIconButtonStyle { filled, outline }

/// บังคับสถานะภาพ (สำหรับโชว์ตัวอย่าง)
enum DsIconVisualState { base, hover, pressed, disabled }

class DsIconButton extends StatefulWidget {
  final String svgAsset;
  final VoidCallback? onPressed;
  final DsIconButtonStyle style;

  // รูปทรง/ขนาด
  final double size; // กล่องปุ่ม (เช่น 60)
  final double radius; // 999 => วงกลม
  final double iconSize; // ขนาดไอคอน
  final String? tooltip;

  // สี base
  final Color baseBg;
  final Color baseIcon;
  final Color? baseBorder;

  // สี hover
  final Color hoverBg;
  final Color hoverIcon;
  final List<BoxShadow> hoverGlow;

  // สี pressed
  final Color pressedBg;
  final Color pressedIcon;

  // สี disabled
  final Color disabledBg;
  final Color disabledIcon;
  final Color? disabledBorder;

  /// ถ้ากำหนด จะเรนเดอร์สถานะนี้ทันที (ใช้โชว์ mock: base/hover/pressed/disabled)
  final DsIconVisualState? visualOverride;

  const DsIconButton.filled({
    super.key,
    required this.svgAsset,
    required this.onPressed,
    this.style = DsIconButtonStyle.filled,
    this.size = 60,
    this.radius = 999,
    this.iconSize = 24,
    this.tooltip,

    // base
    this.baseBg = const Color(0xFF5CE1E6),
    this.baseIcon = Colors.white,
    this.baseBorder,

    // hover
    this.hoverBg = const Color(0x145CE1E6),
    this.hoverIcon = Colors.white,
    this.hoverGlow = const [
      BoxShadow(blurRadius: 18, color: Color(0x335CE1E6)),
    ],

    // pressed
    this.pressedBg = const Color(0x1F5CE1E6),
    this.pressedIcon = Colors.white,

    // disabled
    this.disabledBg = const Color(0xFFE5E7EB),
    this.disabledIcon = const Color(0xFF9AA5B1),
    this.disabledBorder,

    // showcase
    this.visualOverride,
  });

  const DsIconButton.outline({
    super.key,
    required this.svgAsset,
    required this.onPressed,
    this.style = DsIconButtonStyle.outline,
    this.size = 60,
    this.radius = 999,
    this.iconSize = 24,
    this.tooltip,

    // base
    this.baseBg = Colors.transparent,
    this.baseIcon = const Color(0xFF5CE1E6),
    this.baseBorder = const Color(0xFF5CE1E6),

    // hover
    this.hoverBg = const Color(0x145CE1E6),
    this.hoverIcon = const Color(0xFF5CE1E6),
    this.hoverGlow = const [
      BoxShadow(blurRadius: 18, color: Color(0x335CE1E6)),
    ],

    // pressed
    this.pressedBg = const Color(0x1F5CE1E6),
    this.pressedIcon = Colors.white,

    // disabled
    this.disabledBg = Colors.transparent,
    this.disabledIcon = const Color(0xFF9AA5B1),
    this.disabledBorder = const Color(0xFFCBD5E1),

    // showcase
    this.visualOverride,
  });

  @override
  State<DsIconButton> createState() => _DsIconButtonState();
}

class _DsIconButtonState extends State<DsIconButton> {
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

    // --- Resolve visual state (auto หรือ override) ---
    bool isHover = _hovered, isPressed = _pressed, isDisabled = disabled;
    if (widget.visualOverride != null) {
      isHover = widget.visualOverride == DsIconVisualState.hover;
      isPressed = widget.visualOverride == DsIconVisualState.pressed;
      isDisabled = widget.visualOverride == DsIconVisualState.disabled;
    }

    // เลือกสีตามสถานะ
    final Color bg = isDisabled
        ? widget.disabledBg
        : isPressed
        ? widget.pressedBg
        : (isHover ? widget.hoverBg : widget.baseBg);

    final Color iconColor = isDisabled
        ? widget.disabledIcon
        : isPressed
        ? widget.pressedIcon
        : (isHover ? widget.hoverIcon : widget.baseIcon);

    final List<BoxShadow> glow = (!isDisabled && isHover)
        ? widget.hoverGlow
        : const <BoxShadow>[];

    final BorderSide? borderSide = () {
      if (isDisabled) {
        final c = widget.disabledBorder;
        return c == null ? null : BorderSide(color: c, width: 1.5);
      }
      final c = widget.style == DsIconButtonStyle.outline
          ? (widget.baseBorder ?? Colors.transparent)
          : Colors.transparent;
      return c == Colors.transparent ? null : BorderSide(color: c, width: 1.5);
    }();

    final button = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(widget.radius),
        boxShadow: glow,
        border: borderSide == null ? null : Border.fromBorderSide(borderSide),
      ),
      child: Center(
        child: SvgPicture.asset(
          widget.svgAsset,
          width: widget.iconSize,
          height: widget.iconSize,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        ),
      ),
    );

    final withGesture = MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: widget.onPressed,
        child: button,
      ),
    );

    return widget.tooltip == null
        ? withGesture
        : Tooltip(message: widget.tooltip!, child: withGesture);
  }
}
