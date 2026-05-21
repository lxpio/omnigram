// app/test/widgets/reader/reader_bottom_bar_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/widgets/reader/reader_bottom_bar.dart';

void main() {
  Widget buildBar({
    double progress = 0.68,
    int currentPage = 142,
    int totalPages = 208,
  }) {
    return ProviderScope(
        child: MaterialApp(
      home: Scaffold(
        body: ReaderBottomBar(
          progress: progress,
          currentPage: currentPage,
          totalPages: totalPages,
          onSeek: (_) {},
          onShowToc: () {},
          onShowNotes: () {},
          onShowProgress: () {},
          onShowStyle: () {},
          onShowTts: () {},
        ),
      ),
    ));
  }

  group('ReaderBottomBar', () {
    testWidgets('displays percentage text', (tester) async {
      await tester.pumpWidget(buildBar(progress: 0.68));
      expect(find.text('68%'), findsOneWidget);
    });

    testWidgets('displays page indicator', (tester) async {
      await tester.pumpWidget(buildBar(currentPage: 142, totalPages: 208));
      expect(find.text('142 / 208'), findsOneWidget);
    });

    testWidgets('displays 0% for zero progress', (tester) async {
      await tester.pumpWidget(buildBar(progress: 0.0));
      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('displays 100% for full progress', (tester) async {
      await tester.pumpWidget(buildBar(progress: 1.0));
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('renders 5 action icons', (tester) async {
      await tester.pumpWidget(buildBar());
      // Bar uses lightweight ripple-free icons (not IconButton) since the
      // iOS 26 floating chrome rewrite. Assert by the actual icon set.
      expect(find.byIcon(Icons.list_outlined), findsOneWidget);
      expect(find.byIcon(Icons.edit_note_outlined), findsOneWidget);
      expect(find.byIcon(Icons.data_usage_outlined), findsOneWidget);
      expect(find.byIcon(Icons.palette_outlined), findsOneWidget);
      expect(find.byIcon(Icons.headphones_outlined), findsOneWidget);
    });

    testWidgets('calls onShowToc when toc button pressed', (tester) async {
      bool called = false;
      await tester.pumpWidget(ProviderScope(
          child: MaterialApp(
        home: Scaffold(
          body: ReaderBottomBar(
            progress: 0.5,
            currentPage: 1,
            totalPages: 10,
            onSeek: (_) {},
            onShowToc: () => called = true,
            onShowNotes: () {},
            onShowProgress: () {},
            onShowStyle: () {},
            onShowTts: () {},
          ),
        ),
      )));
      await tester.tap(find.byIcon(Icons.list_outlined));
      expect(called, true);
    });
  });
}
