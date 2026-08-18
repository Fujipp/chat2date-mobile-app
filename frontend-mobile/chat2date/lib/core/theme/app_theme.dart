import 'package:flutter/material.dart';

import 'app_color_schemes.dart';
import 'app_colors.dart';
import 'tokens/colors/app_semantic_colors.dart';
import 'tokens/typography/app_typography.dart';

ThemeData buildLightTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: lightColorScheme,
    scaffoldBackgroundColor: AppColors.background,
    extensions: const [AppSemanticColors.light],
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: NoTransitionsPageTransitionsBuilder(),
        TargetPlatform.iOS: NoTransitionsPageTransitionsBuilder(),
      },
    ),
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
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.brandPrimary,
      selectionColor: AppColors.brandPrimary.withValues(alpha: 0.28),
      selectionHandleColor: AppColors.brandPrimary,
    ),
    dividerColor: AppColors.divider,
  );

  return base.copyWith(textTheme: AppTypography.buildTextTheme(base.textTheme));
}

class NoTransitionsPageTransitionsBuilder extends PageTransitionsBuilder {
  const NoTransitionsPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
