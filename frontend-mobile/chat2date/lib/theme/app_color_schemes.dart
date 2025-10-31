import 'package:flutter/material.dart';
import 'app_colors.dart';

final ColorScheme lightColorScheme = const ColorScheme(
  brightness: Brightness.light,
  primary: AppColors.brandPrimary,
  onPrimary: AppColors.brandOnPrimary,
  secondary: AppColors.brandSecondary,
  onSecondary: AppColors.brandOnSecondary,
  error: AppColors.error,
  onError: Colors.white,
  // ✅ ใช้ surface/onSurface แทน background/onBackground
  surface: AppColors.surface,
  onSurface: AppColors.textPrimary,
  // ถ้าต้องการ “สีพื้นหลังของหน้าจอ” ใช้ scaffoldBackgroundColor ใน ThemeData
);
