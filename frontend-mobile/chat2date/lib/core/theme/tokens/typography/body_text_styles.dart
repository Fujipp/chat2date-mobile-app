import 'package:flutter/material.dart';

import 'display_text_styles.dart';

/// Figma node: Typography / Text Regular + Text Semibold
abstract final class AppBodyTextStyles {
  static const TextStyle body = TextStyle(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFF2D2D2D),
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF2D2D2D),
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
    color: Color(0xFF2D2D2D),
  );

  static const TextStyle bodySmallBold = TextStyle(
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w600,
    color: Color(0xFF2D2D2D),
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
    color: Color(0xFF2D2D2D),
  );

  static const TextStyle captionBold = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
    color: Color(0xFF2D2D2D),
  );

  static const TextStyle overline = TextStyle(
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w400,
    color: Color(0xFF2D2D2D),
  );

  static const TextStyle overlineBold = TextStyle(
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w700,
    color: Color(0xFF2D2D2D),
  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF2D2D2D),
  );

  static const TextStyle inputLabel = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
    color: Color(0xFF2D2D2D),
  );

  static const TextStyle inputLabelBold = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
    color: Color(0xFF2D2D2D),
  );

  static const TextStyle helper = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
    color: Color(0xFF8F9098),
  );

  static const TextStyle helperBold = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
    color: Color(0xFF8F9098),
  );

  static const TextStyle toast = caption;
  static const TextStyle toastBold = captionBold;

  static const TextStyle xl = AppDisplayTextStyles.subtitleBold;
  static const TextStyle lg = AppDisplayTextStyles.subtitle;
  static const TextStyle md = body;
  static const TextStyle sm = caption;
  static const TextStyle action = button;
}
