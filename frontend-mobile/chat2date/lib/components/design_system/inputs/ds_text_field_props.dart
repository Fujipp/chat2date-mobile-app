import 'package:flutter/material.dart';

enum DsInputVisualState { empty, typing, filled, error, inactive }

enum DsFieldState { normal, success, warning, error, disabled }

enum DsFieldSize { sm, md, lg }

enum DsFieldStyle { filled, outline }

class DsTextFieldStyle {
  const DsTextFieldStyle({
    this.radius = 16,
    this.iconSize = 20,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),
  });

  final double radius;
  final double iconSize;
  final EdgeInsets contentPadding;
}
