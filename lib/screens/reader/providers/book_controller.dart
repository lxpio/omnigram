import 'package:flutter/foundation.dart';
import 'package:omnigram/screens/reader/models/epub_document.dart';
import 'package:omnigram/screens/reader/models/epub/models/chapter_view_value.dart';

import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

const _minTrailingEdge = 0.55;
const _minLeadingEdge = -0.05;

class BookController {
  BookController({
    required this.document,
  });

  final EpubDocument document;

  late ItemScrollController? itemScrollController;
  late ItemPositionsListener itemPositionListener;

  final ValueNotifier<ChapterIndex?> index = ValueNotifier(null);

  void initialize() {
    itemScrollController = ItemScrollController();

    itemPositionListener = ItemPositionsListener.create();

    itemPositionListener.itemPositions.addListener(_listener);
    index.value = cfiParse(document.epubCfi);
  }

  void dispose() {
    itemPositionListener.itemPositions.removeListener(_listener);
  }

  void _listener() {
    if (document.paragraphs.isEmpty ||
        itemPositionListener.itemPositions.value.isEmpty) {
      return;
    }
    final position = itemPositionListener.itemPositions.value.first;

    final posIndex = _getAbsParagraphIndexBy(
      positionIndex: position.index,
      trailingEdge: position.itemTrailingEdge,
      leadingEdge: position.itemLeadingEdge,
    );

    final chapterIndex = _getChapterIndex(posIndex);

    final paragraphIndex = _getParagraphIndex(chapterIndex, posIndex);

    if (index.value != null) {
      if (index.value!.chapterIndex != chapterIndex ||
          index.value!.paragraphIndex != paragraphIndex) {
        index.value = ChapterIndex(
          chapter: chapterIndex >= 0 ? document.chapters[chapterIndex] : null,
          // 这里是相对路径
          chapterIndex: chapterIndex,
          paragraphIndex: paragraphIndex,
        );
      }
    }
  }

  String? cfiGenerate() {
    final chapter = index.value?.chapter;
    final paragraphIndex = index.value?.paragraphIndex;
    if (chapter == null || paragraphIndex == null) {
      return null;
    }

    return chapter.Anchor == null
        ? '/${chapter.ContentFileName}?$paragraphIndex'
        : '/${chapter.ContentFileName}#${chapter.Anchor}?$paragraphIndex';
  }

  ChapterIndex? cfiParse(String? cfi) {
    if (cfi == null || !cfi.startsWith('/')) {
      // 处理无效的 CFI 字符串
      return null;
    }

    List<String> parts = cfi.split('?');

    int paragraphIndex = 0;

    if (parts.length == 2) {
      // 解析段落索引
      paragraphIndex = int.tryParse(parts[1]) ?? 0;
    }

    List<String> cparts = parts[0].split('#');
    // 处理带锚点的情况
    final anchor = (cparts.length == 2) ? cparts[1] : null;

    final chapterIndex = document.chapters.indexWhere((chapter) =>
        chapter.ContentFileName == cparts[0].substring(1) &&
        chapter.Anchor == anchor);

    return chapterIndex == -1
        ? ChapterIndex(
            chapter: null,
            chapterIndex: 0,
            paragraphIndex: paragraphIndex,
          )
        : ChapterIndex(
            chapter: document.chapters[chapterIndex],
            chapterIndex: chapterIndex,
            paragraphIndex: paragraphIndex,
          );
  }

  int? get currentParagraphIndex {
    final last = cfiParse(document.epubCfi);

    return absParagraphIndex(last);
  }

  int? absParagraphIndex(ChapterIndex? current) {
    return current != null
        ? document.chapterIndexes[current.chapterIndex] + current.paragraphIndex
        : null;
  }

  double get progress {
    final pos = absParagraphIndex(index.value);

    if (pos == null) {
      return 0;
    }
    if (kDebugMode) {
      print('currentParagraphIndex $pos / ${document.paragraphs.length} ');
    }
    return pos * 100.0 / document.paragraphs.length;
  }

  int get paraLength {
    return document.paragraphs.length;
  }

  EpubContent? get content => document.book.Content;

  bool chapterDivider(int posIndex) {
    final chapterIndex = _getChapterIndex(posIndex);

    final paragraphIndex = _getParagraphIndex(chapterIndex, posIndex);

    return (chapterIndex >= 0 && paragraphIndex == 0);
  }

  int _getChapterIndex(
    int posIndex,
  ) {
    final index = posIndex >= document.chapterIndexes.last
        ? document.chapterIndexes.length
        : document.chapterIndexes.indexWhere((chapterIndex) {
            if (posIndex < chapterIndex) {
              return true;
            }
            return false;
          });

    return index - 1;
  }

  int _getParagraphIndex(
    int chapterIndex,
    int posIndex,
  ) {
    if (chapterIndex == -1) {
      return posIndex;
    }

    return posIndex - document.chapterIndexes[chapterIndex];
  }

  int _getAbsParagraphIndexBy({
    required int positionIndex,
    double? trailingEdge,
    double? leadingEdge,
  }) {
    int posIndex = positionIndex;
    if (trailingEdge != null &&
        leadingEdge != null &&
        trailingEdge < _minTrailingEdge &&
        leadingEdge < _minLeadingEdge) {
      posIndex += 1;
    }

    return posIndex;
  }
}
