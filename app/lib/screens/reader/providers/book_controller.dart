import 'package:flutter/material.dart';
import 'package:omnigram/screens/reader/models/epub_document.dart';

import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../models/epub/_chapter_index.dart';

const _minTrailingEdge = 0.55;
const _minLeadingEdge = -0.05;

class BookController {
  BookController({
    // required this.ref,
    required this.document,
  });
  // final Ref ref;
  final EpubDocument document;

  late Function(ChapterIndex? index) updater;

  late ItemScrollController? itemScrollController;
  late ItemPositionsListener itemPositionListener;
  // late ScrollOffsetController scrollOffsetController;
  // final ValueNotifier<ChapterIndex?> index = ValueNotifier(null);

  void initialize(Function(ChapterIndex? index) hook) {
    itemScrollController = ItemScrollController();

    itemPositionListener = ItemPositionsListener.create();
    // scrollOffsetController = ScrollOffsetController();
    updater = hook;
    itemPositionListener.itemPositions.addListener(_listener);
  }

  void dispose() {
    itemPositionListener.itemPositions.removeListener(_listener);
  }

//_listener 监听界面滚动，获取当前阅读的章节和段落
  void _listener() {
    if (document.paragraphs.isEmpty || itemPositionListener.itemPositions.value.isEmpty) {
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

    final current = ChapterIndex(
      // chapter: chapterIndex >= 0 ? document.chapters[chapterIndex] : null,
      // 这里是相对路径
      chapterIndex: chapterIndex,
      paragraphIndex: paragraphIndex,
    );
    updater(current);
  }

  void scrollToChapter(int chapterIndex) {
    if (document.chapters.length > chapterIndex && chapterIndex >= 0) {
      final dest = document.chapterIndexes[chapterIndex];

      itemScrollController?.scrollTo(
        index: dest,
        duration: const Duration(milliseconds: 300),
        alignment: 0,
        curve: Curves.decelerate,
      );
    }
  }

  void scrollToPreviousChapter() {
    final position = itemPositionListener.itemPositions.value.first;

    final posIndex = _getAbsParagraphIndexBy(
      positionIndex: position.index,
      trailingEdge: position.itemTrailingEdge,
      leadingEdge: position.itemLeadingEdge,
    );

    final chapterIndex = _getChapterIndex(posIndex);

    scrollToChapter(chapterIndex - 1);
  }

  void scrollToNextChapter() {
    final position = itemPositionListener.itemPositions.value.first;

    final posIndex = _getAbsParagraphIndexBy(
      positionIndex: position.index,
      trailingEdge: position.itemTrailingEdge,
      leadingEdge: position.itemLeadingEdge,
    );

    final chapterIndex = _getChapterIndex(posIndex);

    scrollToChapter(chapterIndex + 1);
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
