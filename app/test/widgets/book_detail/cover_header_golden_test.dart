import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/widgets/book_detail/cover_header.dart';
import '../../helpers/golden_test_helper.dart';

void main() {
  group('CoverHeader Golden', () {
    testWidgets('renders correctly with progress', (tester) async {
      await tester.pumpWidget(goldenTestApp(
        CoverHeader(
          title: 'The Art of Thinking Clearly',
          author: 'Rolf Dobelli',
          progress: 0.65,
          coverWidget: Container(
            width: 120,
            height: 170,
            color: Colors.blueGrey,
            child: const Center(child: Icon(Icons.book, size: 40, color: Colors.white)),
          ),
          dominantColor: Colors.blueGrey,
        ),
        size: const Size(400, 350),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(CoverHeader),
        matchesGoldenFile('goldens/cover_header_with_progress.png'),
      );
    });
  });
}
