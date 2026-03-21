import 'package:omnigram/dao/tag.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/models/tag.dart';
import 'package:omnigram/service/ai/tools/base_tool.dart';
import 'package:omnigram/service/ai/tools/input/apply_book_tags_input.dart';
import 'package:omnigram/service/ai/tools/repository/books_repository.dart';
import 'package:omnigram/service/ai/tools/repository/tag_repository.dart';
import 'package:omnigram/service/ai/tools/ai_tool_registry.dart';
import 'package:omnigram/utils/color/hash_color.dart';
import 'package:omnigram/utils/color/rgb.dart';

const _applyBookTagsToolId = 'apply_book_tags';

final applyBookTagsToolDefinition = AiToolDefinition(
  id: _applyBookTagsToolId,
  displayNameBuilder: (L10n l10n) => l10n.aiToolApplyBookTagsName,
  descriptionBuilder: (L10n l10n) => l10n.aiToolApplyBookTagsDescription,
  build: (context) =>
      ApplyBookTagsTool(context.tagRepository, context.booksRepository).tool,
);

class ApplyBookTagsTool
    extends RepositoryTool<ApplyBookTagsInput, Map<String, dynamic>> {
  ApplyBookTagsTool(this._tagRepository, this._booksRepository)
      : super(
          name: _applyBookTagsToolId,
          description:
              'Plan tag changes (create/update) and book-tag links. Returns a plan requiring user confirmation.',
          inputJsonSchema: const {
            'type': 'object',
            'properties': {
              'books': {
                'type': 'array',
                'items': {
                  'type': 'object',
                  'required': ['bookId', 'bookTitle'],
                  'properties': {
                    'bookId': {'type': 'integer'},
                    'bookTitle': {'type': 'string'},
                    'tags': {
                      'type': 'array',
                      'items': {'type': 'string'},
                      'description':
                          'Final tag names that should be attached to this book.'
                    }
                  }
                }
              },
              'createTags': {
                'type': 'array',
                'items': {
                  'type': 'object',
                  'required': ['name'],
                  'properties': {
                    'name': {'type': 'string'},
                    'rgb': {
                      'type': 'string',
                      'description': 'RGB hex string, e.g. 0x33aa77',
                    }
                  }
                }
              },
              'updateTags': {
                'type': 'array',
                'items': {
                  'type': 'object',
                  'required': ['id'],
                  'properties': {
                    'id': {'type': 'integer'},
                    'name': {'type': 'string'},
                    'rgb': {
                      'type': 'string',
                      'description': 'RGB hex string, e.g. 0x33aa77',
                    }
                  }
                }
              }
            }
          },
          timeout: const Duration(seconds: 12),
        );

  final TagRepository _tagRepository;
  final BooksRepository _booksRepository;

  @override
  ApplyBookTagsInput parseInput(Map<String, dynamic> json) =>
      ApplyBookTagsInput.fromJson(json);

  @override
  Future<Map<String, dynamic>> run(ApplyBookTagsInput input) async {
    final conflicts = <Map<String, dynamic>>[];
    final createPlans = <String, Map<String, dynamic>>{};
    final updatePlans = <Map<String, dynamic>>[];
    final mergePlans = <Map<String, dynamic>>[];
    final booksOutput = <Map<String, dynamic>>[];
    final bookChanges = <Map<String, dynamic>>[];

    final existingTags = await _tagRepository.fetchAllTags();
    final tagByName = {
      for (final t in existingTags) t.name.toLowerCase(): t,
    };

    // Plan updates with merge
    for (final update in input.updateTags.where((u) => u.isValid)) {
      final existing = await _tagRepository.fetchTagById(update.id);
      if (existing == null) {
        conflicts.add({
          'type': 'missing_tag',
          'id': update.id,
          'message': 'Tag id ${update.id} not found'
        });
        continue;
      }
      Tag target = existing;
      if (update.name != null) {
        final collision = await _tagRepository.fetchTagByName(update.name!);
        if (collision != null && collision.id != existing.id) {
          mergePlans.add({'sourceId': existing.id, 'targetId': collision.id});
          target = collision;
        }
      }
      updatePlans.add({
        'id': target.id,
        if (update.name != null) 'name': update.name,
        if (update.rgb != null)
          'rgb': rgbString(parseRgb(update.rgb) ?? sanitizeRgb(0)),
      });
    }

    // Plan createTags
    for (final create in input.createTags.where((c) => c.isValid)) {
      createPlans[create.name.toLowerCase()] = {
        'name': create.name,
        'rgb': rgbString(
          parseRgb(create.rgb) ?? hashColor(create.name),
        ),
      };
    }

    for (final bookReq in input.books.where((b) => b.isValid)) {
      final book = await _booksRepository.fetchByIds([bookReq.bookId]);
      final found = book[bookReq.bookId];
      if (found == null || found.isDeleted) {
        conflicts.add({
          'type': 'missing_book',
          'bookId': bookReq.bookId,
          'bookTitle': bookReq.bookTitle,
          'message': 'Book not found or deleted'
        });
        continue;
      }

      final desiredNames = bookReq.tags
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList();

      final currentTags = await bookTagDao.fetchTagsForBook(found.id);
      final currentNameSet =
          currentTags.map((t) => t.name.toLowerCase()).toSet();

      // ensure planned create for missing tags
      for (final name in desiredNames) {
        final key = name.toLowerCase();
        if (!tagByName.containsKey(key)) {
          createPlans[key] = {
            'name': name,
            'rgb': rgbString(hashColor(name)),
          };
        }
      }

      final addNames = desiredNames
          .where((n) => !currentNameSet.contains(n.toLowerCase()))
          .toList();
      final removeNames = currentTags
          .where((t) => !desiredNames
              .map((n) => n.toLowerCase())
              .contains(t.name.toLowerCase()))
          .map((t) => t.name)
          .toList();

      booksOutput.add({
        'bookId': found.id,
        'bookTitle': found.title,
        'finalTags': desiredNames
            .map(
              (n) => {
                'name': n,
                'rgb': rgbString(
                    tagByName[n.toLowerCase()]?.color ?? hashColor(n)),
              },
            )
            .toList(),
      });

      bookChanges.add({
        'bookId': found.id,
        'add': addNames,
        'remove': removeNames,
      });
    }

    return {
      'requiresConfirmation': true,
      'plan': {
        'books': booksOutput,
        'createTags': createPlans.values.toList(),
        'updateTags': updatePlans,
        'mergeTags': mergePlans,
        'bookChanges': bookChanges,
      },
      'conflicts': conflicts,
    };
  }
}
