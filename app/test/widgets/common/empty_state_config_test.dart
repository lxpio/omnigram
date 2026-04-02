import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/models/empty_state_data.dart';
import 'package:omnigram/models/warmth_tier.dart';
import 'package:omnigram/widgets/common/empty_state_config.dart';
import 'package:omnigram/l10n/generated/L10n.dart';

void main() {
  for (final page in EmptyPageType.values) {
    for (final tier in WarmthTier.values) {
      testWidgets('$page × $tier returns valid EmptyStateData', (tester) async {
        late EmptyStateData data;
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: L10n.localizationsDelegates,
            supportedLocales: L10n.supportedLocales,
            locale: const Locale('en'),
            home: Builder(builder: (context) {
              data = EmptyStateConfig.forPage(page, tier, L10n.of(context));
              return const SizedBox();
            }),
          ),
        );
        await tester.pumpAndSettle();

        expect(data.message, isNotEmpty);
        expect(data.visualType, isNotNull);
      });
    }
  }

  testWidgets('high tier uses Lottie visual', (tester) async {
    late EmptyStateData data;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        locale: const Locale('en'),
        home: Builder(builder: (context) {
          data = EmptyStateConfig.forPage(EmptyPageType.desk, WarmthTier.high, L10n.of(context));
          return const SizedBox();
        }),
      ),
    );
    await tester.pumpAndSettle();
    expect(data.visualType, isA<EmptyVisualLottie>());
  });

  testWidgets('mid tier uses SVG visual', (tester) async {
    late EmptyStateData data;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        locale: const Locale('en'),
        home: Builder(builder: (context) {
          data = EmptyStateConfig.forPage(EmptyPageType.desk, WarmthTier.mid, L10n.of(context));
          return const SizedBox();
        }),
      ),
    );
    await tester.pumpAndSettle();
    expect(data.visualType, isA<EmptyVisualSvg>());
  });

  testWidgets('low tier uses Icon visual', (tester) async {
    late EmptyStateData data;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        locale: const Locale('en'),
        home: Builder(builder: (context) {
          data = EmptyStateConfig.forPage(EmptyPageType.desk, WarmthTier.low, L10n.of(context));
          return const SizedBox();
        }),
      ),
    );
    await tester.pumpAndSettle();
    expect(data.visualType, isA<EmptyVisualIcon>());
  });

  testWidgets('desk and library have actionLabel, insights and companion do not', (tester) async {
    late EmptyStateData desk, library, insights, companion;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        locale: const Locale('en'),
        home: Builder(builder: (context) {
          final l10n = L10n.of(context);
          desk = EmptyStateConfig.forPage(EmptyPageType.desk, WarmthTier.mid, l10n);
          library = EmptyStateConfig.forPage(EmptyPageType.library, WarmthTier.mid, l10n);
          insights = EmptyStateConfig.forPage(EmptyPageType.insights, WarmthTier.mid, l10n);
          companion = EmptyStateConfig.forPage(EmptyPageType.companion, WarmthTier.mid, l10n);
          return const SizedBox();
        }),
      ),
    );
    await tester.pumpAndSettle();
    expect(desk.actionLabel, isNotNull);
    expect(library.actionLabel, isNotNull);
    expect(insights.actionLabel, isNull);
    expect(companion.actionLabel, isNull);
  });
}
