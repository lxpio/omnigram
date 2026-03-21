import 'dart:async';

import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/service/ai/tools/ai_tool_registry.dart';
import 'package:omnigram/service/ai/tools/input/notes_search_input.dart';
import 'package:omnigram/service/ai/tools/repository/notes_repository.dart';

import 'base_tool.dart';

class NotesSearchTool
    extends RepositoryTool<NotesSearchInput, Map<String, dynamic>> {
  NotesSearchTool(this._repository)
      : super(
          name: 'notes_search',
          description:
              'Search through the user\'s saved notes. Use this to surface annotations relevant to the current discussion by keyword, book, or time range. Returns matching note entries with chapter context, highlights, and timestamps.',
          inputJsonSchema: const {
            'type': 'object',
            'properties': {
              'keyword': {
                'type': 'string',
                'description':
                    'Optional. Text to match in note body content or chapter titles.',
              },
              'book_id': {
                'type': 'integer',
                'description':
                    'Optional. Restrict the search to notes belonging to a specific book ID.',
              },
              'from': {
                'type': 'string',
                'description':
                    'Optional. ISO-8601 timestamp; only notes updated at or after this moment are returned.',
              },
              'to': {
                'type': 'string',
                'description':
                    'Optional. ISO-8601 timestamp; only notes updated at or before this moment are returned.',
              },
              'limit': {
                'type': 'integer',
                'description':
                    'Optional. Maximum number of results to return (range 1-50).',
              },
            },
            // 'required': const <String>[],
          },
          timeout: const Duration(seconds: 4),
        );

  final NotesRepository _repository;

  @override
  NotesSearchInput parseInput(Map<String, dynamic> json) {
    return NotesSearchInput.fromJson(json);
  }

  @override
  Future<Map<String, dynamic>> run(NotesSearchInput input) async {
    final results = await _repository.searchNotes(
      keyword: input.keyword,
      bookId: input.bookId,
      from: input.from,
      to: input.to,
      limit: input.resolvedLimit(),
    );

    return {
      'keyword': input.keyword,
      'bookId': input.bookId,
      'from': input.from?.toIso8601String(),
      'to': input.to?.toIso8601String(),
      'results': results.map((entry) => entry.toMap()).toList(),
    };
  }

  @override
  bool shouldLogError(Object error) {
    return error is! TimeoutException;
  }
}

final AiToolDefinition notesSearchToolDefinition = AiToolDefinition(
  id: 'notes_search',
  displayNameBuilder: (L10n l10n) => l10n.aiToolNotesSearchName,
  descriptionBuilder: (L10n l10n) => l10n.aiToolNotesSearchDescription,
  build: (context) => NotesSearchTool(context.notesRepository).tool,
);
