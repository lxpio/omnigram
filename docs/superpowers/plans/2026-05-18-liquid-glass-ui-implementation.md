# Liquid Glass UI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Align app chrome (nav, buttons, menus, secondary panels) to iOS 26 Liquid Glass visual language across all platforms while preserving FlexColorScheme warm cards as the content layer.

**Architecture:** New `lib/theme/liquid_glass/` package providing a self-contained set of glass-material widgets (surface, button, app bar, tab bar, menu, sheet, chip) layered over the existing `OmnigramTheme`. A Riverpod-driven `GlassQuality` tier (high/medium/low) auto-detects device capability and is forcibly degraded one step inside the Reader.

**Tech Stack:** Flutter 3.41 · Dart 3.11 · Riverpod v2 (code-gen) · `device_info_plus` · `BackdropFilter` + `ContinuousRectangleBorder` · `HapticFeedback`

**Spec:** `docs/superpowers/specs/2026-05-18-liquid-glass-ui-design.md`

---

## File Structure

### Created

| Path | Responsibility |
|---|---|
| `app/lib/theme/liquid_glass/glass_tokens.dart` | All visual + animation constants (blur, tint, highlight, radius, durations, curves) |
| `app/lib/theme/liquid_glass/performance_mode.dart` | `GlassQuality` enum + `GlassQualityNotifier` provider + device auto-detect + Reader-step-down helper |
| `app/lib/theme/liquid_glass/glass_surface.dart` | Base widget: `BackdropFilter` + tint + edge highlight + Squircle clip, varies by quality tier |
| `app/lib/theme/liquid_glass/glass_button.dart` | `GlassButton` widget with Morph Press animation + haptic |
| `app/lib/theme/liquid_glass/glass_app_bar.dart` | `GlassAppBar` with Scroll Edge Effect |
| `app/lib/theme/liquid_glass/glass_tab_bar.dart` | `GlassTabBar` with Collapse-to-capsule behavior |
| `app/lib/theme/liquid_glass/glass_menu.dart` | Glass `PopupMenu` / context menu wrappers |
| `app/lib/theme/liquid_glass/glass_sheet.dart` | `showGlassBottomSheet` / `showGlassDialog` helpers + theme |
| `app/lib/theme/liquid_glass/glass_chip.dart` | `GlassChip` for filter chips + grouped list sections |
| `app/test/theme/liquid_glass/glass_tokens_test.dart` | Token sanity tests |
| `app/test/theme/liquid_glass/performance_mode_test.dart` | Auto-detect logic + Reader step-down tests |
| `app/test/theme/liquid_glass/glass_surface_test.dart` | Widget structure tests per quality tier |
| `app/test/theme/liquid_glass/glass_button_test.dart` | Morph press animation + haptic tests |
| `app/test/theme/liquid_glass/glass_tab_bar_test.dart` | Collapse/expand behavior tests |

### Modified

| Path | Change |
|---|---|
| `app/lib/theme/typography.dart` | Add SF Pro / Roboto Flex / Segoe UI Variable platform fallback |
| `app/lib/theme/omnigram_theme.dart` | Wire `GlassSheet` theme into `dialogTheme` / `bottomSheetTheme` / `popupMenuTheme` / `snackBarTheme` |
| `app/lib/widgets/common/anx_button.dart` | Add `AnxButtonStyle.glass` variant routing to `GlassButton` |
| `app/lib/widgets/common/anx_dropdown_button.dart` | Same — `glass` variant |
| `app/lib/widgets/common/anx_segmented_button.dart` | Same — `glass` variant |
| `app/lib/page/omnigram_home.dart` | Replace `BottomNavigationBar` with `GlassTabBar`; replace `AppBar`s in 4 tabs with `GlassAppBar` |
| `app/lib/page/home/library/...` (filter chip row) | Switch filter chip widgets to `GlassChip` |
| `app/lib/page/home/settings/...` (grouped list sections) | Wrap section containers in `GlassSurface` |
| `app/lib/page/reader/...` (top + bottom toolbars, TOC drawer) | Switch to glass widgets bound to Reader-stepped-down quality |
| `app/pubspec.yaml` | No new deps (`device_info_plus` already present) |
| `docs/superpowers/PROGRESS.md` | Add "Liquid Glass UI" row |
| `CLAUDE.md` | App Design Principles §3: add "chrome = glass, content = warm card" |

---

## Task 1: Tokens — Foundation

**Files:**
- Create: `app/lib/theme/liquid_glass/glass_tokens.dart`
- Create: `app/test/theme/liquid_glass/glass_tokens_test.dart`

- [ ] **Step 1.1: Write failing token test**

```dart
// app/test/theme/liquid_glass/glass_tokens_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/theme/liquid_glass/glass_tokens.dart';

void main() {
  group('GlassTokens', () {
    test('blur sigmas are ordered thin < thick < ultra', () {
      expect(GlassTokens.blurSigmaThin, lessThan(GlassTokens.blurSigmaThick));
      expect(GlassTokens.blurSigmaThick, lessThan(GlassTokens.blurSigmaUltra));
    });

    test('tint alpha never exceeds 0.7', () {
      expect(GlassTokens.tintLightAlpha, lessThanOrEqualTo(0.7));
      expect(GlassTokens.tintDarkAlpha, lessThanOrEqualTo(0.7));
    });

    test('radius scale is monotonic button < menu < bar < sheet', () {
      expect(GlassTokens.radiusButton, lessThan(GlassTokens.radiusMenu));
      expect(GlassTokens.radiusMenu, lessThan(GlassTokens.radiusBar));
      expect(GlassTokens.radiusBar, lessThan(GlassTokens.radiusSheet));
    });

    test('springOut curve overshoots above 1.0', () {
      final t = GlassTokens.springOut.transform(0.7);
      expect(t, greaterThan(1.0));
    });
  });
}
```

- [ ] **Step 1.2: Run test, expect FAIL (file missing)**

Run from `app/`:
```bash
flutter test test/theme/liquid_glass/glass_tokens_test.dart
```
Expected: FAIL with "Target of URI doesn't exist".

- [ ] **Step 1.3: Write `glass_tokens.dart`**

```dart
// app/lib/theme/liquid_glass/glass_tokens.dart
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

class GlassTokens {
  GlassTokens._();

  // —— Blur sigmas ——
  static const double blurSigmaThin  = 12.0;   // buttons / chips / menu items
  static const double blurSigmaThick = 24.0;   // app bar / tab bar / sheet
  static const double blurSigmaUltra = 40.0;   // full-screen modal scrim

  // —— Tint alphas ——
  static const double tintLightAlpha = 0.55;
  static const double tintDarkAlpha  = 0.45;

  static Color tintLight() => Colors.white.withValues(alpha: tintLightAlpha);
  static Color tintDark()  => Colors.black.withValues(alpha: tintDarkAlpha);

  // —— Edge highlight ——
  static const double highlightWidth = 0.8;
  static Color highlightLight = Colors.white.withValues(alpha: 0.6);
  static Color highlightDark  = Colors.white.withValues(alpha: 0.12);
  static Color shadowEdge     = Colors.black.withValues(alpha: 0.08);

  // —— Squircle radii ——
  static const double radiusButton = 14.0;
  static const double radiusMenu   = 18.0;
  static const double radiusBar    = 22.0;
  static const double radiusSheet  = 28.0;
  static const double radiusCapsule = 32.0;

  // —— Press scale ——
  static const double pressedScale  = 0.96;
  static const double overshootScale = 1.02;

  // —— Animation ——
  static const Duration morphPressIn   = Duration(milliseconds: 80);
  static const Duration morphPressOut  = Duration(milliseconds: 220);
  static const Cubic    springOut      = Cubic(0.34, 1.56, 0.64, 1.0);
  static const Duration scrollEdgeFade = Duration(milliseconds: 180);
  static const Duration tabCollapse    = Duration(milliseconds: 320);

  // —— Tab collapse triggers ——
  static const double tabCollapseScrollThreshold = 60.0;
  static const Duration tabCollapseDebounce = Duration(milliseconds: 200);
}
```

