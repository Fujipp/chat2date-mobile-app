import 'package:flutter/material.dart';

import 'tokens/colors/button_colors.dart';
import 'tokens/colors/data_colors.dart';
import 'tokens/colors/input_colors.dart';
import 'tokens/colors/main_colors.dart';
import 'tokens/colors/score_colors.dart';
import 'tokens/colors/text_colors.dart';

/// Convenience aliases for app widgets.
/// Each constant traces back to a Figma token class.
class AppColors {
  // ── Color-Main ────────────────────────────────────────────────────────────
  static const Color brandPrimary    = MainColors.primary;       // #FF6DB1
  static const Color brandSecondary  = MainColors.secondary;     // #FFD700
  static const Color background      = MainColors.background;    // #FFFFFF
  static const Color surface         = MainColors.surface;       // #2D2D2D
  static const Color divider         = MainColors.divider;       // #E0E0E0
  static const Color success         = MainColors.success;       // #CCFFCC
  static const Color warning         = MainColors.warning;       // #FFF2CC
  static const Color warningIcon     = MainColors.warningIcon;   // #FFDA46
  static const Color error           = MainColors.error;         // #FF6B6B
  static const Color info            = MainColors.info;          // #A7E0FF
  static const Color overlay         = MainColors.backgroundBlur; // #999999 70%

  // ── Color-Text ────────────────────────────────────────────────────────────
  static const Color textOnDark      = TextColors.primary;       // #FFFFFF
  static const Color textBlack       = TextColors.secondary;     // #000000
  static const Color textDisabled    = TextColors.disabled;      // #B9B9B9
  static const Color textSupport     = TextColors.supportText;   // #8F9098
  static const Color textPlaceholder = TextColors.placeholder;   // #8F9098

  // Legacy semantic text aliases (values derived from Figma tokens)
  static const Color textPrimary   = MainColors.surface;         // dark body text (#2D2D2D)
  static const Color textSecondary = TextColors.supportText;     // muted text (#8F9098)
  static const Color textMuted     = TextColors.disabled;        // #B9B9B9
  static const Color textNeutral   = TextColors.supportText;     // #8F9098
  static const Color nonSelected   = TextColors.disabled;        // #B9B9B9
  static const Color infoIcon      = MainColors.warningIcon;     // #FFDA46

  // ── Color-Button ──────────────────────────────────────────────────────────
  static const Color btnPrimary         = ButtonColors.primary;
  static const Color btnHoverPrimary    = ButtonColors.primaryHover;
  static const Color btnActivePrimary   = ButtonColors.primaryActive;
  static const Color btnDisabledPrimary = ButtonColors.primaryDisable;
  static const Color btnTextPrimary     = TextColors.primary;    // white text on btn

  static const Color btnSecondary         = ButtonColors.secondary;
  static const Color btnHoverSecondary    = ButtonColors.secondaryHover;
  static const Color btnActiveSecondary   = ButtonColors.secondaryActive;
  static const Color btnDisabledSecondary = ButtonColors.secondaryDisable;
  static const Color btnTextSecondary     = TextColors.primary;  // white text on btn

  static const Color accept         = ButtonColors.accept;
  static const Color acceptHover    = ButtonColors.acceptHover;
  static const Color acceptPressed  = ButtonColors.acceptActive;
  static const Color acceptDisabled = ButtonColors.acceptDisable;

  static const Color denied         = ButtonColors.denied;
  static const Color deniedDisabled = ButtonColors.deniedDisabled;
  static const Color deniedHover    = ButtonColors.deniedHover;
  static const Color deniedActive   = ButtonColors.deniedActive;

  // ── Color-Input ───────────────────────────────────────────────────────────
  static const Color inputActive    = InputColors.active;             // #2D2D2D
  static const Color inputDisabled  = InputColors.disabled;           // #B9B9B9
  static const Color inputBg        = InputColors.background;         // #FFFFFF
  static const Color inputDisabledBg = InputColors.backgroundDisabled; // #F2F4F7
  static const Color inputBorder    = InputColors.border;             // #E2E8F0

