import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'colors.dart';

class OmnigramTheme {
  OmnigramTheme._();

  static const double cardRadius = 16.0;
  static const double cardPadding = 16.0;
  static const double sectionSpacing = 24.0;
  static const double pageHorizontalPadding = 20.0;

  static ThemeData light() {
    return FlexThemeData.light(
      colorScheme: ColorScheme.fromSeed(
        seedColor: OmnigramColors.seed,
        brightness: Brightness.light,
        surface: OmnigramColors.surfaceLight,
      ),
      useMaterial3: true,
      appBarStyle: FlexAppBarStyle.surface,
      subThemesData: const FlexSubThemesData(
        cardRadius: cardRadius,
        inputDecoratorRadius: cardRadius,
        chipRadius: 20.0,
        bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        bottomNavigationBarUnselectedLabelSchemeColor: SchemeColor.onSurfaceVariant,
      ),
    );
  }

  static ThemeData dark() {
    return FlexThemeData.dark(
      colorScheme: ColorScheme.fromSeed(
        seedColor: OmnigramColors.seed,
        brightness: Brightness.dark,
        surface: OmnigramColors.surfaceDark,
      ),
      useMaterial3: true,
      darkIsTrueBlack: false,
      appBarStyle: FlexAppBarStyle.surface,
      subThemesData: const FlexSubThemesData(
        cardRadius: cardRadius,
        inputDecoratorRadius: cardRadius,
        chipRadius: 20.0,
        bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        bottomNavigationBarUnselectedLabelSchemeColor: SchemeColor.onSurfaceVariant,
      ),
    );
  }
}
