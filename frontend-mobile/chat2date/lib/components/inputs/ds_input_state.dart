import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'ds_text_field/ds_text_field_props.dart';

class DsInputState {
  static Color borderColor(DsFieldState state) {
    switch (state) {
      case DsFieldState.success:
        return AppColors.success;
      case DsFieldState.warning:
        return AppColors.warning;
      case DsFieldState.error:
        return AppColors.error;
      case DsFieldState.disabled:
        return AppColors.inputBorder;
      default:
        return AppColors.inputBorder;
    }
  }

  static Color focusColor(DsFieldState state) {
    return state == DsFieldState.error
        ? AppColors.error
        : AppColors.inputBorderFocus;
  }
}
