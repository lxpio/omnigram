import 'dart:async';

import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/providers/current_reading.dart';
import 'package:omnigram/service/ai/tools/ai_tool_registry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'base_tool.dart';

class CurrentReadingMetadataTool
    extends RepositoryTool<JsonMap, Map<String, dynamic>> {
  CurrentReadingMetadataTool(this._ref)
      : super(
          name: 'current_reading_metadata',
          description:
              'Fetch up-to-date metadata about the active reading session. Use when you need book identifiers, progress, chapter details, or to confirm whether the user is currently reading. Returns flags for reading state plus book, progress, and chapter objects when available.',
          inputJsonSchema: const {
            'type': 'object',
            'properties': <String, dynamic>{},
          },
          timeout: const Duration(seconds: 2),
        );

  final WidgetRef _ref;

  @override
  JsonMap parseInput(Map<String, dynamic> json) {
    return json;
  }

  @override
  Future<Map<String, dynamic>> run(JsonMap input) async {
    final state = _ref.read(currentReadingProvider);
    final book = state.book;

    if (!state.isReading || book == null) {
      return {
        'isReading': false,
        'message':
            'No active reading session is detected. The user might not be reading right now.',
      };
    }

    return {
      'isReading': true,
      'book': {
        'id': book.id,
        'title': book.title,
        'author': book.author,
        'groupId': book.groupId,
        'description': book.description,
        'rating': book.rating,
        'coverPath': book.coverPath,
        'filePath': book.filePath,
        'lastReadPosition': book.lastReadPosition,
        'readingPercentage': book.readingPercentage,
        'md5': book.md5,
        'createTime': book.createTime.toIso8601String(),
        'updateTime': book.updateTime.toIso8601String(),
      },
      'progress': {
        'percentage': state.percentage,
        'cfi': state.cfi,
      },
      'chapter': {
        'title': state.chapterTitle,
        'href': state.chapterHref,
        'currentPage': state.chapterCurrentPage,
        'totalPages': state.chapterTotalPages,
      },
    };
  }
}

final AiToolDefinition currentReadingMetadataToolDefinition = AiToolDefinition(
  id: 'current_reading_metadata',
  displayNameBuilder: (L10n l10n) => l10n.aiToolCurrentReadingMetadataName,
  descriptionBuilder: (L10n l10n) =>
      l10n.aiToolCurrentReadingMetadataDescription,
  build: (context) => CurrentReadingMetadataTool(context.ref).tool,
);