- [ ] **Step 1.4: Run test, expect PASS**

```bash
flutter test test/theme/liquid_glass/glass_tokens_test.dart
```
Expected: All 4 tests PASS.

- [ ] **Step 1.5: Commit**

```bash
git add app/lib/theme/liquid_glass/glass_tokens.dart app/test/theme/liquid_glass/glass_tokens_test.dart
git commit -m "feat(theme): add liquid glass design tokens"
```

---

## Task 2: Performance Mode — Auto-detect + Reader Step-down

**Files:**
- Create: `app/lib/theme/liquid_glass/performance_mode.dart`
- Create: `app/test/theme/liquid_glass/performance_mode_test.dart`

- [ ] **Step 2.1: Write failing tests**

```dart
// app/test/theme/liquid_glass/performance_mode_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/theme/liquid_glass/performance_mode.dart';

void main() {
  group('GlassQuality.steppedDownForReader', () {
    test('high steps down to medium', () {
      expect(GlassQuality.high.steppedDownForReader(), GlassQuality.medium);
    });
    test('medium steps down to low', () {
      expect(GlassQuality.medium.steppedDownForReader(), GlassQuality.low);
    });
    test('low stays at low', () {
      expect(GlassQuality.low.steppedDownForReader(), GlassQuality.low);
    });
  });

  group('GlassQuality predicates', () {
    test('hasBlur only true for high', () {
      expect(GlassQuality.high.hasBlur, isTrue);
      expect(GlassQuality.medium.hasBlur, isFalse);
      expect(GlassQuality.low.hasBlur, isFalse);
    });
    test('hasMotion true for high+medium, false for low', () {
      expect(GlassQuality.high.hasMotion, isTrue);
      expect(GlassQuality.medium.hasMotion, isTrue);
      expect(GlassQuality.low.hasMotion, isFalse);
    });
  });

  group('resolveAutoQuality (pure)', () {
    test('iOS always high', () {
      expect(
        resolveAutoQuality(platform: GlassPlatform.iOS, totalRamMb: 2048, sdkInt: 0),
        GlassQuality.high,
      );
    });
    test('Android 6GB API 31 = high', () {
      expect(
        resolveAutoQuality(platform: GlassPlatform.android, totalRamMb: 6 * 1024, sdkInt: 31),
        GlassQuality.high,
      );
    });
    test('Android 4GB API 31 = medium', () {
      expect(
        resolveAutoQuality(platform: GlassPlatform.android, totalRamMb: 4 * 1024, sdkInt: 31),
        GlassQuality.medium,
      );
    });
    test('Android 3GB = low', () {
      expect(
        resolveAutoQuality(platform: GlassPlatform.android, totalRamMb: 3 * 1024, sdkInt: 31),
        GlassQuality.low,
      );
    });
    test('Android API 30 = low regardless of RAM', () {
      expect(
        resolveAutoQuality(platform: GlassPlatform.android, totalRamMb: 8 * 1024, sdkInt: 30),
        GlassQuality.low,
      );
    });
  });
}
```

- [ ] **Step 2.2: Run, expect FAIL**

```bash
flutter test test/theme/liquid_glass/performance_mode_test.dart
```
Expected: FAIL — file does not exist.

- [ ] **Step 2.3: Implement `performance_mode.dart`**

```dart
// app/lib/theme/liquid_glass/performance_mode.dart
import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'performance_mode.g.dart';

enum GlassQuality {
  high,
  medium,
  low;

  bool get hasBlur   => this == GlassQuality.high;
  bool get hasMotion => this != GlassQuality.low;

  GlassQuality steppedDownForReader() => switch (this) {
        GlassQuality.high   => GlassQuality.medium,
        GlassQuality.medium => GlassQuality.low,
        GlassQuality.low    => GlassQuality.low,
      };
}

/// User-selectable override stored in SharedPreferences.
enum GlassQualityOverride { auto, high, medium, low }

enum GlassPlatform { iOS, macOS, android, windows, other }

/// Pure function — testable without device info.
GlassQuality resolveAutoQuality({
  required GlassPlatform platform,
  required int totalRamMb,
  required int sdkInt,
}) {
  switch (platform) {
    case GlassPlatform.iOS:
    case GlassPlatform.macOS:
    case GlassPlatform.windows:
      return GlassQuality.high;
    case GlassPlatform.android:
      if (sdkInt < 31) return GlassQuality.low;
      if (totalRamMb >= 6 * 1024) return GlassQuality.high;
      if (totalRamMb >= 4 * 1024) return GlassQuality.medium;
      return GlassQuality.low;
    case GlassPlatform.other:
      return GlassQuality.medium;
  }
}

const _kOverrideKey = 'glass_quality_override';
const _kCachedAutoKey = 'glass_quality_auto_cache';

@Riverpod(keepAlive: true)
class GlassQualityController extends _$GlassQualityController {
  @override
  Future<GlassQuality> build() async {
    final prefs = await SharedPreferences.getInstance();
    final overrideName = prefs.getString(_kOverrideKey) ?? GlassQualityOverride.auto.name;
    final override = GlassQualityOverride.values.firstWhere(
      (e) => e.name == overrideName,
      orElse: () => GlassQualityOverride.auto,
    );
    if (override != GlassQualityOverride.auto) {
      return GlassQuality.values.byName(override.name);
    }
    final cached = prefs.getString(_kCachedAutoKey);
    if (cached != null) {
      return GlassQuality.values.byName(cached);
    }
    final auto = await _detect();
    await prefs.setString(_kCachedAutoKey, auto.name);
    return auto;
  }

  Future<void> setOverride(GlassQualityOverride override) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kOverrideKey, override.name);
    ref.invalidateSelf();
  }

  Future<GlassQuality> _detect() async {
    final info = DeviceInfoPlugin();
    if (Platform.isIOS)     return resolveAutoQuality(platform: GlassPlatform.iOS,     totalRamMb: 0, sdkInt: 0);
    if (Platform.isMacOS)   return resolveAutoQuality(platform: GlassPlatform.macOS,   totalRamMb: 0, sdkInt: 0);
    if (Platform.isWindows) return resolveAutoQuality(platform: GlassPlatform.windows, totalRamMb: 0, sdkInt: 0);
    if (Platform.isAndroid) {
      final a = await info.androidInfo;
      final ramMb = (a.systemFeatures.contains('android.hardware.ram.normal') ? 4096 : 4096);
      // device_info_plus does not expose RAM directly; treat presence of high-end heuristics:
      final isHighEnd = a.version.sdkInt >= 31 && (a.supported64BitAbis.isNotEmpty);
      return resolveAutoQuality(
        platform: GlassPlatform.android,
        totalRamMb: isHighEnd ? 6 * 1024 : ramMb,
        sdkInt: a.version.sdkInt,
      );
    }
    return GlassQuality.medium;
  }
}

/// Reader scope — always one tier below the global setting.
@riverpod
GlassQuality readerGlassQuality(Ref ref) {
  final globalAsync = ref.watch(glassQualityControllerProvider);
  return globalAsync.maybeWhen(
    data: (q) => q.steppedDownForReader(),
    orElse: () => GlassQuality.low,
  );
}
```

