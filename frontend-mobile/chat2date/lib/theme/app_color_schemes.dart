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
  background: AppColors.background,
  onBackground: AppColors.textPrimary,
  surface: AppColors.surface,
  onSurface: AppColors.textPrimary,
);
