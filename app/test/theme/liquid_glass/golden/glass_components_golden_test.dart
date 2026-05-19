// Pixel-level snapshots for all liquid_glass primitives.
//
// Run/refresh baselines locally:
//   flutter test --update-goldens test/theme/liquid_glass/golden/
//
// Notes:
// - Baselines are macOS-generated (this dev box). Linux CI may diff slightly;
//   if so, tag goldens with `@Tags(['golden'])` and exclude in CI until a
//   stable Linux baseline is added.
// - Quality is pinned to `medium` for most cases (no BackdropFilter, so
//   pixel-stable). GlassSurface adds a `high` variant to lock the blurred
//   look as well — flake there means BackdropFilter regression.
//
// Background uses a soft solid color (NOT pure white) so glass tint +
// edge highlight are visible in the snapshot.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/theme/liquid_glass/glass_action_pill.dart';
import 'package:omnigram/theme/liquid_glass/glass_app_bar.dart';
import 'package:omnigram/theme/liquid_glass/glass_button.dart';
import 'package:omnigram/theme/liquid_glass/glass_chip.dart';
import 'package:omnigram/theme/liquid_glass/glass_icon_button.dart';
import 'package:omnigram/theme/liquid_glass/glass_surface.dart';
import 'package:omnigram/theme/liquid_glass/glass_tab_bar.dart';
import 'package:omnigram/theme/liquid_glass/glass_tokens.dart';
import 'package:omnigram/theme/liquid_glass/performance_mode.dart';

Widget _wrap({
  required Widget child,
  required Brightness brightness,
  Size size = const Size(360, 160),
}) {
  final bg = brightness == Brightness.light
      ? const Color(0xFFEADCF8) // soft lavender — shows light tint
      : const Color(0xFF1A1335); // deep indigo — shows dark tint
  return ProviderScope(
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: brightness, useMaterial3: true),
      home: Scaffold(
        backgroundColor: bg,
        body: Center(
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Center(child: child),
          ),
        ),
      ),
    ),
  );
}

Future<void> _golden(
  WidgetTester tester, {
  required Widget widget,
  required Brightness brightness,
  required String fileName,
  Size size = const Size(360, 160),
}) async {
  await tester.pumpWidget(_wrap(child: widget, brightness: brightness, size: size));
  await tester.pumpAndSettle();
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$fileName.png'),
  );
}

void main() {
  group('GlassSurface', () {
    for (final brightness in Brightness.values) {
      for (final q in [GlassQuality.high, GlassQuality.medium]) {
        testWidgets('${brightness.name} / ${q.name}', (t) async {
          await _golden(
            t,
            brightness: brightness,
            fileName: 'glass_surface_${brightness.name}_${q.name}',
            widget: GlassSurface(
              quality: q,
              borderRadius: GlassTokens.radiusBar,
              blurSigma: GlassTokens.blurSigmaThick,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              child: const Text('Glass', style: TextStyle(fontSize: 20)),
            ),
          );
        });
      }
    }
  });

  group('GlassButton', () {
    for (final brightness in Brightness.values) {
      testWidgets(brightness.name, (t) async {
        await _golden(
          t,
          brightness: brightness,
          fileName: 'glass_button_${brightness.name}',
          widget: GlassButton(
            quality: GlassQuality.medium,
            onPressed: () {},
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text('Continue'),
            ),
          ),
        );
      });
    }
  });

  group('GlassIconButton', () {
    for (final brightness in Brightness.values) {
      testWidgets(brightness.name, (t) async {
        await _golden(
          t,
          brightness: brightness,
          fileName: 'glass_icon_button_${brightness.name}',
          widget: GlassIconButton(
            quality: GlassQuality.medium,
            icon: Icons.add,
            onPressed: () {},
          ),
        );
      });
    }
  });

  group('GlassActionPill', () {
    for (final brightness in Brightness.values) {
      testWidgets('${brightness.name} / plain icon-only', (t) async {
        await _golden(
          t,
          brightness: brightness,
          fileName: 'glass_action_pill_${brightness.name}_plain',
          widget: GlassActionPill(
            quality: GlassQuality.medium,
            icon: Icons.search,
            onPressed: () {},
          ),
        );
      });
      testWidgets('${brightness.name} / tinted with label', (t) async {
        await _golden(
          t,
          brightness: brightness,
          fileName: 'glass_action_pill_${brightness.name}_tinted',
          widget: GlassActionPill(
            quality: GlassQuality.medium,
            icon: Icons.play_arrow_rounded,
            label: 'Continue Reading',
            tinted: true,
            onPressed: () {},
          ),
        );
      });
    }
  });

  group('GlassAppBar', () {
    for (final brightness in Brightness.values) {
      testWidgets(brightness.name, (t) async {
        await _golden(
          t,
          brightness: brightness,
          fileName: 'glass_app_bar_${brightness.name}',
          size: const Size(360, 100),
          widget: SizedBox(
            width: 360,
            child: GlassAppBar(
              quality: GlassQuality.medium,
              title: const Text('Reading Desk'),
              actions: [
                IconButton(icon: const Icon(Icons.search), onPressed: () {}),
              ],
            ),
          ),
        );
      });
    }
  });

  group('GlassTabBar', () {
    for (final brightness in Brightness.values) {
      testWidgets('${brightness.name} expanded', (t) async {
        final ctrl = GlassTabBarController();
        addTearDown(ctrl.dispose);
        await _golden(
          t,
          brightness: brightness,
          fileName: 'glass_tab_bar_${brightness.name}',
          size: const Size(360, 120),
          widget: GlassTabBar(
            quality: GlassQuality.medium,
            controller: ctrl,
            currentIndex: 0,
            onTap: (_) {},
            items: const [
              GlassTabItem(icon: Icons.auto_stories_outlined, label: 'Read'),
              GlassTabItem(icon: Icons.library_books_outlined, label: 'Library'),
              GlassTabItem(icon: Icons.insights_outlined, label: 'Insights'),
              GlassTabItem(icon: Icons.settings_outlined, label: 'Settings'),
            ],
          ),
        );
      });
    }
  });

  group('GlassChip', () {
    for (final brightness in Brightness.values) {
      for (final selected in [false, true]) {
        testWidgets('${brightness.name} / selected=$selected', (t) async {
          await _golden(
            t,
            brightness: brightness,
            fileName:
                'glass_chip_${brightness.name}_${selected ? 'on' : 'off'}',
            widget: GlassChip(
              quality: GlassQuality.medium,
              label: 'Philosophy',
              selected: selected,
              onTap: () {},
            ),
          );
        });
      }
    }
  });
}