> NOTE: `device_info_plus` does not expose total RAM cleanly cross-platform. The detection is intentionally heuristic. The pure `resolveAutoQuality` is fully unit-tested; `_detect()` is integration-tested manually in Task 11.

- [ ] **Step 2.4: Run codegen**

```bash
cd app && dart run build_runner build --delete-conflicting-outputs
```
Expected: `performance_mode.g.dart` generated.

- [ ] **Step 2.5: Run test, expect PASS**

```bash
flutter test test/theme/liquid_glass/performance_mode_test.dart
```
Expected: All tests PASS.

- [ ] **Step 2.6: Commit**

```bash
git add app/lib/theme/liquid_glass/performance_mode.dart \
        app/lib/theme/liquid_glass/performance_mode.g.dart \
        app/test/theme/liquid_glass/performance_mode_test.dart
git commit -m "feat(theme): add glass quality tier with auto-detect and reader step-down"
```

---

## Task 3: GlassSurface — Base Widget

**Files:**
- Create: `app/lib/theme/liquid_glass/glass_surface.dart`
- Create: `app/test/theme/liquid_glass/glass_surface_test.dart`

- [ ] **Step 3.1: Write failing widget tests**

```dart
// app/test/theme/liquid_glass/glass_surface_test.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/theme/liquid_glass/glass_surface.dart';
import 'package:omnigram/theme/liquid_glass/performance_mode.dart';

void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('high quality includes BackdropFilter', (tester) async {
    await tester.pumpWidget(host(
      const GlassSurface(quality: GlassQuality.high, child: SizedBox(width: 100, height: 100)),
    ));
    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets('medium quality omits BackdropFilter', (tester) async {
    await tester.pumpWidget(host(
      const GlassSurface(quality: GlassQuality.medium, child: SizedBox(width: 100, height: 100)),
    ));
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('low quality omits BackdropFilter and uses opaque container', (tester) async {
    await tester.pumpWidget(host(
      const GlassSurface(quality: GlassQuality.low, child: SizedBox(width: 100, height: 100)),
    ));
    expect(find.byType(BackdropFilter), findsNothing);
  });
}
```

- [ ] **Step 3.2: Run, expect FAIL**

```bash
flutter test test/theme/liquid_glass/glass_surface_test.dart
```
Expected: FAIL — file missing.

- [ ] **Step 3.3: Implement `glass_surface.dart`**

```dart
// app/lib/theme/liquid_glass/glass_surface.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'glass_tokens.dart';
import 'performance_mode.dart';

class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    required this.quality,
    this.borderRadius = GlassTokens.radiusBar,
    this.blurSigma = GlassTokens.blurSigmaThick,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final GlassQuality quality;
  final double borderRadius;
  final double blurSigma;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = isDark ? GlassTokens.tintDark() : GlassTokens.tintLight();
    final highlight = isDark ? GlassTokens.highlightDark : GlassTokens.highlightLight;
    final shape = ContinuousRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius * 2.2), // continuous compensation
    );

    final tinted = Container(
      padding: padding,
      decoration: ShapeDecoration(
        color: quality.hasBlur ? tint : tint.withValues(alpha: tint.a + 0.15),
        shape: shape,
      ),
      child: child,
    );

    final highlighted = DecoratedBox(
      decoration: ShapeDecoration(
        shape: ContinuousRectangleBorder(
          side: BorderSide(color: highlight, width: GlassTokens.highlightWidth),
          borderRadius: BorderRadius.circular(borderRadius * 2.2),
        ),
      ),
      child: tinted,
    );

    if (!quality.hasBlur) {
      return ClipPath(
        clipper: ShapeBorderClipper(shape: shape),
        child: highlighted,
      );
    }

    return ClipPath(
      clipper: ShapeBorderClipper(shape: shape),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: highlighted,
      ),
    );
  }
}
```

- [ ] **Step 3.4: Run test, expect PASS**

```bash
flutter test test/theme/liquid_glass/glass_surface_test.dart
```
Expected: All 3 tests PASS.

- [ ] **Step 3.5: Commit**

```bash
git add app/lib/theme/liquid_glass/glass_surface.dart app/test/theme/liquid_glass/glass_surface_test.dart
git commit -m "feat(theme): add GlassSurface base widget with quality-aware rendering"
```

---

## Task 4: GlassButton — Morph Press

**Files:**
- Create: `app/lib/theme/liquid_glass/glass_button.dart`
- Create: `app/test/theme/liquid_glass/glass_button_test.dart`

- [ ] **Step 4.1: Write failing tests**

```dart
// app/test/theme/liquid_glass/glass_button_test.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/theme/liquid_glass/glass_button.dart';
import 'package:omnigram/theme/liquid_glass/glass_tokens.dart';
import 'package:omnigram/theme/liquid_glass/performance_mode.dart';

void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: Center(child: child)));

  testWidgets('tap fires onPressed', (tester) async {
    var taps = 0;
    await tester.pumpWidget(host(GlassButton(
      quality: GlassQuality.high,
      onPressed: () => taps++,
      child: const Text('Hi'),
    )));
    await tester.tap(find.text('Hi'));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('press shrinks scale toward pressedScale (high quality)', (tester) async {
    await tester.pumpWidget(host(GlassButton(
      quality: GlassQuality.high,
      onPressed: () {},
      child: const Text('Hi'),
    )));

    final gesture = await tester.startGesture(tester.getCenter(find.text('Hi')));
    await tester.pump(GlassTokens.morphPressIn);

    final transform = tester.widget<Transform>(find.byType(Transform).first);
    final scale = transform.transform.getMaxScaleOnAxis();
    expect(scale, closeTo(GlassTokens.pressedScale, 0.02));

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('low quality does not animate scale', (tester) async {
    await tester.pumpWidget(host(GlassButton(
      quality: GlassQuality.low,
      onPressed: () {},
      child: const Text('Hi'),
    )));
    final gesture = await tester.startGesture(tester.getCenter(find.text('Hi')));
    await tester.pump(GlassTokens.morphPressIn);
    expect(find.byType(Transform), findsNothing); // no animated Transform
    await gesture.up();
  });

  testWidgets('press calls HapticFeedback.lightImpact', (tester) async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      calls.add(call);
      return null;
    });

    await tester.pumpWidget(host(GlassButton(
      quality: GlassQuality.high,
      onPressed: () {},
      child: const Text('Hi'),
    )));
    await tester.tap(find.text('Hi'));
    await tester.pumpAndSettle();

    expect(
      calls.any((c) => c.method == 'HapticFeedback.vibrate' && c.arguments == 'HapticFeedbackType.lightImpact'),
      isTrue,
    );
  });
}
```

