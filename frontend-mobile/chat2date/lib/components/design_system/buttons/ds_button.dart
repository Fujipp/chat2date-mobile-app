import 'package:chat2date/theme/tokens/typography/body_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'ds_button_schemes.dart';

enum DsButtonVariant {
  primary,
  secondary,
  error,
  accentOutline,
  accentFilled,
  outlinePrimary,
}

enum DsButtonSize { xs, sm, md, lg }

enum DsButtonVisualState { base, hover, pressed, active, disabled }

class DsButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final DsButtonVariant variant;
  final DsButtonSize size;
  final double radius;
  final FontWeight fontWeight;
  final String? fontFamily;
  final Widget? leading;
  final Widget? trailing;
  final String? leadingSvgAsset;
  final String? trailingSvgAsset;
  final double? iconSize;
  final EdgeInsets? padding;
  final double? width;
  final DsButtonVisualState? visualOverride;

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
    this.leadingSvgAsset,
    this.trailingSvgAsset,
    this.iconSize,
    this.padding,
    this.width,
    this.visualOverride,
  });

  @override
  State<DsButton> createState() => _DsButtonState();
}

class _DsButtonState extends State<DsButton> {
  bool _hovered = false;
  bool _pressed = false;

  DsButtonScheme get _scheme {
    switch (widget.variant) {
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

  (double height, double fontSize, EdgeInsets padding)
  _metrics() {
    switch (widget.size) {
      case DsButtonSize.xs:
        return (
          32,
          12,
          const EdgeInsets.symmetric(horizontal: 8),
        );
      case DsButtonSize.sm:
        return (
          40,
          14,
          const EdgeInsets.symmetric(horizontal: 16),
        );
      case DsButtonSize.md:
        return (
          40,
          14,
          const EdgeInsets.symmetric(horizontal: 16),
        );
      case DsButtonSize.lg:
        return (
          40,
          14,
          const EdgeInsets.symmetric(horizontal: 16),
        );
    }
  }

  double get _resolvedIconSize {
    if (widget.iconSize != null) return widget.iconSize!;
    switch (widget.size) {
      case DsButtonSize.xs:
        return 14;
      case DsButtonSize.sm:
        return 16;
      case DsButtonSize.md:
        return 18;
      case DsButtonSize.lg:
        return 18;
    }
  }

  void _setHovered(bool value) {
    if (widget.onPressed == null || widget.visualOverride != null) return;
    setState(() => _hovered = value);
  }

  void _setPressed(bool value) {
    if (widget.onPressed == null || widget.visualOverride != null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final metrics = _metrics();
    final disabledByCallback = widget.onPressed == null;

    var isHovered = _hovered;
    var isPressed = _pressed;
    var isDisabled = disabledByCallback;

    switch (widget.visualOverride) {
      case DsButtonVisualState.hover:
        isHovered = true;
        isPressed = false;
        isDisabled = false;
      case DsButtonVisualState.pressed:
      case DsButtonVisualState.active:
        isHovered = false;
        isPressed = true;
        isDisabled = false;
      case DsButtonVisualState.disabled:
        isHovered = false;
        isPressed = false;
        isDisabled = true;
      case DsButtonVisualState.base:
        isHovered = false;
        isPressed = false;
        isDisabled = false;
      case null:
        break;
    }

    final states = <WidgetState>{
      if (isHovered) WidgetState.hovered,
      if (isPressed) WidgetState.pressed,
      if (isDisabled) WidgetState.disabled,
    };

    final background = _scheme.resolveBg(states);
    final foreground = _scheme.resolveFg(states);
    final borderColor = _scheme.resolveBorder(states);
    final resolvedPadding = widget.padding ?? metrics.$3;

    Widget? buildIcon(String asset) {
      return SvgPicture.asset(
        asset,
        width: _resolvedIconSize,
        height: _resolvedIconSize,
        fit: BoxFit.contain,
        theme: SvgTheme(currentColor: foreground),
        colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
      );
    }

    final effectiveLeading =
        widget.leading ??
        switch (widget.leadingSvgAsset) {
          final asset? => buildIcon(asset),
          null => null,
        };

    final effectiveTrailing =
        widget.trailing ??
        switch (widget.trailingSvgAsset) {
          final asset? => buildIcon(asset),
          null => null,
        };

    final textStyle = AppBodyTextStyles.button.copyWith(
      color: foreground,
      fontSize: metrics.$2,
      fontWeight: widget.fontWeight,
      fontFamily: widget.fontFamily,
    );

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (effectiveLeading != null) ...[
          effectiveLeading,
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.label,
            style: textStyle,
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: false,
              applyHeightToLastDescent: false,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
          ),
        ),
        if (effectiveTrailing != null) ...[
          const SizedBox(width: 8),
          effectiveTrailing,
        ],
      ],
    );

    final button = AnimatedScale(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      scale: isPressed && !isDisabled ? 0.98 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        width: widget.width,
        height: metrics.$1,
        padding: resolvedPadding,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(widget.radius),
          border: borderColor == Colors.transparent
              ? null
              : Border.all(color: borderColor),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );

    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: isDisabled ? null : widget.onPressed,
        child: button,
      ),
    );
  }
}
