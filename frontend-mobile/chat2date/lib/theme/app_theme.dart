import 'package:flutter/material.dart';
import 'app_color_schemes.dart';
import 'app_colors.dart';

ThemeData buildLightTheme() {
  const baseFont = 'Inter';
  const fontFallback = ['Itim']; // เมื่อเจออักษรไทยจะตกไปใช้ Itim

  final base = ThemeData(
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
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.inputBorder),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      focusedBorder: const OutlineInputBorder(
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

    // === ตั้งค่าฟอนต์หลักทั้งแอป ===
    fontFamily: baseFont,
    fontFamilyFallback: fontFallback,
  );

  // ปรับน้ำหนักตัวอักษรที่ใช้บ่อย ๆ ให้เหมาะกับ Inter
  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      displayLarge: base.textTheme.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      displayMedium: base.textTheme.displayMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: base.textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w400,
      ),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
