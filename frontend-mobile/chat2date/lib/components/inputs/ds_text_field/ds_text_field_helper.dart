import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../ds_input_state.dart';
import 'ds_text_field_props.dart';

class DsTextFieldHelper {
  static OutlineInputBorder borderForState(DsFieldState state) {
    final color = DsInputState.borderColor(state);
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: 1.5),
    );
  }

  static Color fillColorForState(DsFieldState state) {
    switch (state) {
      case DsFieldState.disabled:
        return AppColors.inputDisabledBg;
      default:
        return AppColors.inputBg;
    }
  }
}
