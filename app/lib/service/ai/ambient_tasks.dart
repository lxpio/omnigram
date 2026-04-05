import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/dao/concept_tag.dart';
import 'package:omnigram/providers/companion_provider.dart';
import 'package:omnigram/service/ai/ai_language.dart';
import 'package:omnigram/service/ai/ambient_ai_pipeline.dart';
import 'package:omnigram/service/ai/concept_extractor.dart';

/// Convenience methods for specific ambient AI tasks.
class AmbientTasks {
  AmbientTasks._();

  /// Generate context bar text for a chapter
  static Future<String?> contextBar({
    required WidgetRef ref,
    required int bookId,
    required String chapterTitle,
    String? previousChapterContent,
  }) {
    final prompt = previousChapterContent != null
        ? 'The reader just finished a section about: "$previousChapterContent". '
              'They are now starting: "$chapterTitle". '
              'Write a single brief sentence (under 30 words) bridging what they '
              'read before to what comes next. '
              'Format: "Previously: [brief recap]. This chapter: [what to expect]."'
        : 'The reader is starting chapter: "$chapterTitle". '
              'Write a single brief sentence (under 20 words) introducing what '
              'this chapter covers.';

    return AmbientAiPipeline.execute(
      type: AmbientTaskType.contextBar,
      prompt: prompt,
      ref: ref,
      cacheParams: {'bookId': bookId, 'chapter': chapterTitle},
    );
  }

  /// Generate memory bridge for desk page
  static Future<String?> memoryBridge({
    required WidgetRef ref,
    required int bookId,
    required String bookTitle,
    required String lastPosition,
    required double progress,
  }) {
    final pct = (progress * 100).toInt();
    final prompt =
        'The reader is reading "$bookTitle" and was last at: '
        '"$lastPosition" ($pct% through). '
        'Write a single warm sentence (under 25 words) reminding them where '
        'they left off, to help them resume reading. Do not mention the percentage.';

    return AmbientAiPipeline.execute(
      type: AmbientTaskType.memoryBridge,
      prompt: prompt,
      ref: ref,
      cacheParams: {'bookId': bookId, 'position': lastPosition},
    );
  }

  /// Generate auto-tags for a newly imported book
  static Future<String?> autoTag({
    required WidgetRef ref,
    required int bookId,
    required String title,
    required String author,
    String? description,
  }) {
    final desc = description != null ? ' Description: $description' : '';
    final prompt =
        'Book: "$title" by $author.$desc\n\n'
        'Generate 3-5 topic tags for this book. '
        'Return ONLY the tags separated by commas, nothing else. '
        'Example: "量子物理, 科普, 宇宙学"';

    return AmbientAiPipeline.execute(
      type: AmbientTaskType.autoTag,
      prompt: prompt,
      ref: ref,
      cacheParams: {'bookId': bookId},
    );
  }

  /// Generate inline glossary explanation for selected text
  static Future<String?> glossary({
    required WidgetRef ref,
    required String selectedText,
    String? contextText,
  }) {
    final context = contextText != null ? ' Context: "$contextText"' : '';
    final prompt =
        'The reader selected this text: "$selectedText".$context\n\n'
        'Provide a brief, clear explanation (under 40 words). '
        'If it\'s a term, define it. If it\'s a passage, explain its meaning. '
        'Be concise and helpful. Do not use markdown formatting.';

    return AmbientAiPipeline.execute(
      type: AmbientTaskType.glossary,
      prompt: prompt,
      ref: ref,
      cacheParams: {'glossary': selectedText},
    );
  }

  /// Auto-detect difficult words in chapter text.
  /// Returns lines of "word|definition", one per line.
  static Future<String?> autoGlossary({
    required WidgetRef ref,
    required int bookId,
    required String chapterTitle,
    required String chapterText,
  }) {
    final lang = getAiReplyLanguage();
    final truncated = chapterText.length > 3000
        ? chapterText.substring(0, 3000)
        : chapterText;
    final prompt =
        'Identify 5-8 difficult, uncommon, or domain-specific words/phrases in the following text.\n'
        'For each word, provide a brief definition (1 sentence max).\n'
        'Format: one per line, word|definition\n'
        'Only include words that a general reader would likely not know.\n\n'
        'Text:\n$truncated\n\n'
        'Reply in $lang.';

    return AmbientAiPipeline.execute(
      type: AmbientTaskType.autoGlossary,
      prompt: prompt,
      ref: ref,
      cacheParams: {'bookId': bookId, 'chapter': chapterTitle},
      bookId: bookId,
    );
  }

  /// Generate reading recommendation based on library
  static Future<String?> recommendation({
    required WidgetRef ref,
    required List<String> recentTitles,
  }) {
    if (recentTitles.isEmpty) return Future.value(null);
    final titles = recentTitles.take(5).join(', ');
    final prompt =
        'The reader\'s recent books include: $titles. '
        'Based on their reading interests, write ONE sentence (under 30 words) '
        'suggesting what kind of book they might enjoy next. '
        'Be warm and specific. Do not recommend a specific title.';

    return AmbientAiPipeline.execute(
      type: AmbientTaskType.recommendation,
      prompt: prompt,
      ref: ref,
      cacheParams: {'recommendation': titles},
    );
  }

  /// Generate AI reading narrative for insights page
  static Future<String?> readingNarrative({
    required WidgetRef ref,
    required List<String> bookTitles,
    required int totalMinutes,
    required int totalNotes,
    required String timePeriod,
  }) {
    if (bookTitles.isEmpty) return Future.value(null);

    final titles = bookTitles.join(', ');
    final hours = totalMinutes ~/ 60;
    final prompt =
        'The reader has read these books during $timePeriod: $titles. '
        'They spent about $hours hours reading and made $totalNotes notes. '
        'Write a 2-3 sentence narrative summary (under 60 words) of their reading journey. '
        'Comment on themes, patterns, or progression in their reading. '
        'Be warm and insightful. Do not list the books — weave them into a story.';

    return AmbientAiPipeline.execute(
      type: AmbientTaskType.narrative,
      prompt: prompt,
      ref: ref,
      cacheParams: {'narrative': timePeriod, 'books': titles},
    );
  }

  /// Generate one-line summary for a book
  static Future<String?> summary({
    required WidgetRef ref,
    required int bookId,
    required String title,
    required String author,
    String? description,
  }) {
    final desc = description != null ? ' Description: $description' : '';
    final prompt =
        'Book: "$title" by $author.$desc\n\n'
        'Write a single-sentence summary (under 30 words) of what this book '
        'is about. Be specific, not generic.';

    return AmbientAiPipeline.execute(
      type: AmbientTaskType.summary,
      prompt: prompt,
      ref: ref,
      cacheParams: {'bookId': bookId},
    );
  }

  /// Extract concept tags from a book's notes and persist them.
  /// Returns the number of new concepts extracted.
  static Future<int> extractConcepts({
    required WidgetRef ref,
    required int bookId,
    required String bookTitle,
  }) async {
    // Guard: skip if auto knowledge graph is disabled
    final personality = ref.read(companionProvider);
    if (!personality.autoKnowledgeGraph) return 0;

    final tags = await ConceptExtractor.extractFromNotes(
      ref: ref,
      bookId: bookId,
      bookTitle: bookTitle,
    );
    if (tags.isEmpty) return 0;

    final dao = ConceptTagDao();
    await dao.insertBatch(tags);
    return tags.length;
  }
}
