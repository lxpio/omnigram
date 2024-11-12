export 'package:epubx/epubx.dart' hide Image;

class ChapterIndex {
  const ChapterIndex({
    // required this.chapter,
    required this.chapterIndex,
    required this.paragraphIndex,
    this.position,
  });

  // final EpubChapter? chapter;
  final int chapterIndex;
  final int paragraphIndex;
  final int? position;

  factory ChapterIndex.create(
    int? combined,
    int? position,
  ) {
    return ChapterIndex(
      chapterIndex: (combined ?? 0) >> 32,
      paragraphIndex: (combined ?? 0) & 0xFFFFFFFF,
      position: position,
    );
  }

  get combined => (chapterIndex << 32) | paragraphIndex;

  get duration => position == null ? null : Duration(milliseconds: position!);
}
