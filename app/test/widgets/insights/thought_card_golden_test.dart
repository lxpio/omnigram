import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/dao/thought.dart';
import 'package:omnigram/widgets/insights/thought_card.dart';
import '../../helpers/golden_test_helper.dart';

void main() {
  group('ThoughtCard Golden', () {
    testWidgets('renders with concept tag', (tester) async {
      await tester.pumpWidget(goldenTestApp(
        ThoughtCard(
          thought: const Thought(
            id: 1,
            content: 'Both books argue that our intuitions are systematically biased, but Kahneman focuses on cognitive shortcuts while Ariely emphasizes social context.',
            conceptName: 'cognitive bias ↔ behavioral economics',
            createdAt: '2026-04-07T14:30:00Z',
          ),
        ),
        size: const Size(400, 300),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ThoughtCard),
        matchesGoldenFile('goldens/thought_card_with_concept.png'),
      );
    });

    testWidgets('renders without concept tag', (tester) async {
      await tester.pumpWidget(goldenTestApp(
        ThoughtCard(
          thought: const Thought(
            id: 2,
            content: 'I need to revisit the chapter on anchoring effects.',
            createdAt: '2026-04-07T15:00:00Z',
          ),
        ),
        size: const Size(400, 200),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ThoughtCard),
        matchesGoldenFile('goldens/thought_card_plain.png'),
      );
    });
  });
}
