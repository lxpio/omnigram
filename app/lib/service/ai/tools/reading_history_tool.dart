import 'dart:async';

import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/service/ai/tools/ai_tool_registry.dart';
import 'package:omnigram/service/ai/tools/input/reading_history_input.dart';
import 'package:omnigram/service/ai/tools/repository/reading_history_repository.dart';
import 'package:omnigram/utils/date/convert_seconds.dart';

import 'base_tool.dart';

class ReadingHistoryTool
    extends RepositoryTool<ReadingHistoryInput, Map<String, dynamic>> {
  ReadingHistoryTool(this._repository)
      : super(
          name: 'reading_history',
          description:
              'Retrieve historical reading sessions recorded by the app. Use this to analyse habits or reference when the user last read a book. Supports optional filters for book, date range, and record count. Returns the filtered entries plus totals for duration and count.',
          inputJsonSchema: const {
            'type': 'object',
            'properties': {
              'book_id': {
                'type': 'integer',
                'description':
                    'Optional. Only include history for the specified book ID.',
              },
              'from': {
                'type': 'string',
                'description':
                    'Optional. ISO-8601 date or timestamp marking the earliest entry to include.',
              },
              'to': {
                'type': 'string',
                'description':
                    'Optional. ISO-8601 date or timestamp marking the latest entry to include.',
              },
              'limit': {
                'type': 'integer',
                'description':
                    'Optional. Upper bound on the number of records to return (range 1-100).',
              },
            },
          },
          timeout: const Duration(seconds: 4),
        );

  final ReadingHistoryRepository _repository;

  @override
  ReadingHistoryInput parseInput(Map<String, dynamic> json) {
    return ReadingHistoryInput.fromJson(json);
  }

  @override
  Future<Map<String, dynamic>> run(ReadingHistoryInput input) async {
    final records = await _repository.fetchHistory(
      bookId: input.bookId,
      from: input.from,
      to: input.to,
      limit: input.resolvedLimit(),
    );

    final totalSeconds =
        records.fold<int>(0, (sum, item) => sum + item.entry.readingTime);

    return {
      'bookId': input.bookId,
      'from': input.from?.toIso8601String(),
      'to': input.to?.toIso8601String(),
      'totalEntries': records.length,
      'totalReadingDuration': convertSeconds(totalSeconds),
      'records': records.map((record) => record.toMap()).toList(),
    };
  }

  @override
  bool shouldLogError(Object error) {
    return error is! TimeoutException;
  }
}

final AiToolDefinition readingHistoryToolDefinition = AiToolDefinition(
  id: 'reading_history',
  displayNameBuilder: (L10n l10n) => l10n.aiToolReadingHistoryName,
  descriptionBuilder: (L10n l10n) => l10n.aiToolReadingHistoryDescription,
  build: (context) => ReadingHistoryTool(context.readingHistoryRepository).tool,
);
