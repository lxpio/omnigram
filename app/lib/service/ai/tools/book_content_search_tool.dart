import 'dart:async';

import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/service/ai/tools/ai_tool_registry.dart';

import 'base_tool.dart';
import 'input/book_content_search_input.dart';
import 'repository/book_content_search_repository.dart';

class BookContentSearchTool
    extends RepositoryTool<BookContentSearchInput, Map<String, dynamic>> {
  BookContentSearchTool(
    this._repository,
  ) : super(
          name: 'book_content_search',
          description:
              'Locate passages inside a specific book you already know the numeric id for. Supply a keyword or phrase to retrieve chapters containing matching text along with highlighted snippets. Ideal when you need supporting quotations or to confirm context while discussing the book. Returns matched chapters with chapter metadata, snippet previews, and match counts.',
          inputJsonSchema: const {
            'type': 'object',
            'properties': {
              'bookId': {
                'type': 'integer',
                'description':
                    'Required. ID of the book to search, typically obtained from bookshelf tools.',
              },
              'keyword': {
                'type': 'string',
                'description':
                    'Required. Case-insensitive keyword or phrase to look for in the selected book.',
              },
              'maxResults': {
                'type': 'integer',
                'description':
                    'Optional. Caps how many chapter-level matches are returned (range 1-10, default set by backend).',
              },
              'maxSnippets': {
                'type': 'integer',
                'description':
                    'Optional. Max number of snippet excerpts per chapter (range 1-10). Lower this when you only need a quick preview.',
              },
              'maxCharacters': {
                'type': 'integer',
                'description':
                    'Optional. Truncates each snippet to the specified character budget (100-2000) for concise responses.',
              },
            },
            'required': ['bookId', 'keyword'],
          },
          timeout: const Duration(seconds: 20),
        );

  final BookContentSearchRepository _repository;

  @override
  BookContentSearchInput parseInput(Map<String, dynamic> json) {
    return BookContentSearchInput.fromJson(json);
  }

  @override
  Future<Map<String, dynamic>> run(BookContentSearchInput input) async {
    return _repository.search(input);
  }
}

final AiToolDefinition bookContentSearchToolDefinition = AiToolDefinition(
  id: 'book_content_search',
  displayNameBuilder: (L10n l10n) => l10n.aiToolBookContentSearchName,
  descriptionBuilder: (L10n l10n) => l10n.aiToolBookContentSearchDescription,
  build: (context) =>
      BookContentSearchTool(context.bookContentSearchRepository).tool,
);
