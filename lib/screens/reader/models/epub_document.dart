import 'dart:io';
import 'package:flutter/foundation.dart';
import 'epub/_chapter_view_value.dart';
import 'epub/_paragraph.dart';
import 'epub/_parse_result.dart';

class EpubDocument {
  EpubDocument();

  late List<EpubChapter> chapters;
  late List<Paragraph> paragraphs;
  late List<int> chapterIndexes;

  late EpubBook book;

  static Future<EpubDocument> initialize(String path) async {
    final doc = EpubDocument();

    final file = File(path);
    final bytes = await file.readAsBytes();

    doc.book = await EpubReader.readBook(bytes);

    doc.chapters = parseChapters(doc.book);
    final parseParagraphsResult =
        parseParagraphs(doc.chapters, doc.book.Content);
    doc.paragraphs = parseParagraphsResult.flatParagraphs;
    doc.chapterIndexes = (parseParagraphsResult.chapterIndexes);

    if (kDebugMode) {
      print("chapters: ${doc.chapters.length}");
      print("paragraphs: ${doc.paragraphs.length}");
      print("chapterIndexes: ${doc.chapterIndexes.length}");
    }

    return doc;
  }

  ChapterIndex? nextIndex(ChapterIndex index) {
    final abs = (absParagraphIndex(index) ?? 0) + 1;

    if (abs == paragraphs.length - 1) {
      return null;
    }

    if (abs < chapterIndexes[index.chapterIndex + 1]) {
      return ChapterIndex(
        chapter: index.chapter,
        chapterIndex: index.chapterIndex,
        paragraphIndex: index.paragraphIndex + 1,
      );
    } else {
      return ChapterIndex(
        chapter: index.chapter,
        chapterIndex: index.chapterIndex + 1,
        paragraphIndex: 0,
      );
    }
  }

  String getContent(ChapterIndex? index) {
    final abs = absParagraphIndex(index) ?? 0;

    return paragraphs[abs].element.innerHtml;
  }

  String? cfiGenerate(ChapterIndex? index) {
    final chapter = index?.chapter;
    final paragraphIndex = index?.paragraphIndex;
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

    final chapterIndex = chapters.indexWhere((chapter) =>
        chapter.ContentFileName == cparts[0].substring(1) &&
        chapter.Anchor == anchor);

    return chapterIndex == -1
        ? ChapterIndex(
            chapter: null,
            chapterIndex: 0,
            paragraphIndex: paragraphIndex,
          )
        : ChapterIndex(
            chapter: chapters[chapterIndex],
            chapterIndex: chapterIndex,
            paragraphIndex: paragraphIndex,
          );
  }

  int? absParagraphIndex(ChapterIndex? current) {
    return current != null
        ? chapterIndexes[current.chapterIndex] + current.paragraphIndex
        : null;
  }

  double progress(ChapterIndex? current) {
    final pos = absParagraphIndex(current);

    if (pos == null) {
      return 0;
    }
    if (kDebugMode) {
      print('currentParagraphIndex $pos / ${paragraphs.length} ');
    }
    return pos * 100.0 / paragraphs.length;
  }
}