- [ ] **Step 4.2: Run, expect FAIL**

```bash
flutter test test/theme/liquid_glass/glass_button_test.dart
```
Expected: FAIL — file missing.

- [ ] **Step 4.3: Implement `glass_button.dart`**

```dart
// app/lib/theme/liquid_glass/glass_button.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'glass_surface.dart';
import 'glass_tokens.dart';
import 'performance_mode.dart';

class GlassButton extends StatefulWidget {
  const GlassButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.quality,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    this.borderRadius = GlassTokens.radiusButton,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final GlassQuality quality;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _pressed = false;

  void _handleTapDown(_) => setState(() => _pressed = true);
  void _handleTapUp(_)   => setState(() => _pressed = false);
  void _handleTapCancel() => setState(() => _pressed = false);

  void _handleTap() {
    if (widget.onPressed == null) return;
    HapticFeedback.lightImpact();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final surface = GlassSurface(
      quality: widget.quality,
      borderRadius: widget.borderRadius,
      blurSigma: GlassTokens.blurSigmaThin,
      padding: widget.padding,
      child: DefaultTextStyle.merge(
        style: Theme.of(context).textTheme.labelLarge ?? const TextStyle(),
        child: widget.child,
      ),
    );

    final tappable = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: surface,
    );

    if (!widget.quality.hasMotion) return tappable;

    return AnimatedScale(
      scale: _pressed ? GlassTokens.pressedScale : 1.0,
      duration: _pressed ? GlassTokens.morphPressIn : GlassTokens.morphPressOut,
      curve: _pressed ? Curves.easeOut : GlassTokens.springOut,
      child: tappable,
    );
  }
}
```

- [ ] **Step 4.4: Run test, expect PASS**

```bash
flutter test test/theme/liquid_glass/glass_button_test.dart
```
Expected: All 4 tests PASS.

- [ ] **Step 4.5: Commit**

```bash
git add app/lib/theme/liquid_glass/glass_button.dart app/test/theme/liquid_glass/glass_button_test.dart
git commit -m "feat(theme): add GlassButton with morph press + haptic"
```

---

## Task 5: GlassAppBar — Scroll Edge Effect

**Files:**
- Create: `app/lib/theme/liquid_glass/glass_app_bar.dart`

- [ ] **Step 5.1: Write minimal widget test**

```dart
// app/test/theme/liquid_glass/glass_app_bar_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/theme/liquid_glass/glass_app_bar.dart';
import 'package:omnigram/theme/liquid_glass/performance_mode.dart';

void main() {
  testWidgets('GlassAppBar starts at zero opacity scroll', (tester) async {
    final controller = ScrollController();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
          controller: controller,
          slivers: [
            GlassAppBar(quality: GlassQuality.high, title: const Text('T')),
            SliverList.list(children: List.generate(40, (i) => SizedBox(height: 50, child: Text('$i')))),
          ],
        ),
      ),
    ));

    // Initial: not scrolled — opacity should be at minimum.
    final opacity0 = tester.widget<Opacity>(find.byKey(const Key('glass_app_bar_layer'))).opacity;
    expect(opacity0, lessThan(0.2));

    controller.jumpTo(200);
    await tester.pump();
    final opacity1 = tester.widget<Opacity>(find.byKey(const Key('glass_app_bar_layer'))).opacity;
    expect(opacity1, greaterThan(0.8));
  });
}
```

- [ ] **Step 5.2: Run, expect FAIL**

```bash
flutter test test/theme/liquid_glass/glass_app_bar_test.dart
```

- [ ] **Step 5.3: Implement `glass_app_bar.dart`**

```dart
// app/lib/theme/liquid_glass/glass_app_bar.dart
import 'package:flutter/material.dart';
import 'glass_surface.dart';
import 'glass_tokens.dart';
import 'performance_mode.dart';

class GlassAppBar extends StatefulWidget {
  const GlassAppBar({
    super.key,
    required this.quality,
    required this.title,
    this.actions = const [],
    this.height = kToolbarHeight,
  });

  final GlassQuality quality;
  final Widget title;
  final List<Widget> actions;
  final double height;

  @override
  State<GlassAppBar> createState() => _GlassAppBarState();
}

class _GlassAppBarState extends State<GlassAppBar> {
  double _scrolledFraction = 0.0;

  bool _onScroll(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return false;
    final f = (n.metrics.pixels / 80.0).clamp(0.0, 1.0);
    if ((f - _scrolledFraction).abs() > 0.02) {
      setState(() => _scrolledFraction = f);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final layer = Opacity(
      key: const Key('glass_app_bar_layer'),
      opacity: _scrolledFraction,
      child: GlassSurface(
        quality: widget.quality,
        borderRadius: 0,
        blurSigma: GlassTokens.blurSigmaThick,
        child: SizedBox(height: widget.height),
      ),
    );

    final foreground = SizedBox(
      height: widget.height,
      child: Row(
        children: [
          const SizedBox(width: 16),
          DefaultTextStyle.merge(
            style: Theme.of(context).textTheme.titleLarge!,
            child: widget.title,
          ),
          const Spacer(),
          ...widget.actions,
          const SizedBox(width: 8),
        ],
      ),
    );

    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: SliverAppBar(
        pinned: true,
        toolbarHeight: widget.height,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Stack(children: [Positioned.fill(child: layer), foreground]),
      ),
    );
  }
}
```

> NOTE: This `GlassAppBar` is a `SliverAppBar` returning widget; consumers must place it inside a `CustomScrollView`. For non-sliver usages we'll add a thin `GlassAppBarBox` variant in Task 7 only if needed.

- [ ] **Step 5.4: Run test, expect PASS**

```bash
flutter test test/theme/liquid_glass/glass_app_bar_test.dart
```

- [ ] **Step 5.5: Commit**

```bash
git add app/lib/theme/liquid_glass/glass_app_bar.dart app/test/theme/liquid_glass/glass_app_bar_test.dart
git commit -m "feat(theme): add GlassAppBar with scroll-edge fade"
```

---

## Task 6: GlassTabBar — Collapse-to-Capsule

**Files:**
- Create: `app/lib/theme/liquid_glass/glass_tab_bar.dart`
- Create: `app/test/theme/liquid_glass/glass_tab_bar_test.dart`

- [ ] **Step 6.1: Write failing tests**

