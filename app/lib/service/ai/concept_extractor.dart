import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/dao/book_note.dart';
import 'package:omnigram/dao/concept_tag.dart';
import 'package:omnigram/service/ai/ai_availability.dart';
import 'package:omnigram/service/ai/ai_language.dart';
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
        .map((n) => '- [${n.chapter}] ${n.content}${n.readerNote != null ? " (note: ${n.readerNote})" : ""}')
        .join('\n');

    if (notesText.isEmpty) return [];

    final lang = getAiReplyLanguage();
    final prompt =
        '''From the following highlights and notes of the book "$bookTitle", extract key concept tags.
One concept per line, format: concept name|source text snippet
Only extract meaningful concepts (people, theories, methods, core ideas), not common words.
Extract at most 10 of the most important concepts.

Notes:
$notesText

Output the concept list directly, one per line, format: concept|source
Reply in $lang.''';

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

    final lang = getAiReplyLanguage();
    final prompt =
        '''The following are concept tags extracted from multiple books. Find cross-book concept connections.
One connection per line, format: sourceID|targetID|weight(0.1-1.0)|reason
Only find truly meaningful cross-book connections, at most 5.

Concept list:
$tagList

Output the connection list directly.
Reply in $lang.''';

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
