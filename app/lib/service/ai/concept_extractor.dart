import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/dao/book_note.dart';
import 'package:omnigram/dao/concept_tag.dart';
import 'package:omnigram/service/ai/ai_availability.dart';
import 'package:omnigram/service/ai/ambient_ai_pipeline.dart';

/// Extracts concept tags from book notes using AI.
class ConceptExtractor {
  ConceptExtractor._();

  static Future<List<ConceptTag>> extractFromNotes({
    required WidgetRef ref,
    required int bookId,
    required String bookTitle,
  }) async {
    if (!AiAvailability.isAvailable(ref)) return [];

    final noteDao = BookNoteDao();
    final notes = await noteDao.selectBookNotesByBookId(bookId);
    if (notes.isEmpty) return [];

    final notesText = notes
        .where((n) => n.content.trim().isNotEmpty)
        .map((n) => '- [${n.chapter}] ${n.content}${n.readerNote != null ? " (笔记: ${n.readerNote})" : ""}')
        .join('\n');

    if (notesText.isEmpty) return [];

    final prompt =
        '''从以下书籍"$bookTitle"的高亮和笔记中，提取关键概念标签。
每个概念用一行表示，格式为: 概念名称|来源文本片段
只提取有实质意义的概念（人物、理论、方法论、核心观点等），不要提取通用词汇。
最多提取10个最重要的概念。

笔记内容:
$notesText

请直接输出概念列表，每行一个，格式: 概念|来源''';

    final result = await AmbientAiPipeline.execute(
      type: AmbientTaskType.conceptExtract,
      prompt: prompt,
      ref: ref,
      cacheParams: {'bookId': bookId, 'task': 'concept_extract'},
      bookId: bookId,
    );

    if (result == null || result.isEmpty) return [];

    final tags = <ConceptTag>[];
    for (final line in result.split('\n')) {
      final parts = line.trim().split('|');
      if (parts.length >= 2 && parts[0].trim().isNotEmpty) {
        tags.add(ConceptTag(bookId: bookId, name: parts[0].trim(), source: parts[1].trim()));
      }
    }
    return tags;
  }

  /// Find cross-book concept connections using AI.
  static Future<List<ConceptEdge>> findConnections({required WidgetRef ref, required List<ConceptTag> allTags}) async {
    if (!AiAvailability.isAvailable(ref) || allTags.length < 2) return [];

    // Group tags by book for the prompt
    final byBook = <int, List<ConceptTag>>{};
    for (final tag in allTags) {
      byBook.putIfAbsent(tag.bookId, () => []).add(tag);
    }
    if (byBook.length < 2) return [];

    final tagList = allTags.map((t) => '[ID:${t.id}] ${t.name} (book:${t.bookId})').join('\n');

    final prompt =
        '''以下是从多本书中提取的概念标签。请找出跨书的概念关联。
每个关联用一行表示，格式: 源ID|目标ID|权重(0.1-1.0)|关联原因
只找出真正有意义的跨书关联，最多5个。

概念列表:
$tagList

请直接输出关联列表:''';

    final result = await AmbientAiPipeline.execute(
      type: AmbientTaskType.conceptConnect,
      prompt: prompt,
      ref: ref,
      cacheParams: {'task': 'concept_connect', 'count': allTags.length.toString()},
    );

    if (result == null || result.isEmpty) return [];

    final edges = <ConceptEdge>[];
    for (final line in result.split('\n')) {
      final parts = line.trim().split('|');
      if (parts.length >= 4) {
        final sourceId = int.tryParse(parts[0].trim());
        final targetId = int.tryParse(parts[1].trim());
        final weight = double.tryParse(parts[2].trim()) ?? 0.5;
        final reason = parts[3].trim();
        if (sourceId != null && targetId != null) {
          edges.add(ConceptEdge(sourceTagId: sourceId, targetTagId: targetId, weight: weight, reason: reason));
        }
      }
    }
    return edges;
  }
}
