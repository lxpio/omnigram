import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/models/empty_state_data.dart';
import 'package:omnigram/widgets/common/empty_state.dart';
import '../../helpers/golden_test_helper.dart';

void main() {
  group('EmptyState Golden', () {
    testWidgets('renders icon variant', (tester) async {
      await tester.pumpWidget(goldenTestApp(
        EmptyState.fromData(EmptyStateData(
          message: 'No books yet. Import your first book to start reading.',
          actionLabel: 'Import Books',
          visualType: EmptyVisualIcon(Icons.library_books),
        )),
        size: const Size(400, 400),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(EmptyState),
        matchesGoldenFile('goldens/empty_state_icon.png'),
      );
    });
  });
}
