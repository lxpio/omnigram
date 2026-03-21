import 'dart:async';

import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/service/ai/tools/ai_tool_registry.dart';
import 'package:omnigram/service/ai/tools/input/bookshelf_organize_input.dart';
import 'package:omnigram/service/ai/tools/repository/books_repository.dart';
import 'package:omnigram/service/ai/tools/repository/groups_repository.dart';

import 'base_tool.dart';

class BookshelfOrganizeTool
    extends RepositoryTool<BookshelfOrganizeInput, Map<String, dynamic>> {
  BookshelfOrganizeTool(
    this._booksRepository,
    this._groupsRepository,
  ) : super(
          name: 'bookshelf_organize',
          description:
              'Draft a re-organization plan for the user\'s bookshelf without mutating data yourself. Use this after you have discussed a grouping strategy and want to present concrete moves. Supply the desired groups and book IDs to relocate; the tool responds with a human-readable plan that still needs the user to click Apply inside the app.',
          inputJsonSchema: const {
            'type': 'object',
            'properties': {
              'groups': {
                'type': 'array',
                'description':
                    'List every group you want to exist after re-organization, including its member books.',
                'minItems': 1,
                'items': {
                  'type': 'object',
                  'properties': {
                    'groupId': {
                      'type': 'integer',
                      'description':
                          'Identifier for the destination group. Use an existing group ID or, for new groups, reuse one of the member book IDs to match app behaviour.',
                    },
                    'bookIds': {
                      'type': 'array',
                      'items': {'type': 'integer'},
                      'description':
                          'One or more book IDs that should end up inside this group once the plan is applied.',
                      'minItems': 1,
                    },
                    'name': {
                      'type': 'string',
                      'description':
                          'Optional. Suggested name for the group when it already exists.',
                    },
                    'renameTo': {
                      'type': 'string',
                      'description':
                          'Optional. New title you would like to assign to an existing group.',
                    },
                    'createNew': {
                      'type': 'boolean',
                      'description':
                          'Optional. Set true when this group does not already exist and should be created.',
                    },
                  },
                },
              },
              'ungroupedBookIds': {
                'type': 'array',
                'items': {'type': 'integer'},
                'description':
                    'Optional. Any book IDs that should end up outside of all groups (i.e. moved to the Ungrouped list).',
                'minItems': 1,
              },
              'cleanupGroupIds': {
                'type': 'array',
                'items': {'type': 'integer'},
                'description':
                    'Optional. IDs of groups to delete after the move (use for empty folders you want to remove).',
                'minItems': 1,
              },
              'summary': {
                'type': 'string',
                'description':
                    'Optional. Short explanation of the overall plan to display to the user.',
              },
            },
          },
          timeout: const Duration(seconds: 8),
        );

  final BooksRepository _booksRepository;
  final GroupsRepository _groupsRepository;

  @override
  BookshelfOrganizeInput parseInput(Map<String, dynamic> json) {
    return BookshelfOrganizeInput.fromJson(json);
  }

  @override
  Future<Map<String, dynamic>> run(BookshelfOrganizeInput input) async {
    if (input.isEmpty) {
      throw ArgumentError('No bookshelf changes were provided.');
    }

    final allBookIds = input.allBookIds().toList(growable: false);
    if (allBookIds.isEmpty) {
      throw ArgumentError('Book IDs cannot be empty.');
    }

    final uniqueBookIds = allBookIds.toSet();
    if (uniqueBookIds.length != allBookIds.length) {
      throw ArgumentError(
        'Each book ID must appear in only one target group or ungrouped list.',
      );
    }

    final bookMap = await _booksRepository.fetchByIds(uniqueBookIds);
    final missingBooks = uniqueBookIds.where((id) => !bookMap.containsKey(id));
    if (missingBooks.isNotEmpty) {
      throw ArgumentError('Unknown book IDs: ${missingBooks.join(', ')}');
    }

    final deletedBooks = bookMap.values.where((book) => book.isDeleted);
    if (deletedBooks.isNotEmpty) {
      final ids = deletedBooks.map((book) => book.id).join(', ');
      throw ArgumentError('Cannot organize deleted books (ids: $ids).');
    }

    final allGroupIds = {
      ...input.groups.map((group) => group.groupId),
      ...input.cleanupGroupIds,
    }..removeWhere((id) => id <= 0);
    final existingGroups = await _groupsRepository.fetchByIds(allGroupIds);

    final groupsPlan = <Map<String, dynamic>>[];
    final newGroupIds = <int>{};

    for (final group in input.groups) {
      final books = group.bookIds.map((id) => bookMap[id]!).toList();
      final existing = existingGroups[group.groupId];
      final createNew = group.createNew ?? existing == null;

      if (createNew && books.isEmpty) {
        throw ArgumentError(
          'New group ${group.groupId} must include at least one book.',
        );
      }

      if (createNew && !books.any((book) => book.id == group.groupId)) {
        throw ArgumentError(
          'For a new group, use a book ID from its members as groupId to stay consistent with the app.',
        );
      }

      if (!createNew && existing == null) {
        throw ArgumentError(
          'Group ${group.groupId} does not exist. Set create_new=true to create it.',
        );
      }

      if (createNew && newGroupIds.contains(group.groupId)) {
        throw ArgumentError('Duplicate new group identifier ${group.groupId}.');
      }
      if (createNew) {
        newGroupIds.add(group.groupId);
      }

      final targetName = group.renameTo ?? group.name ?? existing?.name;
      groupsPlan.add({
        'groupId': group.groupId,
        'createNew': createNew,
        'currentName': existing?.name,
        'proposedName': targetName,
        'books': books.map(_serializeBook).toList(),
      });
    }

    final ungrouped = input.ungroupedBookIds
        .map((id) => bookMap[id]!)
        .map(_serializeBook)
        .toList(growable: false);

    final cleanupGroupIds = input.cleanupGroupIds
        .where((id) => id > 0)
        .where((id) => !input.groups.any((group) => group.groupId == id))
        .toSet()
        .toList()
      ..sort();

    final generatedSummary = input.summary ??
        _buildSummary(
          groupsPlan,
          ungrouped,
        );

    return {
      'requiresConfirmation': true,
      'plan': {
        'summary': generatedSummary,
        'groups': groupsPlan,
        'ungroupedBooks': ungrouped,
        'cleanupGroupIds': cleanupGroupIds,
        'stats': {
          'groups': groupsPlan.length,
          'movedBooks': groupsPlan.fold<int>(
            0,
            (acc, group) => acc + (group['books'] as List).length,
          ),
          'ungroupedBooks': ungrouped.length,
        },
      },
    };
  }

  Map<String, dynamic> _serializeBook(Book book) {
    return {
      'bookId': book.id,
      'title': book.title,
      if (book.author.trim().isNotEmpty) 'author': book.author,
      'previousGroupId': book.groupId,
    };
  }

  String _buildSummary(
    List<Map<String, dynamic>> groups,
    List<Map<String, dynamic>> ungrouped,
  ) {
    final movedCount = groups.fold<int>(
      0,
      (sum, group) => sum + (group['books'] as List).length,
    );
    final groupCount = groups.length;
    final ungroupedCount = ungrouped.length;
    final parts = <String>[];

    if (movedCount > 0) {
      parts.add(
        '$movedCount book${movedCount == 1 ? '' : 's'} assigned to $groupCount group${groupCount == 1 ? '' : 's'}.',
      );
    }
    if (ungroupedCount > 0) {
      parts.add(
        '$ungroupedCount book${ungroupedCount == 1 ? '' : 's'} left ungrouped.',
      );
    }
    if (parts.isEmpty) {
      parts.add('No bookshelf changes detected.');
    }
    return parts.join(' ');
  }
}

final AiToolDefinition bookshelfOrganizeToolDefinition = AiToolDefinition(
  id: 'bookshelf_organize',
  displayNameBuilder: (L10n l10n) => l10n.aiToolBookshelfOrganizeName,
  descriptionBuilder: (L10n l10n) => l10n.aiToolBookshelfOrganizeDescription,
  build: (context) =>
      BookshelfOrganizeTool(context.booksRepository, context.groupsRepository)
          .tool,
);
