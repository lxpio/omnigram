import 'dart:async';

import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/models/toc_item.dart';
import 'package:omnigram/providers/book_toc.dart';
import 'package:omnigram/providers/current_reading.dart';
import 'package:omnigram/service/ai/tools/ai_tool_registry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'base_tool.dart';

class CurrentBookTocTool extends RepositoryTool<JsonMap, Map<String, dynamic>> {
  CurrentBookTocTool(this._ref)
      : super(
          name: 'current_book_toc',
          description:
              'Gather the table of contents for the book the user is reading right now, including their current position. Use this when you need chapter structure or to navigate to a different section. Returns an isReading flag, the current location details, and the full hierarchical TOC with percentages.',
          inputJsonSchema: const {
            'type': 'object',
            'properties': <String, dynamic>{},
          },
          timeout: const Duration(seconds: 2),
        );

  final WidgetRef _ref;

  @override
  JsonMap parseInput(Map<String, dynamic> json) {
    return json;
  }

  @override
  Future<Map<String, dynamic>> run(JsonMap input) async {
    final readingState = _ref.read(currentReadingProvider);
    final tocItems = _ref.read(bookTocProvider);

    if (!readingState.isReading || readingState.book == null) {
      return {
        'isReading': false,
        'message':
            'No active reading session is detected. A table of contents is only available while reading.',
        'toc': <Map<String, dynamic>>[],
      };
    }

    final currentLocation = {
      'href': readingState.chapterHref,
      'title': readingState.chapterTitle,
      'percentage': readingState.percentage,
    };

    return {
      'isReading': true,
      'currentLocation': currentLocation,
      'toc': tocItems.map(_serializeTocItem).toList(),
    };
  }

  Map<String, dynamic> _serializeTocItem(TocItem item) {
    return {
      'id': item.id,
      'href': item.href,
      'title': item.label,
      'level': item.level,
      'formattedPercentage': item.percentage,
      'children': item.subitems.map(_serializeTocItem).toList(),
    };
  }
}

final AiToolDefinition currentBookTocToolDefinition = AiToolDefinition(
  id: 'current_book_toc',
  displayNameBuilder: (L10n l10n) => l10n.aiToolCurrentBookTocName,
  descriptionBuilder: (L10n l10n) => l10n.aiToolCurrentBookTocDescription,
  build: (context) => CurrentBookTocTool(context.ref).tool,
);
