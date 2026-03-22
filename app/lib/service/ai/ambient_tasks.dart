import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/service/ai/ambient_ai_pipeline.dart';

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
}
