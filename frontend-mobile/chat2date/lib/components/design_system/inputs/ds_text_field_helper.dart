import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:chat2date/core/theme/app_colors.dart';
import 'package:chat2date/core/theme/tokens/typography/body_text_styles.dart';
import 'package:chat2date/core/theme/tokens/typography/display_text_styles.dart';
import 'ds_text_field_props.dart';

class DsTextFieldHelper {
  static DsInputVisualState normalizeState({
    required bool enabled,
    required bool hasFocus,
    required bool hasError,
    required bool hasValue,
    DsInputVisualState? explicitState,
  }) {
    if (!enabled) return DsInputVisualState.inactive;
    if (explicitState != null) return explicitState;
    if (hasError) return DsInputVisualState.error;
    if (hasFocus) return DsInputVisualState.typing;
    if (hasValue) return DsInputVisualState.filled;
    return DsInputVisualState.empty;
  }

  static Color borderColorFor(DsInputVisualState state) {
    switch (state) {
      case DsInputVisualState.typing:
        return AppColors.inputBorderFocus;
      case DsInputVisualState.error:
        return AppColors.error;
      case DsInputVisualState.inactive:
      case DsInputVisualState.empty:
      case DsInputVisualState.filled:
        return AppColors.inputBorder;
    }
  }

  static double borderWidthFor(DsInputVisualState state) {
    switch (state) {
      case DsInputVisualState.typing:
      case DsInputVisualState.error:
        return 1.5;
      case DsInputVisualState.empty:
      case DsInputVisualState.filled:
      case DsInputVisualState.inactive:
        return 1;
    }
  }

  static Color fillColorForVisualState(DsInputVisualState state) {
    return state == DsInputVisualState.inactive
        ? AppColors.inputDisabledBg
        : AppColors.inputBg;
  }

  static Color textColorFor(DsInputVisualState state) {
    return state == DsInputVisualState.inactive
        ? AppColors.textDisabled
        : AppColors.textPrimary;
  }

  static Color hintColorFor(DsInputVisualState state) {
    return state == DsInputVisualState.inactive
        ? AppColors.textDisabled
        : AppColors.inputPlaceholder;
  }

  static Color supportColorFor(DsInputVisualState state) {
    return state == DsInputVisualState.error
        ? AppColors.error
        : AppColors.supportText;
  }

  static TextStyle labelStyle({double? fontSize}) {
    return AppDisplayTextStyles.subtitleBold.copyWith(
      color: AppColors.textBlack,
      fontSize: fontSize,
      height: fontSize == null ? null : 22 / fontSize,
    );
  }

  static TextStyle bodyStyle({
    required DsInputVisualState state,
    double? fontSize,
    Color? colorOverride,
  }) {
    final size = fontSize ?? 14.0;
    return AppBodyTextStyles.body.copyWith(
      color: colorOverride ?? textColorFor(state),
      fontSize: size,
      height: 20 / size,
    );
  }

  static TextStyle hintStyle({
    required DsInputVisualState state,
    double? fontSize,
  }) {
    final size = fontSize ?? 14.0;
    return AppBodyTextStyles.body.copyWith(
      color: hintColorFor(state),
      fontSize: size,
      height: 20 / size,
    );
  }

  static TextStyle supportStyle(DsInputVisualState state) {
    return AppBodyTextStyles.helper.copyWith(
      color: supportColorFor(state),
      letterSpacing: 0.15,
    );
  }

  static InputBorder borderForVisualState(
    DsInputVisualState state, {
    double radius = 12,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(
        color: borderColorFor(state),
        width: borderWidthFor(state),
      ),
    );
  }

  static Widget? buildSvgIcon(
    String? assetPath, {
    double size = 16,
    Color? color,
    double turns = 0,
  }) {
    if (assetPath == null) return null;

    final icon = SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      theme: color == null ? null : SvgTheme(currentColor: color),
    );

    if (turns == 0) return icon;

    return Transform.rotate(angle: turns * 3.1415926535897932 * 2, child: icon);
  }
}
