// app/test/widgets/reader/reader_app_bar_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/widgets/reader/reader_app_bar.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(home: Scaffold(body: child)),
    );

void main() {
  group('ReaderAppBar', () {
    testWidgets('displays chapter title', (tester) async {
      await tester.pumpWidget(_wrap(ReaderAppBar(
        chapterTitle: 'Chapter 3: The Beginning',
        isBookmarked: false,
        onBack: () {},
        onToggleBookmark: () {},
        onShowCompanion: () {},
        onShowMenu: () {},
      )));
      expect(find.text('Chapter 3: The Beginning'), findsOneWidget);
    });

    testWidgets('shows filled bookmark icon when bookmarked', (tester) async {
      await tester.pumpWidget(_wrap(ReaderAppBar(
        chapterTitle: 'Test',
        isBookmarked: true,
        onBack: () {},
        onToggleBookmark: () {},
        onShowCompanion: () {},
        onShowMenu: () {},
      )));
      expect(find.byIcon(Icons.bookmark), findsOneWidget);
    });

    testWidgets('shows outline bookmark icon when not bookmarked',
        (tester) async {
      await tester.pumpWidget(_wrap(ReaderAppBar(
        chapterTitle: 'Test',
        isBookmarked: false,
        onBack: () {},
        onToggleBookmark: () {},
        onShowCompanion: () {},
        onShowMenu: () {},
      )));
      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
    });

    testWidgets('calls onBack when back button pressed', (tester) async {
      bool called = false;
      await tester.pumpWidget(_wrap(ReaderAppBar(
        chapterTitle: 'Test',
        isBookmarked: false,
        onBack: () => called = true,
        onToggleBookmark: () {},
        onShowCompanion: () {},
        onShowMenu: () {},
      )));
      await tester.tap(find.byIcon(Icons.arrow_back));
      expect(called, true);
    });
  });
}