```dart
// app/test/theme/liquid_glass/glass_tab_bar_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/theme/liquid_glass/glass_tab_bar.dart';
import 'package:omnigram/theme/liquid_glass/glass_tokens.dart';
import 'package:omnigram/theme/liquid_glass/performance_mode.dart';

void main() {
  Widget host(GlassTabBarController c) => MaterialApp(
        home: Scaffold(
          body: const SizedBox.expand(),
          bottomNavigationBar: GlassTabBar(
            quality: GlassQuality.high,
            controller: c,
            currentIndex: 0,
            onTap: (_) {},
            items: const [
              GlassTabItem(icon: Icons.book, label: 'Desk'),
              GlassTabItem(icon: Icons.library_books, label: 'Library'),
              GlassTabItem(icon: Icons.insights, label: 'Insights'),
              GlassTabItem(icon: Icons.settings, label: 'Settings'),
            ],
          ),
        ),
      );

  testWidgets('starts expanded', (tester) async {
    final c = GlassTabBarController();
    await tester.pumpWidget(host(c));
    expect(c.collapsed, isFalse);
  });

  testWidgets('scrolling down past threshold collapses', (tester) async {
    final c = GlassTabBarController();
    await tester.pumpWidget(host(c));

    c.handleScrollDelta(GlassTokens.tabCollapseScrollThreshold + 1);
    await tester.pump(GlassTokens.tabCollapseDebounce);
    await tester.pumpAndSettle();
    expect(c.collapsed, isTrue);
  });

  testWidgets('scrolling up expands immediately', (tester) async {
    final c = GlassTabBarController();
    await tester.pumpWidget(host(c));
    c.handleScrollDelta(GlassTokens.tabCollapseScrollThreshold + 1);
    await tester.pump(GlassTokens.tabCollapseDebounce);
    expect(c.collapsed, isTrue);

    c.handleScrollDelta(-10);
    await tester.pump();
    expect(c.collapsed, isFalse);
  });
}
```

- [ ] **Step 6.2: Run, expect FAIL**

```bash
flutter test test/theme/liquid_glass/glass_tab_bar_test.dart
```

- [ ] **Step 6.3: Implement `glass_tab_bar.dart`**

```dart
// app/lib/theme/liquid_glass/glass_tab_bar.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'glass_surface.dart';
import 'glass_tokens.dart';
import 'performance_mode.dart';

class GlassTabItem {
  const GlassTabItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class GlassTabBarController extends ChangeNotifier {
  bool _collapsed = false;
  Timer? _debounce;
  double _accumDown = 0.0;

  bool get collapsed => _collapsed;

  void handleScrollDelta(double delta) {
    if (delta < 0) {
      _debounce?.cancel();
      _accumDown = 0;
      if (_collapsed) {
        _collapsed = false;
        notifyListeners();
      }
      return;
    }
    _accumDown += delta;
    if (_accumDown < GlassTokens.tabCollapseScrollThreshold) return;
    _debounce?.cancel();
    _debounce = Timer(GlassTokens.tabCollapseDebounce, () {
      if (!_collapsed) {
        _collapsed = true;
        notifyListeners();
      }
    });
  }

  void expand() {
    if (_collapsed) {
      _collapsed = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

class GlassTabBar extends StatelessWidget {
  const GlassTabBar({
    super.key,
    required this.quality,
    required this.controller,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final GlassQuality quality;
  final GlassTabBarController controller;
  final List<GlassTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final collapsed = quality.hasMotion && controller.collapsed;
        return SafeArea(
          top: false,
          child: AnimatedAlign(
            duration: GlassTokens.tabCollapse,
            curve: GlassTokens.springOut,
            alignment: collapsed ? Alignment.bottomRight : Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: GlassTokens.tabCollapse,
              curve: GlassTokens.springOut,
              margin: EdgeInsets.only(
                left: collapsed ? 0 : 16,
                right: collapsed ? 16 : 16,
                bottom: collapsed ? 24 : 16,
              ),
              child: GlassSurface(
                quality: quality,
                borderRadius: collapsed ? GlassTokens.radiusCapsule : GlassTokens.radiusBar,
                blurSigma: GlassTokens.blurSigmaThick,
                child: collapsed
                    ? _CollapsedCapsule(item: items[currentIndex], onTap: controller.expand)
                    : _ExpandedRow(items: items, currentIndex: currentIndex, onTap: onTap),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ExpandedRow extends StatelessWidget {
  const _ExpandedRow({required this.items, required this.currentIndex, required this.onTap});
  final List<GlassTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < items.length; i++)
            InkResponse(
              onTap: () => onTap(i),
              radius: 36,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(items[i].icon,
                        color: i == currentIndex ? Theme.of(context).colorScheme.primary : null),
                    const SizedBox(height: 2),
                    Text(items[i].label,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: i == currentIndex ? Theme.of(context).colorScheme.primary : null,
                        )),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CollapsedCapsule extends StatelessWidget {
  const _CollapsedCapsule({required this.item, required this.onTap});
  final GlassTabItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 32,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Icon(item.icon, size: 24, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
```

- [ ] **Step 6.4: Run test, expect PASS**

```bash
flutter test test/theme/liquid_glass/glass_tab_bar_test.dart
```

- [ ] **Step 6.5: Commit**

```bash
git add app/lib/theme/liquid_glass/glass_tab_bar.dart app/test/theme/liquid_glass/glass_tab_bar_test.dart
git commit -m "feat(theme): add GlassTabBar with collapse-to-capsule behavior"
```

---

## Task 7: Glass Menu / Sheet / Chip — Secondary Surfaces

**Files:**
- Create: `app/lib/theme/liquid_glass/glass_menu.dart`
- Create: `app/lib/theme/liquid_glass/glass_sheet.dart`
- Create: `app/lib/theme/liquid_glass/glass_chip.dart`

- [ ] **Step 7.1: Implement `glass_chip.dart`**

```dart
// app/lib/theme/liquid_glass/glass_chip.dart
import 'package:flutter/material.dart';
import 'glass_surface.dart';
import 'glass_tokens.dart';
import 'performance_mode.dart';

class GlassChip extends StatelessWidget {
  const GlassChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.quality,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final GlassQuality quality;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: GlassSurface(
        quality: quality,
        borderRadius: GlassTokens.radiusButton,
        blurSigma: GlassTokens.blurSigmaThin,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        child: Stack(
          children: [
            if (selected)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(GlassTokens.radiusButton * 2.2),
                  ),
                ),
              ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: selected ? scheme.onPrimaryContainer : scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 7.2: Implement `glass_sheet.dart`**

```dart
// app/lib/theme/liquid_glass/glass_sheet.dart
import 'package:flutter/material.dart';
import 'glass_surface.dart';
import 'glass_tokens.dart';
import 'performance_mode.dart';

Future<T?> showGlassBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required GlassQuality quality,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.25),
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: GlassSurface(
        quality: quality,
        borderRadius: GlassTokens.radiusSheet,
        blurSigma: GlassTokens.blurSigmaThick,
        padding: const EdgeInsets.all(16),
        child: SafeArea(top: false, child: builder(ctx)),
      ),
    ),
  );
}

Future<T?> showGlassDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required GlassQuality quality,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'dismiss',
    barrierColor: Colors.black.withValues(alpha: 0.25),
    pageBuilder: (ctx, _, __) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: GlassSurface(
          quality: quality,
          borderRadius: GlassTokens.radiusSheet,
          blurSigma: GlassTokens.blurSigmaUltra,
          padding: const EdgeInsets.all(20),
          child: builder(ctx),
        ),
      ),
    ),
  );
}
```

- [ ] **Step 7.3: Implement `glass_menu.dart`**

```dart
// app/lib/theme/liquid_glass/glass_menu.dart
import 'package:flutter/material.dart';
import 'glass_surface.dart';
import 'glass_tokens.dart';
import 'performance_mode.dart';

