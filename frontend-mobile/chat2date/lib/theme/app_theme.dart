import 'package:flutter/material.dart';
import 'app_color_schemes.dart';
import 'app_colors.dart';

ThemeData buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: lightColorScheme,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputBg,
      hintStyle: const TextStyle(color: AppColors.inputPlaceholder),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.inputBorder),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.inputBorderFocus, width: 2),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.btnPrimary,
        foregroundColor: AppColors.btnTextPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    dividerColor: AppColors.divider,
  );
}
