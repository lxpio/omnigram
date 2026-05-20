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

  // Polish global theme so any remaining un-migrated Material control
  // (Slider, Switch, DropdownButton, Divider) inherits the Liquid Glass
  // look without per-site rewrites. Modal surfaces also get iOS-26
  // squircle shape; background colors stay default so un-migrated
  // `showDialog` / `showModalBottomSheet` callers remain visible. Glass
  // variants (showGlassDialog/showGlassBottomSheet) draw their own
  // GlassSurface and don't depend on this.
  static ThemeData _applyGlassPolish(ThemeData base) {
    final scheme = base.colorScheme;
    final squircleSheet = ContinuousRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(GlassTokens.radiusBar * 2.2)),
    );
    final squircleDialog = ContinuousRectangleBorder(
      borderRadius: BorderRadius.circular(GlassTokens.radiusBar * 2.2),
    );

    // FlexColorScheme derives its own scaffoldBackground from the seed and
    // ignores the `surface:` override on the input ColorScheme — in light
    // mode it lands near-white, which collapses contrast against the glass
    // cards (also near-white because tintLightAlpha is 0.85). Pin scaffold
    // and the low surface containers back to our warm-grey palette so the
    // iOS systemGroupedBackground pattern (grey page + white cards) holds.
    final isLight = base.brightness == Brightness.light;
    final pageBg = isLight ? OmnigramColors.surfaceLight : OmnigramColors.surfaceDark;
    final patchedScheme = scheme.copyWith(
      surface: pageBg,
      surfaceContainerLowest: pageBg,
      surfaceContainerLow: pageBg,
    );

    return base.copyWith(
      scaffoldBackgroundColor: pageBg,
      canvasColor: pageBg,
      colorScheme: patchedScheme,
      bottomSheetTheme: base.bottomSheetTheme.copyWith(shape: squircleSheet),
      dialogTheme: base.dialogTheme.copyWith(shape: squircleDialog),
      popupMenuTheme: base.popupMenuTheme.copyWith(shape: squircleDialog),

      // Thin primary-tinted track, solid thumb, soft overlay.
      sliderTheme: base.sliderTheme.copyWith(
        trackHeight: 4,
        activeTrackColor: patchedScheme.primary,
        inactiveTrackColor: patchedScheme.surfaceContainerHighest,
        thumbColor: patchedScheme.primary,
        overlayColor: patchedScheme.primary.withValues(alpha: 0.12),
        valueIndicatorColor: patchedScheme.primary,
        valueIndicatorTextStyle: TextStyle(color: patchedScheme.onPrimary),
      ),

      // iOS-leaning Material Switch fallback (CupertinoSwitch is used
      // inside SettingsTile.switchTile already; this covers raw
      // SwitchListTile and ad-hoc Switch usages).
      switchTheme: base.switchTheme.copyWith(
        thumbColor: WidgetStateProperty.resolveWith(
          (_) => Colors.white,
        ),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return patchedScheme.primary;
          return patchedScheme.surfaceContainerHighest;
        }),
        trackOutlineColor:
            WidgetStateProperty.all(Colors.transparent),
      ),

      // Squircle dropdown popup with subtle surface color.
      dropdownMenuTheme: base.dropdownMenuTheme.copyWith(
        menuStyle: MenuStyle(
          shape: WidgetStateProperty.all(squircleDialog),
          backgroundColor:
              WidgetStateProperty.all(patchedScheme.surfaceContainer),
          elevation: WidgetStateProperty.all(2),
        ),
      ),

      // 0.5px hair-line divider in outlineVariant @ 30 % alpha. Used by
      // _GlassSettingsRow between tiles and by manual `Divider()` calls.
      dividerTheme: base.dividerTheme.copyWith(
        color: patchedScheme.outlineVariant.withValues(alpha: 0.3),
        thickness: 0.5,
        space: 0.5,
      ),
    );
  }
}
