import 'package:omnigram/dao/book.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/service/ai/tools/base_tool.dart';
import 'package:omnigram/service/ai/tools/repository/tag_repository.dart';
import 'package:omnigram/service/ai/tools/ai_tool_registry.dart';
import 'package:omnigram/utils/color/hash_color.dart';
import 'package:omnigram/utils/color/rgb.dart';

const _booksTagsListToolId = 'books_tags_list';

final booksTagsListToolDefinition = AiToolDefinition(
  id: _booksTagsListToolId,
  displayNameBuilder: (L10n l10n) => l10n.aiToolBooksTagsListName,
  descriptionBuilder: (L10n l10n) => l10n.aiToolBooksTagsListDescription,
  build: (context) => BooksTagsListTool(context.tagRepository).tool,
);

class BooksTagsListTool
    extends RepositoryTool<Map<String, dynamic>, List<Map<String, dynamic>>> {
  BooksTagsListTool(this._tagRepository)
      : super(
          name: _booksTagsListToolId,
          description:
              'List books with their tags. Optional bookIds array filters the result.',
          inputJsonSchema: const {
            'type': 'object',
            'properties': {
              'bookIds': {
                'type': 'array',
                'items': {'type': 'integer'},
                'description': 'Optional list of book IDs to filter.',
              }
            }
          },
          timeout: const Duration(seconds: 8),
        );

  final TagRepository _tagRepository;

  @override
  Map<String, dynamic> parseInput(Map<String, dynamic> json) => json;

  @override
  Future<List<Map<String, dynamic>>> run(Map<String, dynamic> input) async {
    final ids = (input['bookIds'] as List?)
            ?.map((e) => (e as num?)?.toInt() ?? 0)
            .where((e) => e > 0)
            .toList() ??
        const [];
    final tagMap = await _tagRepository.fetchTagsForBooks(ids);
    final books = ids.isEmpty
        ? await bookDao.selectNotDeleteBooks()
        : await bookDao.selectBooksByIds(ids);
    final byId = {for (final b in books) b.id: b};
    return tagMap.entries
        .map((entry) {
          final book = byId[entry.key];
          if (book == null) return null;
          return {
            'bookId': book.id,
            'bookTitle': book.title,
            'tags': entry.value
                .map((t) => {
                      'id': t.id,
                      'name': t.name,
                      'rgb': rgbString(
                        t.color ?? hashColor(t.name),
                      ),
                    })
                .toList(),
          };
        })
        .whereType<Map<String, dynamic>>()
        .toList();
  }
}
