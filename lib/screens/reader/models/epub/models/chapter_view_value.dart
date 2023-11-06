import 'chapter_view_value.dart';

export 'package:epubx/epubx.dart' hide Image;

class ChapterIndex {
  const ChapterIndex({
    required this.chapter,
    required this.chapterIndex,
    required this.paragraphIndex,
  });

  final EpubChapter? chapter;
  final int chapterIndex;
  final int paragraphIndex;
}
