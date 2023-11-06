import 'dart:io';
import 'package:flutter/foundation.dart';
import 'epub/models/paragraph.dart';
import 'epub/models/parse_result.dart';

class EpubDocument {
  EpubDocument({required this.path, required this.epubCfi});
  final String path;
  final String? epubCfi;

  late List<EpubChapter> chapters;
  late List<Paragraph> paragraphs;
  late List<int> chapterIndexes;

  late EpubBook book;

  Future<void> initialize() async {
    book = await open();

    chapters = parseChapters(book);
    final parseParagraphsResult = parseParagraphs(chapters, book.Content);
    paragraphs = parseParagraphsResult.flatParagraphs;
    chapterIndexes = (parseParagraphsResult.chapterIndexes);

    if (kDebugMode) {
      print("chapters: ${chapters.length}");
      print("paragraphs: ${paragraphs.length}");
      print("chapterIndexes: ${chapterIndexes.length}");
    }
  }

  Future<EpubBook> open() async {
    final file = File(path);
    final bytes = await file.readAsBytes();
    return EpubReader.readBook(bytes);
  }
}
