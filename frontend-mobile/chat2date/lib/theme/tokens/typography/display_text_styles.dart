import 'package:flutter/material.dart';

/// Figma node: Typography / Text Regular + Text Semibold
abstract final class AppDisplayTextStyles {
  static const TextStyle h1 = TextStyle(
    fontFamily: AppTypographyFamilies.primary,
    fontFamilyFallback: AppTypographyFamilies.fallbacks,
    fontSize: 28,
    height: 32 / 28,
    fontWeight: FontWeight.w400,
    color: Color(0xFF2D2D2D),
  );

  static const TextStyle h1Bold = TextStyle(
    fontFamily: AppTypographyFamilies.primary,
    fontFamilyFallback: AppTypographyFamilies.fallbacks,
    fontSize: 28,
    height: 32 / 28,
    fontWeight: FontWeight.w600,
    color: Color(0xFF2D2D2D),
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: AppTypographyFamilies.primary,
    fontFamilyFallback: AppTypographyFamilies.fallbacks,
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w400,
    color: Color(0xFF2D2D2D),
  );

  static const TextStyle h2Bold = TextStyle(
    fontFamily: AppTypographyFamilies.primary,
    fontFamilyFallback: AppTypographyFamilies.fallbacks,
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w600,
    color: Color(0xFF2D2D2D),
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: AppTypographyFamilies.primary,
    fontFamilyFallback: AppTypographyFamilies.fallbacks,
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w400,
    color: Color(0xFF2D2D2D),
  );

  static const TextStyle h3Bold = TextStyle(
    fontFamily: AppTypographyFamilies.primary,
    fontFamilyFallback: AppTypographyFamilies.fallbacks,
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
    color: Color(0xFF2D2D2D),
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: AppTypographyFamilies.primary,
    fontFamilyFallback: AppTypographyFamilies.fallbacks,
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w400,
    color: Color(0xFF2D2D2D),
  );

  static const TextStyle subtitleBold = TextStyle(
    fontFamily: AppTypographyFamilies.primary,
    fontFamilyFallback: AppTypographyFamilies.fallbacks,
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w600,
    color: Color(0xFF2D2D2D),
  );

  static const TextStyle large = h1;
  static const TextStyle medium = h2;
  static const TextStyle small = h3;
}

abstract final class AppTypographyFamilies {
  static const String primary = 'Inter';
  static const List<String> fallbacks = ['Inter'];
}
