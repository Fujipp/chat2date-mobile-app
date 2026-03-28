import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';

bool _isPressed(Set<WidgetState> states) =>
    states.contains(WidgetState.pressed);
bool _isHovered(Set<WidgetState> states) =>
    states.contains(WidgetState.hovered);
bool _isDisabled(Set<WidgetState> states) =>
    states.contains(WidgetState.disabled);

class DsButtonScheme {
  final Color bgDefault;
  final Color bgHover;
  final Color bgPressed;
  final Color bgDisabled;

  final Color fgDefault;
  final Color fgHover;
  final Color fgPressed;
  final Color fgDisabled;

  final Color borderDefault;
  final Color borderHover;
  final Color borderPressed;
  final Color borderDisabled;

  const DsButtonScheme({
    required this.bgDefault,
    required this.bgHover,
    required this.bgPressed,
    required this.bgDisabled,
    required this.fgDefault,
    Color? fgHover,
    Color? fgPressed,
    required this.fgDisabled,
    this.borderDefault = Colors.transparent,
    Color? borderHover,
    Color? borderPressed,
    Color? borderDisabled,
  }) : fgHover = fgHover ?? fgDefault,
       fgPressed = fgPressed ?? fgDefault,
       borderHover = borderHover ?? borderDefault,
       borderPressed = borderPressed ?? borderDefault,
       borderDisabled = borderDisabled ?? borderDefault;

  Color resolveBg(Set<WidgetState> states) {
    if (_isDisabled(states)) return bgDisabled;
    if (_isPressed(states)) return bgPressed;
    if (_isHovered(states)) return bgHover;
    return bgDefault;
  }

  Color resolveFg(Set<WidgetState> states) {
    if (_isDisabled(states)) return fgDisabled;
    if (_isPressed(states)) return fgPressed;
    if (_isHovered(states)) return fgHover;
    return fgDefault;
  }

  Color resolveBorder(Set<WidgetState> states) {
    if (_isDisabled(states)) return borderDisabled;
    if (_isPressed(states)) return borderPressed;
    if (_isHovered(states)) return borderHover;
    return borderDefault;
  }
}

class DsButtonSchemes {
  /// Filled pink CTA. Matches Figma `Secondary-1`.
  static const primary = DsButtonScheme(
    bgDefault: AppColors.btnSecondary,
    bgHover: AppColors.btnHoverSecondary,
    bgPressed: AppColors.btnActiveSecondary,
    bgDisabled: AppColors.btnDisabledSecondary,
    fgDefault: AppColors.btnTextSecondary,
    fgDisabled: AppColors.btnTextSecondary,
  );

  /// Filled green mini action. Matches Figma `Accept`.
  static const secondary = DsButtonScheme(
    bgDefault: AppColors.accept,
    bgHover: AppColors.acceptHover,
    bgPressed: AppColors.acceptPressed,
    bgDisabled: AppColors.acceptDisabled,
    fgDefault: Colors.white,
    fgDisabled: Colors.white,
  );

  /// Filled red destructive action. Matches Figma error buttons.
  static const error = DsButtonScheme(
    bgDefault: AppColors.denied,
    bgHover: Color(0xFFC83838),
    bgPressed: Color(0xFFFF0000),
    bgDisabled: Color(0xFFFFADAD),
    fgDefault: Colors.white,
    fgDisabled: Colors.white,
  );

  /// Legacy aliases kept for existing call sites.
  static const accentOutline = outlinePrimary;
  static const accentFilled = primary;

  /// Outlined pink button. Matches Figma `Primary-1`.
  static const outlinePrimary = DsButtonScheme(
    bgDefault: Colors.transparent,
    bgHover: AppColors.btnHoverPrimary,
    bgPressed: AppColors.btnActivePrimary,
    bgDisabled: Colors.transparent,
    fgDefault: AppColors.btnPrimary,
    fgHover: Colors.white,
    fgPressed: Colors.white,
    fgDisabled: AppColors.btnDisabledPrimary,
    borderDefault: AppColors.btnPrimary,
    borderHover: Colors.transparent,
    borderPressed: Colors.transparent,
    borderDisabled: AppColors.btnDisabledPrimary,
  );
}
