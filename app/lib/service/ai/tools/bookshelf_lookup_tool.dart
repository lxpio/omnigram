import 'dart:async';

import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/service/ai/tools/ai_tool_registry.dart';
import 'package:omnigram/service/ai/tools/input/bookshelf_lookup_input.dart';
import 'package:omnigram/service/ai/tools/repository/books_repository.dart';

import 'base_tool.dart';

class BookshelfLookupTool
    extends RepositoryTool<BookshelfLookupInput, Map<String, dynamic>> {
  BookshelfLookupTool(this._repository)
      : super(
          name: 'bookshelf_lookup',
          description:
              'Find books that already exist on the user\'s local shelf based on title, author, or group membership. Use this before referencing a book in replies so you can cite real items from the library. Supports optional filters for bookshelf groups, deleted books, and result limits. Returns a structured list of matching books with identifiers, metadata, progress, and last-read timestamps.',
          inputJsonSchema: const {
            'type': 'object',
            'properties': {
              'query': {
                'type': 'string',
                'description':
                    'Optional. Text to match against book titles or authors. Omit when you want to list everything in a group.',
              },
              'group_id': {
                'type': 'integer',
                'description':
                    'Optional. Restrict the search to a specific bookshelf group ID.',
              },
              'include_deleted': {
                'type': 'boolean',
                'description':
                    'Optional. Set true when you also need books that are currently marked as deleted (defaults to false).',
              },
              'limit': {
                'type': 'integer',
                'description':
                    'Optional. Upper bound on the number of books to return (range 1-50; backend default used if omitted).',
              },
            },
          },
          timeout: const Duration(seconds: 3),
        );

  final BooksRepository _repository;

  @override
  BookshelfLookupInput parseInput(Map<String, dynamic> json) {
    return BookshelfLookupInput.fromJson(json);
  }

  @override
  Future<Map<String, dynamic>> run(BookshelfLookupInput input) async {
    final results = await _repository.searchBooks(
      keyword: input.query,
      groupId: input.groupId,
      includeDeleted: input.includeDeleted,
      limit: input.resolvedLimit(),
    );

    return {
      'query': input.query,
      'groupId': input.groupId,
      'includeDeleted': input.includeDeleted,
      'results': results.map((entry) => entry.toMap()).toList(),
    };
  }

  @override
  bool shouldLogError(Object error) {
    return error is! TimeoutException;
  }
}

final AiToolDefinition bookshelfLookupToolDefinition = AiToolDefinition(
  id: 'bookshelf_lookup',
  displayNameBuilder: (L10n l10n) => l10n.aiToolBookshelfLookupName,
  descriptionBuilder: (L10n l10n) => l10n.aiToolBookshelfLookupDescription,
  build: (context) => BookshelfLookupTool(context.booksRepository).tool,
);
