import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/widgets/insights/cross_book_card.dart';
import '../../helpers/golden_test_helper.dart';

void main() {
  group('CrossBookCard Golden', () {
    testWidgets('renders discovery card', (tester) async {
      await tester.pumpWidget(goldenTestApp(
        CrossBookCard(
          discovery: const CrossBookDiscovery(
            edgeId: 1,
            sourceBookTitle: 'Thinking, Fast and Slow',
            targetBookTitle: 'Predictably Irrational',
            sourceConcept: 'cognitive bias',
            targetConcept: 'decision heuristics',
            reason: 'Both explore how systematic errors affect human judgment',
            weight: 0.8,
          ),
          onRecordThought: () {},
        ),
        size: const Size(400, 280),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(CrossBookCard),
        matchesGoldenFile('goldens/cross_book_card.png'),
      );
    });
  });
}
