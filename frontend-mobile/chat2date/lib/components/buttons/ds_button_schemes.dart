import 'package:flutter/material.dart';

/// Helpers to read current widget states (Flutter 3.19+ widgets layer)
bool _isPressed(Set<WidgetState> s) => s.contains(WidgetState.pressed);
bool _isHovered(Set<WidgetState> s) => s.contains(WidgetState.hovered);
bool _isDisabled(Set<WidgetState> s) => s.contains(WidgetState.disabled);

/// A single button color scheme with state-based mappings.
class DsButtonScheme {
  /// Background colors
  final Color bgDefault;
  final Color bgHover;
  final Color bgPressed;
  final Color bgDisabled;

  /// Foreground (text/icon) colors
  final Color fgDefault;
  final Color fgDisabled;

  /// Border colors (transparent if not used)
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
    required this.fgDisabled,
    this.borderDefault = Colors.transparent,
    Color? borderHover,
    Color? borderPressed,
    Color? borderDisabled,
  }) : borderHover = borderHover ?? borderDefault,
       borderPressed = borderPressed ?? borderDefault,
       borderDisabled = borderDisabled ?? borderDefault;

  /// Resolve background by states
  Color resolveBg(Set<WidgetState> s) {
    if (_isDisabled(s)) return bgDisabled;
    if (_isPressed(s)) return bgPressed;
    if (_isHovered(s)) return bgHover;
    return bgDefault;
  }

  /// Resolve foreground by states
  Color resolveFg(Set<WidgetState> s) {
    if (_isDisabled(s)) return fgDisabled;
    return fgDefault;
  }

  /// Resolve border by states
  Color resolveBorder(Set<WidgetState> s) {
    if (_isDisabled(s)) return borderDisabled;
    if (_isPressed(s)) return borderPressed;
    if (_isHovered(s)) return borderHover;
    return borderDefault;
  }

  /// Convenience mappers to WidgetStateProperty if needed
  WidgetStateProperty<Color> get bg =>
      WidgetStateProperty.resolveWith(resolveBg);
  WidgetStateProperty<Color> get fg =>
      WidgetStateProperty.resolveWith(resolveFg);
  WidgetStateProperty<BorderSide> get side =>
      WidgetStateProperty.resolveWith((s) {
        final c = resolveBorder(s);
        return BorderSide(color: c, width: c == Colors.transparent ? 0 : 1.5);
      });
}

/// Shared disabled-foreground color referenced by designs
const _textDisabled = Color(0xFF9AA5B1);

/// All predefined schemes from the Figma spec Dev ส่งมา
class DsButtonSchemes {
  /// Primary (cyan)
  /// - default: #5CE1E6
  /// - hover:   #55CFD4
  /// - pressed: #75EDF2
  /// - disabled:#B8F1F3
  static const primary = DsButtonScheme(
    bgDefault: Color(0xFF5CE1E6), // btn-bg-Primary
    bgHover: Color(0xFF55CFD4), // btn-hover-Primary
    bgPressed: Color(0xFF75EDF2), // btn-active-Primary
    bgDisabled: Color(0xFFB8F1F3), // btn-disabled-Primary
    fgDefault: Colors.white, // btn-text-Primary-2
    fgDisabled: Colors.white, // Light-Text-Secondary
  );

  /// Error (red)
  /// - default: #FF2222
  /// - hover:   #C73737
  /// - pressed: #FF0000
  /// - disabled:#FFACAC
  static const error = DsButtonScheme(
    bgDefault: Color(0xFFFF2222), // btn-bg-Error
    bgHover: Color(0xFFC73737), // btn-hover-Error
    bgPressed: Color(0xFFFF0000), // btn-active-Error
    bgDisabled: Color(0xFFFFACAC), // btn-disabled-Error
    fgDefault: Colors.white,
    fgDisabled: Colors.white,
  );

  /// Secondary (green)
  /// - default: #98FB98
  /// - hover:   #AFE866
  /// - pressed: #ACFF42
  /// - disabled:#B7FFB7
  static const secondary = DsButtonScheme(
    bgDefault: Color(0xFF98FB98), // Light-Secondary
    bgHover: Color(0xFFAFE866), // btn-hover-Secondary
    bgPressed: Color(0xFFACFF42), // btn-active-Secondary
    bgDisabled: Color(0xFFB7FFB7), // btn-disabled-Secondary
    fgDefault: Colors.white,
    fgDisabled: Colors.white,
  );

  /// Accent Outline (pink ring)
  /// - border/text: #FF8FB3
  static const accentOutline = DsButtonScheme(
    bgDefault: Colors.transparent,
    bgHover: Colors.transparent,
    bgPressed: Colors.transparent,
    bgDisabled: Colors.transparent,
    fgDefault: Color(0xFFFF8FB3), // Light-Surface (text)
    fgDisabled: _textDisabled,
    borderDefault: Color(0xFFFF8FB3), // Light-Surface (border)
  );

  /// Accent Filled (pink filled)
  /// - bg: #FFB3C7, border: #FF739F
  static const accentFilled = DsButtonScheme(
    bgDefault: Color(0xFFFFB3C7), // Light-Accent
    bgHover: Color(0xFFFFB3C7),
    bgPressed: Color(0xFFFFB3C7),
    bgDisabled: Color(0xFFFFB3C7),
    fgDefault: Colors.white,
    fgDisabled: Colors.white,
    borderDefault: Color(0xFFFF739F), // Light-Accent-Strong
  );

  /// Outline Primary (cyan ring)
  /// - border/text: #5CE1E6
  static const outlinePrimary = DsButtonScheme(
    bgDefault: Colors.transparent,
    bgHover: Colors.transparent,
    bgPressed: Colors.transparent,
    bgDisabled: Colors.transparent,
    fgDefault: Color(0xFF5CE1E6),
    fgDisabled: _textDisabled,
    borderDefault: Color(0xFF5CE1E6),
  );
}
