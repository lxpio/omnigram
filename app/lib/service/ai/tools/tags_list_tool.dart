import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/service/ai/tools/base_tool.dart';
import 'package:omnigram/service/ai/tools/repository/tag_repository.dart';
import 'package:omnigram/service/ai/tools/ai_tool_registry.dart';
import 'package:omnigram/utils/color/hash_color.dart';
import 'package:omnigram/utils/color/rgb.dart';

const _tagsListToolId = 'tags_list';

final tagsListToolDefinition = AiToolDefinition(
  id: _tagsListToolId,
  displayNameBuilder: (L10n l10n) => l10n.aiToolTagsListName,
  descriptionBuilder: (L10n l10n) => l10n.aiToolTagsListDescription,
  build: (context) => TagsListTool(context.tagRepository).tool,
);

class TagsListTool
    extends RepositoryTool<Map<String, dynamic>, List<Map<String, dynamic>>> {
  TagsListTool(this._tagRepository)
      : super(
          name: _tagsListToolId,
          description: 'List all tags with id, name, rgb.',
          inputJsonSchema: const {
            'type': 'object',
            'properties': {},
          },
          timeout: const Duration(seconds: 5),
        );

  final TagRepository _tagRepository;

  @override
  Map<String, dynamic> parseInput(Map<String, dynamic> json) => json;

  @override
  Future<List<Map<String, dynamic>>> run(Map<String, dynamic> input) async {
    final tags = await _tagRepository.fetchAllTags();
    return tags
        .map((t) => {
              'id': t.id,
              'name': t.name,
              'rgb': rgbString(t.color ?? hashColor(t.name)),
            })
        .toList();
  }
}