  // Legacy input aliases
  static const Color inputText          = InputColors.active;
  static const Color inputBorderHover   = InputColors.disabled;
  static const Color inputBorderFocus   = MainColors.primary;
  static const Color inputPlaceholder   = TextColors.placeholder;
  static const Color supportText        = TextColors.supportText;
  static const Color inputDisabledBgAlt = InputColors.backgroundDisabled;
  static const Color outline            = InputColors.border;

  // ── Color-Data ────────────────────────────────────────────────────────────
  static const Color data1   = DataColors.data1;
  static const Color data2   = DataColors.data2;
  static const Color data3   = DataColors.data3;
  static const Color data4   = DataColors.data4;
  static const Color data5   = DataColors.data5;
  static const Color data6   = DataColors.data6;
  static const Color data7   = DataColors.data7;
  static const Color data8   = DataColors.data8;
  static const Color pastel1 = DataColors.pastel1;
  static const Color pastel2 = DataColors.pastel2;
  static const Color pastel3 = DataColors.pastel3;
  static const Color pastel4 = DataColors.pastel4;
  static const Color pastel5 = DataColors.pastel5;
  static const Color pastel6 = DataColors.pastel6;
  static const Color pastel7 = DataColors.pastel7;

  // ── Color-Score ───────────────────────────────────────────────────────────
  static const Color score1To25   = ScoreColors.range1To25;
  static const Color score26To50  = ScoreColors.range26To50;
  static const Color score51To75  = ScoreColors.range51To75;
  static const Color score76To100 = ScoreColors.range76To100;

  // ── Misc legacy aliases ───────────────────────────────────────────────────
  static const Color backgroundWhite    = MainColors.background;
  static const Color lightPrimary       = MainColors.primary;
  static const Color brandPrimary200    = ButtonColors.primaryDisable;  // #FFB8D9
  static const Color brandPrimary600    = ButtonColors.primaryHover;    // #FF429A
  static const Color brandPrimary700    = ButtonColors.primaryHover;    // #FF429A
  static const Color brandOnPrimary     = TextColors.primary;           // white
  static const Color lightBrandSecondary = MainColors.warning;          // #FFF2CC
  static const Color brandSecondary500  = MainColors.warningIcon;       // #FFDA46
  static const Color brandSecondary700  = DataColors.data5;             // #F59E0B
  static const Color brandOnSecondary   = MainColors.surface;           // #2D2D2D
  static const Color brandAccentPink    = MainColors.warning;           // #FFF2CC
  static const Color brandAccentStrong  = MainColors.primary;           // #FF6DB1
  static const Color brandOnAccent      = TextColors.primary;           // white
  static const Color badgeSecondaryBg   = MainColors.secondary;         // #FFD700
  static const Color badgeErrorBg       = MainColors.error;             // #FF6B6B
  static const Color badgeWarning       = MainColors.warning;           // #FFF2CC
  static const Color surfaceMuted       = Color(0xFFF2F4F7);
  static const Color surfaceLight       = MainColors.primary;
  static const Color errorSurface       = MainColors.error;
  static const Color successText        = ButtonColors.accept;           // #21E84F

  // Neutral scale (kept for backward compat, values from Figma tokens)
  static const Color neutral50   = MainColors.background;     // #FFFFFF
  static const Color neutral100  = Color(0xFFF2F4F7);
  static const Color neutral200  = InputColors.border;         // #E2E8F0
  static const Color neutral300  = MainColors.divider;         // #E0E0E0
  static const Color neutral400  = TextColors.disabled;        // #B9B9B9
  static const Color neutral500  = TextColors.supportText;     // #8F9098
  static const Color neutral600  = MainColors.surface;         // #2D2D2D
  static const Color neutral700  = MainColors.surface;         // #2D2D2D
  static const Color neutral800  = TextColors.secondary;       // #000000
  static const Color neutral900  = TextColors.secondary;       // #000000
  static const Color neutralLight = Color(0xFFF2F4F7);
}
