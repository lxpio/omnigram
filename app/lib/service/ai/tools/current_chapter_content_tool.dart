import 'dart:async';

import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/service/ai/tools/ai_tool_registry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'base_tool.dart';
import 'repository/chapter_content_repository.dart';

class CurrentChapterContentTool
    extends RepositoryTool<JsonMap, Map<String, dynamic>> {
  CurrentChapterContentTool(
    this._ref,
    this._repository,
  ) : super(
          name: 'current_chapter_content',
          description:
              'Pull the plain-text content of whichever chapter the user is actively reading. Use this when you need to quote the current section or summarise it without specifying a href. Returns a single content string.',
          inputJsonSchema: const {
            'type': 'object',
            'properties': <String, dynamic>{},
          },
          timeout: const Duration(seconds: 4),
        );

  final WidgetRef _ref;
  final ChapterContentRepository _repository;

  @override
  JsonMap parseInput(Map<String, dynamic> json) {
    return json;
  }

  @override
  Future<Map<String, dynamic>> run(JsonMap input) async {
    final content = await _repository.fetchCurrent(_ref);
    return {
      'content': content,
    };
  }
}

final AiToolDefinition currentChapterContentToolDefinition = AiToolDefinition(
  id: 'current_chapter_content',
  displayNameBuilder: (L10n l10n) => l10n.aiToolCurrentChapterContentName,
  descriptionBuilder: (L10n l10n) =>
      l10n.aiToolCurrentChapterContentDescription,
  build: (context) =>
      CurrentChapterContentTool(context.ref, const ChapterContentRepository())
          .tool,
);
