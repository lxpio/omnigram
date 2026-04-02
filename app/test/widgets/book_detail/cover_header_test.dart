// app/test/widgets/book_detail/cover_header_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/widgets/book_detail/cover_header.dart';

void main() {
  group('CoverHeader', () {
    testWidgets('displays book title and author', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CoverHeader(
            title: 'Test Book',
            author: 'Test Author',
            progress: 0.48,
            coverWidget: const SizedBox(width: 120, height: 170),
            dominantColor: Colors.blue,
          ),
        ),
      ));
      expect(find.text('Test Book'), findsOneWidget);
      expect(find.text('Test Author'), findsOneWidget);
    });

    testWidgets('displays progress percentage', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CoverHeader(
            title: 'Test',
            author: 'Author',
            progress: 0.48,
            coverWidget: const SizedBox(width: 120, height: 170),
            dominantColor: Colors.blue,
          ),
        ),
      ));
      expect(find.text('48%'), findsOneWidget);
    });

    testWidgets('displays 0% for zero progress', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CoverHeader(
            title: 'Test',
            author: 'Author',
            progress: 0.0,
            coverWidget: const SizedBox(width: 120, height: 170),
            dominantColor: Colors.blue,
          ),
        ),
      ));
      expect(find.text('0%'), findsOneWidget);
    });
  });
}
