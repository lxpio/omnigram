import 'package:omnigram/providers/chapter_content_bridge.dart';
import 'package:omnigram/providers/current_reading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChapterContentRepository {
  const ChapterContentRepository();

  static const int _minLimit = 500;
  static const int _maxLimit = 12000;

  int? _resolveLimit(int? value) {
    if (value == null) {
      return null;
    }
    if (value <= 0) {
      return null;
    }
    return value.clamp(_minLimit, _maxLimit);
  }

  Future<String> fetchCurrent(
    WidgetRef ref, {
    int? maxCharacters,
  }) async {
    final readingState = ref.read(currentReadingProvider);
    if (!readingState.isReading) {
      throw StateError('No active reading session.');
    }

    final handlers = ref.read(chapterContentBridgeProvider);
    if (handlers == null) {
      throw StateError('Reader bridge is not available.');
    }

    final limit = _resolveLimit(maxCharacters);
    final content = await handlers.fetchCurrentChapter(maxCharacters: limit);
    return _sanitizeContent(content, limit);
  }

  Future<String> fetchByHref(
    WidgetRef ref, {
    required String href,
    int? maxCharacters,
  }) async {
    final normalizedHref = href.trim();
    if (normalizedHref.isEmpty) {
      throw ArgumentError('href must not be empty');
    }

    final readingState = ref.read(currentReadingProvider);
    if (!readingState.isReading) {
      throw StateError('No active reading session.');
    }

    final handlers = ref.read(chapterContentBridgeProvider);
    if (handlers == null) {
      throw StateError('Reader bridge is not available.');
    }

    final limit = _resolveLimit(maxCharacters);
    final content = await handlers.fetchChapterByHref(
      normalizedHref,
      maxCharacters: limit,
    );
    return _sanitizeContent(content, limit);
  }

  String _sanitizeContent(String content, int? limit) {
    final trimmed = content.trim();
    if (limit == null || trimmed.length <= limit) {
      return trimmed;
    }
    return trimmed.substring(0, limit);
  }
}
