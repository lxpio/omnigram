import 'dart:async';

import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/service/ai/tools/ai_tool_registry.dart';
import 'package:omnigram/service/ai/tools/input/mindmap_input.dart';
import 'package:omnigram/service/ai/tools/util/mindmap_outline_parser.dart';

import 'base_tool.dart';

class MindmapTool extends RepositoryTool<MindmapInput, Map<String, dynamic>> {
  MindmapTool()
      : _parser = MindmapOutlineParser(),
        super(
          name: 'mindmap_draw',
          description:
              'Transform a hierarchical bullet list into the structured JSON the app uses to render mind maps. Call this after drafting an outline you want to visualise. Returns a root node with nested children ready for display.',
          inputJsonSchema: const {
            'type': 'object',
            'required': ['title', 'hierarchicalList'],
            'properties': {
              'title': {
                'type': 'string',
                'description':
                    'Required. Text used as the root label of the resulting mind map.',
              },
              'hierarchicalList': {
                'type': 'string',
                'description':
                    'Required. Markdown-like bullet list where indentation expresses nesting and each line represents a node.',
              },
            },
          },
          timeout: const Duration(seconds: 4),
        );

  final MindmapOutlineParser _parser;

  @override
  MindmapInput parseInput(Map<String, dynamic> json) {
    return MindmapInput.fromJson(json);
  }

  @override
  Future<Map<String, dynamic>> run(MindmapInput input) async {
    final result = _parser.parse(
      title: input.title,
      outline: input.hierarchicalList,
    );

    return Map<String, dynamic>.from(result.toJson());
  }
}

final AiToolDefinition mindmapToolDefinition = AiToolDefinition(
  id: 'mindmap_draw',
  displayNameBuilder: (L10n l10n) => l10n.aiToolMindmapName,
  descriptionBuilder: (L10n l10n) => l10n.aiToolMindmapDescription,
  build: (context) => MindmapTool().tool,
);
