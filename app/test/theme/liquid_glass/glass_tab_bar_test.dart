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
    addTearDown(c.dispose);
  });

  testWidgets('scrolling down past threshold collapses', (tester) async {
    final c = GlassTabBarController();
    await tester.pumpWidget(host(c));
    addTearDown(c.dispose);

    c.handleScrollDelta(GlassTokens.tabCollapseScrollThreshold + 1);
    await tester.pump(GlassTokens.tabCollapseDebounce);
    await tester.pumpAndSettle();
    expect(c.collapsed, isTrue);
  });

  testWidgets('scrolling up expands immediately', (tester) async {
    final c = GlassTabBarController();
    await tester.pumpWidget(host(c));
    addTearDown(c.dispose);

    c.handleScrollDelta(GlassTokens.tabCollapseScrollThreshold + 1);
    await tester.pump(GlassTokens.tabCollapseDebounce);
    expect(c.collapsed, isTrue);

    c.handleScrollDelta(-10);
    await tester.pump();
    expect(c.collapsed, isFalse);
  });

  testWidgets('small scroll deltas accumulate but stay below threshold', (tester) async {
    final c = GlassTabBarController();
    await tester.pumpWidget(host(c));
    addTearDown(c.dispose);

    c.handleScrollDelta(10);
    c.handleScrollDelta(10);
    await tester.pump(GlassTokens.tabCollapseDebounce);
    expect(c.collapsed, isFalse);
  });
}
