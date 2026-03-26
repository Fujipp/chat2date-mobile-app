import 'package:flutter/material.dart';

import '../colors/neutral_colors.dart';
import 'body_text_styles.dart';
import 'display_text_styles.dart';

abstract final class AppTypography {
  static const String fontFamily = AppTypographyFamilies.primary;
  static const List<String> fontFamilyFallback =
      AppTypographyFamilies.fallbacks;

  static TextTheme buildTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: AppDisplayTextStyles.h1,
      displayMedium: AppDisplayTextStyles.h2,
      displaySmall: AppDisplayTextStyles.h3,
      headlineLarge: AppDisplayTextStyles.h1Bold,
      headlineMedium: AppDisplayTextStyles.h2Bold,
      headlineSmall: AppDisplayTextStyles.h3Bold,
      titleLarge: AppDisplayTextStyles.subtitleBold,
      titleMedium: AppBodyTextStyles.bodyBold,
      titleSmall: AppBodyTextStyles.bodySmallBold,
      bodyLarge: AppDisplayTextStyles.subtitle.copyWith(
        color: NeutralColors.textPrimary,
      ),
      bodyMedium: AppBodyTextStyles.body.copyWith(
        color: NeutralColors.textPrimary,
      ),
      bodySmall: AppBodyTextStyles.bodySmall.copyWith(
        color: NeutralColors.textSecondary,
      ),
      labelLarge: AppBodyTextStyles.button,
      labelMedium: AppBodyTextStyles.inputLabelBold,
      labelSmall: AppBodyTextStyles.overlineBold,
    );
  }
}
