import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef CurrentChapterContentFetcher = Future<String> Function(
    {int? maxCharacters});
typedef ChapterContentByHrefFetcher = Future<String> Function(
  String href, {
  int? maxCharacters,
});

class ChapterContentHandlers {
  const ChapterContentHandlers({
    required this.fetchCurrentChapter,
    required this.fetchChapterByHref,
  });

  final CurrentChapterContentFetcher fetchCurrentChapter;
  final ChapterContentByHrefFetcher fetchChapterByHref;
}

final chapterContentBridgeProvider =
    StateProvider<ChapterContentHandlers?>((ref) => null);
