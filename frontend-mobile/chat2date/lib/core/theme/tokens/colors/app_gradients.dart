import 'package:flutter/material.dart';

import 'button_colors.dart';
import 'data_colors.dart';
import 'main_colors.dart';

/// Special gradient color styles (not part of Figma variable collections).
abstract final class AppGradients {
  /// Rainbow gradient — uses Color-Data tokens + Denied button color.
  /// Stops: data-6 (0%), data-4 (19%), data-1 (34%), data-2 (49%),
  ///         Pastel-5 (64%), data-5 (79%), Denied (100%)
  static const LinearGradient rainbow = LinearGradient(
    colors: [
      DataColors.data6,   // 0%   – #A78BFA
      DataColors.data4,   // 19%  – #2563EB
      DataColors.data1,   // 34%  – #78CEFF
      DataColors.data2,   // 49%  – #98FB98
      DataColors.pastel5, // 64%  – #FFF1A8
      DataColors.data5,   // 79%  – #F59E0B
      ButtonColors.denied, // 100% – #FF6B6B
    ],
    stops: [0.0, 0.19, 0.34, 0.49, 0.64, 0.79, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Theme-App-2 gradient — Primary → Pastel-5.
  /// Stops: Primary (0%) → Pastel-5 (100%)
  static const LinearGradient themeApp2 = LinearGradient(
    colors: [
      MainColors.primary,  // 0%   – #FF6DB1
      DataColors.pastel5,  // 100% – #FFF1A8
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
