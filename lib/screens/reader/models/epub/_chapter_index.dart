import '_chapter_index.dart';

export 'package:epubx/epubx.dart' hide Image;

class ChapterIndex {
  const ChapterIndex({
    // required this.chapter,
    required this.chapterIndex,
    required this.paragraphIndex,
  });

  factory ChapterIndex.create(
    int? combined,
  ) {
    return ChapterIndex(
        // chapter: chapter,
        chapterIndex: (combined ?? 0) >> 32,
        paragraphIndex: (combined ?? 0) & 0xFFFFFFFF);
  }

  // final EpubChapter? chapter;
  final int chapterIndex;
  final int paragraphIndex;

  get combined => (chapterIndex << 32) | paragraphIndex;
}
