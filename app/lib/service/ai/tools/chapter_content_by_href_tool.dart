import 'dart:async';

import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/service/ai/tools/ai_tool_registry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'base_tool.dart';
import 'input/chapter_content_by_href_input.dart';
import 'repository/chapter_content_repository.dart';

class ChapterContentByHrefTool
    extends RepositoryTool<ChapterContentByHrefInput, Map<String, dynamic>> {
  ChapterContentByHrefTool(
    this._ref,
    this._repository,
  ) : super(
          name: 'chapter_content_by_href',
          description:
              'Retrieve the plain-text body of a specific chapter when you already know its TOC href. Use this to quote or analyse a particular section without changing the current reading position. Returns the chapter text trimmed to the requested length.',
          inputJsonSchema: const {
            'type': 'object',
            'properties': {
              'href': {
                'type': 'string',
                'description':
                    'Required. Chapter href string obtained from the table of contents tool.',
              },
              'maxCharacters': {
                'type': 'integer',
                'description':
                    'Optional. Hard cap on the number of characters returned (500-12000). Use lower values to avoid long responses.',
              },
            },
            'required': ['href'],
          },
          timeout: const Duration(seconds: 6),
        );

  final WidgetRef _ref;
  final ChapterContentRepository _repository;

  @override
  ChapterContentByHrefInput parseInput(Map<String, dynamic> json) {
    return ChapterContentByHrefInput.fromJson(json);
  }

  @override
  Future<Map<String, dynamic>> run(ChapterContentByHrefInput input) async {
    final content = await _repository.fetchByHref(
      _ref,
      href: input.href,
      maxCharacters: input.maxCharacters,
    );
    return {
      'content': content,
    };
  }
}

final AiToolDefinition chapterContentByHrefToolDefinition = AiToolDefinition(
  id: 'chapter_content_by_href',
  displayNameBuilder: (L10n l10n) => l10n.aiToolChapterContentByHrefName,
  descriptionBuilder: (L10n l10n) => l10n.aiToolChapterContentByHrefDescription,
  build: (context) => ChapterContentByHrefTool(
    context.ref,
    const ChapterContentRepository(),
  ).tool,
);
