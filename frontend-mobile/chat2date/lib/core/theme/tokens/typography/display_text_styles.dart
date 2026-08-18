import 'package:flutter/material.dart';

/// Figma node: Typography / Text Regular + Text Semibold
abstract final class AppDisplayTextStyles {
  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    height: 32 / 28,
    fontWeight: FontWeight.w400,
    color: Color(0xFF2D2D2D),
  );

  static const TextStyle h1Bold = TextStyle(
    fontSize: 28,
    height: 32 / 28,
    fontWeight: FontWeight.w600,
    color: Color(0xFF2D2D2D),
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w400,
    color: Color(0xFF2D2D2D),
  );

  static const TextStyle h2Bold = TextStyle(
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w600,
    color: Color(0xFF2D2D2D),
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w400,
    color: Color(0xFF2D2D2D),
  );

  static const TextStyle h3Bold = TextStyle(
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
    color: Color(0xFF2D2D2D),
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w400,
    color: Color(0xFF2D2D2D),
  );

  static const TextStyle subtitleBold = TextStyle(
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
  static const List<String> fallbacks = ['IBMPlexSansThai', 'Inter'];
}