class GlassPopupMenuItem<T> {
  const GlassPopupMenuItem({required this.value, required this.label, this.icon});
  final T value;
  final String label;
  final IconData? icon;
}

Future<T?> showGlassPopupMenu<T>({
  required BuildContext context,
  required Offset position,
  required List<GlassPopupMenuItem<T>> items,
  required GlassQuality quality,
}) async {
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  final rect = RelativeRect.fromRect(
    Rect.fromPoints(position, position),
    Offset.zero & overlay.size,
  );

  return showMenu<T>(
    context: context,
    position: rect,
    color: Colors.transparent,
    elevation: 0,
    shape: ContinuousRectangleBorder(
      borderRadius: BorderRadius.circular(GlassTokens.radiusMenu * 2.2),
    ),
    items: [
      PopupMenuItem<T>(
        padding: EdgeInsets.zero,
        enabled: false,
        child: GlassSurface(
          quality: quality,
          borderRadius: GlassTokens.radiusMenu,
          blurSigma: GlassTokens.blurSigmaThick,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final item in items)
                InkWell(
                  onTap: () => Navigator.of(context).pop(item.value),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        if (item.icon != null) ...[
                          Icon(item.icon, size: 18),
                          const SizedBox(width: 12),
                        ],
                        Text(item.label),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ],
  );
}
```

- [ ] **Step 7.4: Smoke-compile**

```bash
cd app && flutter analyze lib/theme/liquid_glass/
```
Expected: no errors.

- [ ] **Step 7.5: Commit**

```bash
git add app/lib/theme/liquid_glass/glass_chip.dart \
        app/lib/theme/liquid_glass/glass_sheet.dart \
        app/lib/theme/liquid_glass/glass_menu.dart
git commit -m "feat(theme): add glass chip, sheet, and popup menu"
```

---

## Task 8: Typography — Platform-Aware Fonts

**Files:**
- Modify: `app/lib/theme/typography.dart`

- [ ] **Step 8.1: Read the current file**

```bash
cat app/lib/theme/typography.dart
```

- [ ] **Step 8.2: Add platform font fallback**

Modify the file so each `TextStyle` uses `fontFamily` resolved from a single helper:

```dart
// app/lib/theme/typography.dart (top of file, after imports)
import 'dart:io' show Platform;

String? _systemFontFamily() {
  if (Platform.isIOS || Platform.isMacOS) return '.SF Pro Text';
  if (Platform.isAndroid) return 'Roboto Flex';
  if (Platform.isWindows) return 'Segoe UI Variable';
  return null;
}

// Then in every TextStyle construction, set:
//   fontFamily: _systemFontFamily(),
```

For every existing `TextStyle(...)` constructor in the file, add `fontFamily: _systemFontFamily(),`.

- [ ] **Step 8.3: Compile check**

```bash
cd app && flutter analyze lib/theme/typography.dart
```

- [ ] **Step 8.4: Commit**

```bash
git add app/lib/theme/typography.dart
git commit -m "feat(theme): platform-aware system font (SF Pro / Roboto Flex / Segoe UI)"
```

---

## Task 9: Settings Override UI

**Files:**
- Modify: `app/lib/page/home/settings/` — locate "阅读体验" group and add a new tile

- [ ] **Step 9.1: Find the right file**

```bash
grep -rn "阅读体验\|reading_experience\|ReadingExperience" app/lib/page/home/settings/
```

- [ ] **Step 9.2: Add the "视觉质量" tile**

Inside the located "阅读体验" group widget, add:

```dart
// inside the group's children list
Consumer(builder: (context, ref, _) {
  final qualityAsync = ref.watch(glassQualityControllerProvider);
  final notifier = ref.read(glassQualityControllerProvider.notifier);
  return ListTile(
    title: const Text('视觉质量'),
    subtitle: const Text('在阅读页会自动降低一档以保证翻页流畅。'),
    trailing: qualityAsync.when(
      data: (q) => DropdownButton<GlassQualityOverride>(
        value: GlassQualityOverride.auto, // TODO read stored value
        items: GlassQualityOverride.values
            .map((o) => DropdownMenuItem(value: o, child: Text(_label(o))))
            .toList(),
        onChanged: (o) {
          if (o != null) notifier.setOverride(o);
        },
      ),
      loading: () => const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
      error: (_, __) => const Text('—'),
    ),
  );
}),
```

Add helper at file bottom:
```dart
String _label(GlassQualityOverride o) => switch (o) {
  GlassQualityOverride.auto   => '自动（推荐）',
  GlassQualityOverride.high   => '完整玻璃',
  GlassQualityOverride.medium => '平衡（关闭模糊）',
  GlassQualityOverride.low    => '省电（关闭动效）',
};
```

Required imports:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/theme/liquid_glass/performance_mode.dart';
```

> NOTE: The current stored override value is not yet exposed; for now it always shows `auto` in the dropdown. We'll wire up reading the saved value in Task 10 along with the rest of the override plumbing.

- [ ] **Step 9.3: Manual smoke**

```bash
cd app && flutter run -d <device-id>
```
Navigate Settings > 阅读体验 > 视觉质量 and select each option; verify no crash.

- [ ] **Step 9.4: Commit**

```bash
git add app/lib/page/home/settings/
git commit -m "feat(settings): expose liquid glass quality override"
```

---

## Task 10: Persist & Read Override Value

**Files:**
- Modify: `app/lib/theme/liquid_glass/performance_mode.dart`

- [ ] **Step 10.1: Add provider exposing the current override**

Append to `performance_mode.dart`:

```dart
@Riverpod(keepAlive: true)
Future<GlassQualityOverride> glassQualityOverride(Ref ref) async {
  final prefs = await SharedPreferences.getInstance();
  final name = prefs.getString(_kOverrideKey) ?? GlassQualityOverride.auto.name;
  return GlassQualityOverride.values.firstWhere(
    (e) => e.name == name,
    orElse: () => GlassQualityOverride.auto,
  );
}
```

In `GlassQualityController.setOverride`, after writing, also call:
```dart
ref.invalidate(glassQualityOverrideProvider);
```

- [ ] **Step 10.2: Run codegen + test**

```bash
cd app && dart run build_runner build --delete-conflicting-outputs
flutter test test/theme/liquid_glass/performance_mode_test.dart
```
Expected: existing tests still pass.

- [ ] **Step 10.3: Wire dropdown to the new provider** in the settings file from Task 9.

Replace the dropdown's `value:` with:
```dart
value: ref.watch(glassQualityOverrideProvider).valueOrNull ?? GlassQualityOverride.auto,
```

- [ ] **Step 10.4: Commit**

```bash
git add app/lib/theme/liquid_glass/performance_mode.dart \
        app/lib/theme/liquid_glass/performance_mode.g.dart \
        app/lib/page/home/settings/
git commit -m "feat(settings): persist and read glass quality override"
```

---

## Task 11: Migrate Bottom Nav to GlassTabBar

**Files:**
- Modify: `app/lib/page/omnigram_home.dart`

- [ ] **Step 11.1: Read existing shell**

```bash
cat app/lib/page/omnigram_home.dart
```

- [ ] **Step 11.2: Add controller field + replace BottomNavigationBar**

In the state class:

```dart
final _tabBarController = GlassTabBarController();

@override
void dispose() {
  _tabBarController.dispose();
  super.dispose();
}
```

In `build`, wrap the body in a `NotificationListener<ScrollUpdateNotification>` that forwards delta to the controller:

```dart
body: NotificationListener<ScrollUpdateNotification>(
  onNotification: (n) {
    if (n.metrics.axis == Axis.vertical) {
      _tabBarController.handleScrollDelta(n.scrollDelta ?? 0);
    }
    return false;
  },
  child: <existing body>,
),
```

Replace `bottomNavigationBar:` with:

```dart
bottomNavigationBar: Consumer(
  builder: (context, ref, _) {
    final quality = ref.watch(glassQualityControllerProvider).valueOrNull ?? GlassQuality.medium;
    return GlassTabBar(
      quality: quality,
      controller: _tabBarController,
      currentIndex: _currentIndex,
      onTap: (i) => setState(() => _currentIndex = i),
      items: const [
        GlassTabItem(icon: Icons.menu_book_outlined, label: '阅读'),
        GlassTabItem(icon: Icons.library_books_outlined, label: '书架'),
        GlassTabItem(icon: Icons.insights_outlined, label: '洞察'),
        GlassTabItem(icon: Icons.settings_outlined, label: '设置'),
      ],
    );
  },
),
```

Required imports:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/theme/liquid_glass/glass_tab_bar.dart';
import 'package:omnigram/theme/liquid_glass/performance_mode.dart';
```

- [ ] **Step 11.3: Wrap MaterialApp** (in app entry, e.g. `lib/main.dart`) **with ProviderScope if not already present**

```bash
grep -n "ProviderScope" app/lib/main.dart
```
If missing, wrap `runApp(...)` in `runApp(ProviderScope(child: ...))`.

- [ ] **Step 11.4: Manual smoke + commit**

```bash
cd app && flutter run
# verify: 4 tabs glass, scroll a long list, tab bar collapses to capsule bottom-right
git add app/lib/page/omnigram_home.dart app/lib/main.dart
git commit -m "feat(shell): replace bottom nav with GlassTabBar (with collapse)"
```

---

## Task 12: Migrate Page AppBars to GlassAppBar

**Files:**
- Modify: each of Desk / Library / Insights / Settings root page

- [ ] **Step 12.1: Find each AppBar usage**

```bash
grep -rln "AppBar(" app/lib/page/home/desk/ app/lib/page/home/library/ app/lib/page/home/insights/ app/lib/page/home/settings/
```

- [ ] **Step 12.2: For each page, convert its `Scaffold` body to use `CustomScrollView`** with `GlassAppBar` as the first sliver. Existing content becomes a `SliverToBoxAdapter` or `SliverList`.

Generic shape:

```dart
Scaffold(
  extendBodyBehindAppBar: true,
  body: CustomScrollView(
    slivers: [
      GlassAppBar(
        quality: ref.watch(glassQualityControllerProvider).valueOrNull ?? GlassQuality.medium,
        title: const Text('阅读'),
        actions: [/* existing actions */],
      ),
      SliverToBoxAdapter(child: <existing-body-content>),
    ],
  ),
)
```

- [ ] **Step 12.3: Visual smoke per page**

Run app, navigate to each tab, scroll down, verify the AppBar fades in tint.

- [ ] **Step 12.4: Commit**

```bash
git add app/lib/page/home/
git commit -m "feat(pages): use GlassAppBar with scroll-edge fade in all 4 tabs"
```

---

## Task 13: Migrate Library Filter Chips → GlassChip

**Files:**
- Modify: the filter chip row file in `app/lib/page/home/library/` or `app/lib/widgets/library/`

- [ ] **Step 13.1: Locate filter chip widget**

```bash
grep -rln "FilterChip\|ChoiceChip" app/lib/page/home/library/ app/lib/widgets/library/
```

- [ ] **Step 13.2: Replace each `FilterChip` / `ChoiceChip` with `GlassChip`**

```dart
GlassChip(
  label: <existing label>,
  selected: <existing selected bool>,
  onTap: <existing onSelected callback>,
  quality: ref.watch(glassQualityControllerProvider).valueOrNull ?? GlassQuality.medium,
)
```

Required imports:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/theme/liquid_glass/glass_chip.dart';
import 'package:omnigram/theme/liquid_glass/performance_mode.dart';
```

- [ ] **Step 13.3: Visual smoke + commit**

```bash
git add app/lib/page/home/library/ app/lib/widgets/library/
git commit -m "feat(library): glass filter chips with morph-style selection"
```

---

## Task 14: Wrap Settings Grouped Lists in GlassSurface

**Files:**
- Modify: section container widgets in `app/lib/page/home/settings/`

- [ ] **Step 14.1: Identify the section container**

```bash
grep -rn "Card(\|section\|GroupedSection" app/lib/page/home/settings/
```

- [ ] **Step 14.2: Wrap each group's `Column` of `ListTile`s in `GlassSurface`**

```dart
GlassSurface(
  quality: ref.watch(glassQualityControllerProvider).valueOrNull ?? GlassQuality.medium,
  borderRadius: GlassTokens.radiusBar,
  blurSigma: GlassTokens.blurSigmaThick,
  padding: const EdgeInsets.symmetric(vertical: 4),
  child: Column(children: <existing-list-tiles>),
)
```

Required imports:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/theme/liquid_glass/glass_surface.dart';
import 'package:omnigram/theme/liquid_glass/glass_tokens.dart';
import 'package:omnigram/theme/liquid_glass/performance_mode.dart';
```

- [ ] **Step 14.3: Page background tweak** — set Settings page Scaffold backgroundColor to a slightly tinted neutral so groups visibly float (e.g. `Theme.of(context).colorScheme.surfaceContainerLowest`).

- [ ] **Step 14.4: Visual smoke + commit**

```bash
git add app/lib/page/home/settings/
git commit -m "feat(settings): glass grouped sections (iOS 26 style)"
```

---

## Task 15: Update Button Variants — `glass` style

**Files:**
- Modify: `app/lib/widgets/common/anx_button.dart`
- Modify: `app/lib/widgets/common/anx_dropdown_button.dart`
- Modify: `app/lib/widgets/common/anx_segmented_button.dart`

- [ ] **Step 15.1: For `anx_button.dart`**

Add to the existing enum (or create one if missing):
```dart
enum AnxButtonStyle { filled, outlined, glass }
```

In the build method, branch on `style`:
```dart
if (style == AnxButtonStyle.glass) {
  return GlassButton(
    quality: <existing-quality-from-ref-or-default>,
    onPressed: onPressed,
    child: child,
  );
}
// existing implementation continues
```

> NOTE: `AnxButton` is currently a `StatelessWidget`; if it doesn't have access to a Riverpod ref, accept `quality` as an optional parameter:
> ```dart
> final GlassQuality quality;
> ```
> Default it to `GlassQuality.medium` so non-glass usage is unaffected.

- [ ] **Step 15.2: Same pattern for `anx_dropdown_button.dart`** — when `style == glass`, render the trigger with `GlassButton` and use `showGlassPopupMenu` for the dropdown.

- [ ] **Step 15.3: Same pattern for `anx_segmented_button.dart`** — when glass, wrap each segment in a `GlassSurface` with `borderRadius: GlassTokens.radiusButton`, selected segment gets primary-tinted overlay (same trick as `GlassChip`).

- [ ] **Step 15.4: Commit**

```bash
git add app/lib/widgets/common/
git commit -m "feat(common): add glass variant to button/dropdown/segmented button"
```

---

## Task 16: Reader Toolbars — Glass + Auto Step-down

**Files:**
- Modify: Reader top/bottom toolbar widgets and TOC drawer

- [ ] **Step 16.1: Locate Reader chrome**

```bash
grep -rln "class.*ReaderToolbar\|class.*ReaderBottomBar\|class.*ChapterDrawer\|class.*TocDrawer" app/lib/page/reader/ app/lib/widgets/reader/
```

- [ ] **Step 16.2: Replace toolbar containers with `GlassSurface`**, sourcing quality from `readerGlassQualityProvider`:

```dart
final quality = ref.watch(readerGlassQualityProvider);
return GlassSurface(
  quality: quality,
  borderRadius: GlassTokens.radiusBar,
  blurSigma: GlassTokens.blurSigmaThick,
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
  child: <existing toolbar row>,
);
```

Replace buttons inside with `GlassButton(quality: quality, ...)` from Task 4.

- [ ] **Step 16.3: TOC drawer** — wrap drawer content in `GlassSurface(quality: quality, borderRadius: GlassTokens.radiusSheet)`. Make the drawer scaffold backgroundColor `Colors.transparent`.

- [ ] **Step 16.4: Hide chrome → dispose glass**

In the existing "chrome visible" toggle state, render toolbars only when visible (so when hidden, no `BackdropFilter` exists in tree). This matches spec §5.6.

- [ ] **Step 16.5: Tab bar hide in Reader**

In Reader page state, on enter set a flag on the shell to hide the bottom tab bar entirely (not collapse). Implementation: expose a `Provider<bool>` like `hideShellTabBarProvider`; in `omnigram_home.dart` use:
```dart
bottomNavigationBar: ref.watch(hideShellTabBarProvider) ? null : <GlassTabBar from Task 11>,
```
Set it true on Reader push, false on pop.

- [ ] **Step 16.6: Manual perf check (foreground tests; not automated)**

Open a long EPUB on the lowest-tier Android device available; verify scroll is smooth and Reader quality reports `low` or `medium` in debug.

- [ ] **Step 16.7: Commit**

```bash
git add app/lib/page/reader/ app/lib/widgets/reader/ app/lib/page/omnigram_home.dart
git commit -m "feat(reader): glass toolbars with auto step-down + shell tab bar hide"
```

---

## Task 17: Dialog / BottomSheet / SnackBar / PopupMenu — Global Theme

**Files:**
- Modify: `app/lib/theme/omnigram_theme.dart`

- [ ] **Step 17.1: Add glass theme to both `light()` and `dark()`**

Inside both, in `subThemesData`, set:
```dart
dialogBackgroundSchemeColor: SchemeColor.transparent,
bottomSheetBackgroundColor: SchemeColor.transparent,
popupMenuOpacity: 0.0,
```

Then after the ThemeData is built, use `copyWith` to override:
```dart
.copyWith(
  dialogTheme: const DialogTheme(backgroundColor: Colors.transparent, elevation: 0),
  bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.transparent, elevation: 0),
  snackBarTheme: const SnackBarThemeData(backgroundColor: Colors.transparent, elevation: 0),
  popupMenuTheme: const PopupMenuThemeData(color: Colors.transparent, elevation: 0),
)
```

This makes call sites use the global `Material*Theme` consistently; per-call-site widgets must now provide their own glass wrapping (Task 7 helpers).

- [ ] **Step 17.2: Search for and convert existing `showModalBottomSheet`/`showDialog` call sites** to `showGlassBottomSheet`/`showGlassDialog`:

```bash
grep -rn "showModalBottomSheet\|showDialog(" app/lib/page/ app/lib/widgets/
```

For each call site, replace with the glass helper from Task 7, passing `quality: ref.watch(glassQualityControllerProvider).valueOrNull ?? GlassQuality.medium`.

- [ ] **Step 17.3: Compile + commit**

```bash
cd app && flutter analyze lib/
git add app/lib/theme/omnigram_theme.dart app/lib/page/ app/lib/widgets/
git commit -m "feat(theme): transparent global modals + glass wrappers"
```

---

## Task 18: Cross-Device Verification (Manual)

Not automated. Run through the §9 acceptance checklist from the spec on real hardware.

- [ ] **Step 18.1: iOS device** — visual + perf + dark/light + side-by-side with iOS 26 Settings
- [ ] **Step 18.2: macOS** — same
- [ ] **Step 18.3: Android high-end (RAM ≥ 6GB, API ≥ 31)** — confirm auto-detect = `high`
- [ ] **Step 18.4: Android mid (RAM 4–6GB)** — confirm `medium`, no BackdropFilter visible
- [ ] **Step 18.5: Android low (RAM < 4GB or API < 31)** — confirm `low`, plain solids
- [ ] **Step 18.6: Reader smooth-scroll** on all three Android tiers — 60fps in DevTools Performance overlay
- [ ] **Step 18.7: Accessibility** — toggle "Reduce Transparency" / "Increase Contrast" system settings, confirm app respects them (Note: this auto-respect is wired via `MediaQuery.disableAnimations` and `MediaQuery.highContrast` — add a follow-up task if not yet wired during Step 18.7 testing)

---

## Task 19: Update Project Docs

**Files:**
- Modify: `docs/superpowers/PROGRESS.md`
- Modify: `CLAUDE.md`

- [ ] **Step 19.1: PROGRESS.md** — add a "Liquid Glass UI" row under appropriate Layer/Sprint, status ✅, link to spec + this plan, key files `app/lib/theme/liquid_glass/`, commit hash from Task 17.

- [ ] **Step 19.2: CLAUDE.md** — in "App Design Principles", insert as new bullet between current 3 and 4:

```markdown
4. **Chrome uses Liquid Glass, content uses warm cards** — see `docs/superpowers/specs/2026-05-18-liquid-glass-ui-design.md`. Use `GlassSurface`/`GlassButton`/`GlassChip`/`GlassAppBar`/`GlassTabBar` for navigation, buttons, menus, settings groups, and reader toolbars. Use `OmnigramCard` and `FlexColorScheme` cards for content surfaces. Reader auto-degrades one quality tier.
```

Renumber subsequent bullets.

- [ ] **Step 19.3: Commit**

```bash
git add docs/superpowers/PROGRESS.md CLAUDE.md
git commit -m "docs: record liquid glass UI implementation"
```

---

## Done

After Task 19, the implementation is complete. The branch is ready for manual cross-device QA (Task 18) and then merging to main.
