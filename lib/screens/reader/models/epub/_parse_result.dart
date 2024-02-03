import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;
import '_chapter_index.dart';
import '_paragraph.dart';

export 'package:epubx/epubx.dart' hide Image;

class ParseResult {
  const ParseResult(this.epubBook, this.chapters, this.parseResult);

  final EpubBook epubBook;
  final List<EpubChapter> chapters;
  final ParseParagraphsResult parseResult;
}

class ParseParagraphsResult {
  ParseParagraphsResult(this.flatParagraphs, this.chapterIndexes);

  final List<Paragraph> flatParagraphs;
  final List<int> chapterIndexes;
}

List<EpubChapter> parseChapters(EpubBook epubBook) =>
    epubBook.Chapters!.fold<List<EpubChapter>>(
      [],
      (acc, next) {
        acc.add(next);
        next.SubChapters!.forEach(acc.add);
        return acc;
      },
    );

ParseParagraphsResult parseParagraphs(
  List<EpubChapter> chapters,
  EpubContent? content,
) {
  String? filename = '';
  final List<int> chapterIndexes = [];

  final Map<String, Range> ranges = {};

  // List<dom.Element> elmList = [];
//遍历获取所有的章节的元素转换成 dom
  final paragraphs = chapters.fold<List<Paragraph>>([], (eles, next) {
    if (filename != next.ContentFileName) {
      filename = next.ContentFileName;
      final document = chapterDocument(next);
      if (document != null) {
        final result = convertDocumentToElements(document);

        final start = eles.length;
        eles.addAll(result.map((e) => Paragraph(e)));

        //记录每个文件的章节的起始位置和结束位置
        ranges[next.ContentFileName!] = Range(start, eles.length);
      }
    }

    return eles;
  });

  chapterIndexes.add(0);

  for (var i = 1; i < chapters.length; i++) {
    // if

    final chapter = chapters[i];
    final fileRange = ranges[chapter.ContentFileName]!;
    if (chapter.Anchor == null) {
      chapterIndexes.add(fileRange.end);
      continue;
    }

    // range start > acc.length 说明是第一次或者没有找到
    // range start < acc.length 说明找到过

    int start = fileRange.start > chapterIndexes.last
        ? fileRange.start
        : chapterIndexes.last;

    int index = start;
    // print("current  $start: ${chapter.Anchor} ${fileRange.end}");
    for (var i = start; i < fileRange.end; i++) {
      if (paragraphs[i].element.outerHtml.contains('id="${chapter.Anchor}"')) {
        index = i;
        // print("current id: ${chapter.Anchor} $i");
        break;
      }
    }

    chapterIndexes.add(index);

    // if (index != -1) {

    // }
  }

  return ParseParagraphsResult(paragraphs, chapterIndexes);
}

List<dom.Element> convertDocumentToElements(dom.Document document) =>
    document.getElementsByTagName('body').first.children;

List<dom.Element> _removeAllDiv(List<dom.Element> elements) {
  final List<dom.Element> result = [];

  for (final node in elements) {
    if (node.localName == 'div' && node.children.length > 1) {
      result.addAll(_removeAllDiv(node.children));
    } else {
      result.add(node);
    }
  }

  return result;
}

dom.Document? chapterDocument(EpubChapter? chapter) {
  if (chapter == null) {
    return null;
  }
  final html = chapter.HtmlContent!.replaceAllMapped(
      RegExp(r'<\s*([^\s>]+)([^>]*)\/\s*>'),
      (match) => '<${match.group(1)}${match.group(2)}></${match.group(1)}>');
  final regExp = RegExp(
    r'<body.*?>.+?</body>',
    caseSensitive: false,
    multiLine: true,
    dotAll: true,
  );
  final matches = regExp.firstMatch(html)!;

  return parse(matches.group(0));
}
