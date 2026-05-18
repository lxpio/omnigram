import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'colors.dart';
import 'liquid_glass/glass_tokens.dart';
import 'typography.dart';

class OmnigramTheme {
  OmnigramTheme._();

  static const double cardRadius = 16.0;
  static const double cardPadding = 16.0;
  static const double sectionSpacing = 24.0;
  static const double pageHorizontalPadding = 20.0;

  static ThemeData light() {
    return _applyGlassPolish(FlexThemeData.light(
      colorScheme: ColorScheme.fromSeed(
        seedColor: OmnigramColors.seed,
        brightness: Brightness.light,
        surface: OmnigramColors.surfaceLight,
      ),
      useMaterial3: true,
      fontFamily: systemFontFamily(),
      appBarStyle: FlexAppBarStyle.surface,
      subThemesData: const FlexSubThemesData(
        cardRadius: cardRadius,
        inputDecoratorRadius: cardRadius,
        chipRadius: 20.0,
        bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        bottomNavigationBarUnselectedLabelSchemeColor: SchemeColor.onSurfaceVariant,
      ),
    ));
  }

  static ThemeData dark() {
    return _applyGlassPolish(FlexThemeData.dark(
      colorScheme: ColorScheme.fromSeed(
        seedColor: OmnigramColors.seed,
        brightness: Brightness.dark,
        surface: OmnigramColors.surfaceDark,
      ),
      useMaterial3: true,
      darkIsTrueBlack: false,
      fontFamily: systemFontFamily(),
      appBarStyle: FlexAppBarStyle.surface,
      subThemesData: const FlexSubThemesData(
        cardRadius: cardRadius,
        inputDecoratorRadius: cardRadius,
        chipRadius: 20.0,
        bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        bottomNavigationBarUnselectedLabelSchemeColor: SchemeColor.onSurfaceVariant,
      ),
    ));
  }

  // Polish modal surfaces to iOS-26 squircle shape. Background colors are
  // intentionally left at theme defaults so un-migrated `showDialog` /
  // `showModalBottomSheet` callers still get a visible surface. Glass-style
  // modals (showGlassDialog/showGlassBottomSheet) draw their own GlassSurface
  // and don't depend on this.
  static ThemeData _applyGlassPolish(ThemeData base) {
    final squircleSheet = ContinuousRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(GlassTokens.radiusBar * 2.2)),
    );
    final squircleDialog = ContinuousRectangleBorder(
      borderRadius: BorderRadius.circular(GlassTokens.radiusBar * 2.2),
    );
    return base.copyWith(
      bottomSheetTheme: base.bottomSheetTheme.copyWith(shape: squircleSheet),
      dialogTheme: base.dialogTheme.copyWith(shape: squircleDialog),
      popupMenuTheme: base.popupMenuTheme.copyWith(shape: squircleDialog),
    );
  }
}
