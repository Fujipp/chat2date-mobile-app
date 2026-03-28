import 'package:flutter/material.dart';

import 'button_colors.dart';
import 'input_colors.dart';
import 'main_colors.dart';
import 'text_colors.dart';

@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.background,
    required this.backgroundAlt,
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceHighlight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textNeutral,
    required this.outline,
    required this.divider,
    required this.primaryAction,
    required this.primaryActionHover,
    required this.primaryActionPressed,
    required this.primaryActionDisabled,
    required this.secondaryAction,
    required this.secondaryActionHover,
    required this.secondaryActionPressed,
    required this.secondaryActionDisabled,
    required this.inputBackground,
    required this.inputBorder,
    required this.inputBorderHover,
    required this.inputBorderFocus,
    required this.inputPlaceholder,
    required this.inputText,
    required this.inputDisabledBackground,
    required this.success,
    required this.successText,
    required this.warning,
    required this.warningSoft,
    required this.error,
    required this.errorSoft,
    required this.info,
  });

  final Color background;
  final Color backgroundAlt;
  final Color surface;
  final Color surfaceMuted;
  final Color surfaceHighlight;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textNeutral;
  final Color outline;
  final Color divider;
  final Color primaryAction;
  final Color primaryActionHover;
  final Color primaryActionPressed;
  final Color primaryActionDisabled;
  final Color secondaryAction;
  final Color secondaryActionHover;
  final Color secondaryActionPressed;
  final Color secondaryActionDisabled;
  final Color inputBackground;
  final Color inputBorder;
  final Color inputBorderHover;
  final Color inputBorderFocus;
  final Color inputPlaceholder;
  final Color inputText;
  final Color inputDisabledBackground;
  final Color success;
  final Color successText;
  final Color warning;
  final Color warningSoft;
  final Color error;
  final Color errorSoft;
  final Color info;

  static const AppSemanticColors light = AppSemanticColors(
    // ── Surface (from Color-Main) ─────────────────────────────────────────
    background:       MainColors.background,
    backgroundAlt:    Color(0xFFFFF2CC), // secondary soft – not in Figma tokens
    surface:          MainColors.surface,
    surfaceMuted:     Color(0xFFF2F4F7), // light grey surface – not in Figma tokens
    surfaceHighlight: MainColors.primary,
    // ── Text ──────────────────────────────────────────────────────────────
    textPrimary:   MainColors.surface,          // dark body text on white bg (#2D2D2D)
    textSecondary: TextColors.supportText,      // Color-Text / Support-text (#8F9098)
    textMuted:     TextColors.disabled,         // Color-Text / Disabled (#B9B9B9)
    textNeutral:   TextColors.supportText,      // Color-Text / Support-text (#8F9098)
    outline:       InputColors.border,          // Color-Input / Border (#E2E8F0)
    divider:       MainColors.divider,          // Color-Main / Divider (#E0E0E0)
    // ── Buttons ───────────────────────────────────────────────────────────
    primaryAction:         ButtonColors.primary,
    primaryActionHover:    ButtonColors.primaryHover,
    primaryActionPressed:  ButtonColors.primaryActive,
    primaryActionDisabled: ButtonColors.primaryDisable,
    secondaryAction:         ButtonColors.secondary,
    secondaryActionHover:    ButtonColors.secondaryHover,
    secondaryActionPressed:  ButtonColors.secondaryActive,
    secondaryActionDisabled: ButtonColors.secondaryDisable,
    // ── Inputs ────────────────────────────────────────────────────────────
    inputBackground:         InputColors.background,
    inputBorder:             InputColors.border,
    inputBorderHover:        InputColors.disabled,           // Color-Input / Disabled (#B9B9B9)
    inputBorderFocus:        MainColors.primary,             // Color-Main / Primary
    inputPlaceholder:        TextColors.placeholder,         // Color-Text / Placeholder
    inputText:               InputColors.active,             // Color-Input / Active
    inputDisabledBackground: InputColors.backgroundDisabled, // Color-Input / Background-Disabled
    // ── Status ────────────────────────────────────────────────────────────
    success:     MainColors.success,
    successText: ButtonColors.accept,    // green #21E84F – reuse Button/Accept
    warning:     MainColors.warning,
    warningSoft: MainColors.warning,
    error:       MainColors.error,
    errorSoft:   MainColors.error,
    info:        MainColors.info,
  );

  @override
  AppSemanticColors copyWith({
    Color? background,
    Color? backgroundAlt,
    Color? surface,
    Color? surfaceMuted,
    Color? surfaceHighlight,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textNeutral,
    Color? outline,
    Color? divider,
    Color? primaryAction,
    Color? primaryActionHover,
    Color? primaryActionPressed,
    Color? primaryActionDisabled,
    Color? secondaryAction,
    Color? secondaryActionHover,
    Color? secondaryActionPressed,
    Color? secondaryActionDisabled,
    Color? inputBackground,
    Color? inputBorder,
    Color? inputBorderHover,
    Color? inputBorderFocus,
    Color? inputPlaceholder,
    Color? inputText,
    Color? inputDisabledBackground,
    Color? success,
    Color? successText,
    Color? warning,
    Color? warningSoft,
    Color? error,
    Color? errorSoft,
    Color? info,
  }) {
    return AppSemanticColors(
      background: background ?? this.background,
      backgroundAlt: backgroundAlt ?? this.backgroundAlt,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      surfaceHighlight: surfaceHighlight ?? this.surfaceHighlight,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textNeutral: textNeutral ?? this.textNeutral,
      outline: outline ?? this.outline,
      divider: divider ?? this.divider,
      primaryAction: primaryAction ?? this.primaryAction,
      primaryActionHover: primaryActionHover ?? this.primaryActionHover,
      primaryActionPressed: primaryActionPressed ?? this.primaryActionPressed,
      primaryActionDisabled:
          primaryActionDisabled ?? this.primaryActionDisabled,
      secondaryAction: secondaryAction ?? this.secondaryAction,
      secondaryActionHover: secondaryActionHover ?? this.secondaryActionHover,
      secondaryActionPressed:
          secondaryActionPressed ?? this.secondaryActionPressed,
      secondaryActionDisabled:
          secondaryActionDisabled ?? this.secondaryActionDisabled,
      inputBackground: inputBackground ?? this.inputBackground,
      inputBorder: inputBorder ?? this.inputBorder,
      inputBorderHover: inputBorderHover ?? this.inputBorderHover,
      inputBorderFocus: inputBorderFocus ?? this.inputBorderFocus,
      inputPlaceholder: inputPlaceholder ?? this.inputPlaceholder,
      inputText: inputText ?? this.inputText,
      inputDisabledBackground:
          inputDisabledBackground ?? this.inputDisabledBackground,
      success: success ?? this.success,
      successText: successText ?? this.successText,
      warning: warning ?? this.warning,
      warningSoft: warningSoft ?? this.warningSoft,
      error: error ?? this.error,
      errorSoft: errorSoft ?? this.errorSoft,
      info: info ?? this.info,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) {
      return this;
    }

    return AppSemanticColors(
      background: Color.lerp(background, other.background, t)!,
      backgroundAlt: Color.lerp(backgroundAlt, other.backgroundAlt, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      surfaceHighlight: Color.lerp(
        surfaceHighlight,
        other.surfaceHighlight,
        t,
      )!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textNeutral: Color.lerp(textNeutral, other.textNeutral, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      primaryAction: Color.lerp(primaryAction, other.primaryAction, t)!,
      primaryActionHover: Color.lerp(
        primaryActionHover,
        other.primaryActionHover,
        t,
      )!,
      primaryActionPressed: Color.lerp(
        primaryActionPressed,
        other.primaryActionPressed,
        t,
      )!,
      primaryActionDisabled: Color.lerp(
        primaryActionDisabled,
        other.primaryActionDisabled,
        t,
      )!,
      secondaryAction: Color.lerp(secondaryAction, other.secondaryAction, t)!,
      secondaryActionHover: Color.lerp(
        secondaryActionHover,
        other.secondaryActionHover,
        t,
      )!,
      secondaryActionPressed: Color.lerp(
        secondaryActionPressed,
        other.secondaryActionPressed,
        t,
      )!,
      secondaryActionDisabled: Color.lerp(
        secondaryActionDisabled,
        other.secondaryActionDisabled,
        t,
      )!,
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      inputBorderHover: Color.lerp(
        inputBorderHover,
        other.inputBorderHover,
        t,
      )!,
      inputBorderFocus: Color.lerp(
        inputBorderFocus,
        other.inputBorderFocus,
        t,
      )!,
      inputPlaceholder: Color.lerp(
        inputPlaceholder,
        other.inputPlaceholder,
        t,
      )!,
      inputText: Color.lerp(inputText, other.inputText, t)!,
      inputDisabledBackground: Color.lerp(
        inputDisabledBackground,
        other.inputDisabledBackground,
        t,
      )!,
      success: Color.lerp(success, other.success, t)!,
      successText: Color.lerp(successText, other.successText, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorSoft: Color.lerp(errorSoft, other.errorSoft, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

extension AppSemanticColorsBuildContextX on BuildContext {
  AppSemanticColors get appColors =>
      Theme.of(this).extension<AppSemanticColors>() ?? AppSemanticColors.light;
}
