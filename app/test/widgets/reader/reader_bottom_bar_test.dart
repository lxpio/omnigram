// app/test/widgets/reader/reader_bottom_bar_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/widgets/reader/reader_bottom_bar.dart';

void main() {
  Widget buildBar({
    double progress = 0.68,
    int currentPage = 142,
    int totalPages = 208,
  }) {
    return MaterialApp(
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
    );
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

    testWidgets('renders 5 action buttons', (tester) async {
      await tester.pumpWidget(buildBar());
      expect(find.byType(IconButton), findsNWidgets(5));
    });

    testWidgets('calls onShowToc when toc button pressed', (tester) async {
      bool called = false;
      await tester.pumpWidget(MaterialApp(
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
      ));
      await tester.tap(find.byIcon(Icons.list_outlined));
      expect(called, true);
    });
  });
}
