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

  final paragraphs = chapters.fold<List<Paragraph>>(
    [],
    (acc, next) {
      if (next.ContentFileName == 'text00008.html' ||
          next.ContentFileName == 'text00054.html') {
        print('next.ContentFileName: ${next.ContentFileName}');
      }

      List<dom.Element> elmList = [];
      if (filename != next.ContentFileName) {
        filename = next.ContentFileName;
        final document = chapterDocument(next);
        if (document != null) {
          final result = convertDocumentToElements(document);
          elmList = _removeAllDiv(result);
        }
      }

      if (next.Anchor == null) {
        // last element from document index as chapter index
        chapterIndexes.add(acc.length);
        acc.addAll(elmList
            .map((element) => Paragraph(element, chapterIndexes.length - 1)));

        ranges[next.ContentFileName!] =
            Range(chapterIndexes.last, chapterIndexes.last + elmList.length);
      } else {
        //如果文件名和当前的文件名一致，就应该从当前的这个章节文件的开始位置到结束位置中间查找
        if (filename == next.ContentFileName) {
          //获取当前列表中位置
          final range = ranges[next.ContentFileName]!;

          int index = -1;

          for (var i = range.start; i < range.end; i++) {
            if (acc[i].element.outerHtml.contains('id="${next.Anchor}"') ||
                acc[i].element.outerHtml.contains(
                    'href="${next.ContentFileName}#${next.Anchor}"')) {
              index = i;
              break;
            }
          }

          index == -1
              ? chapterIndexes.add(range.start)
              : chapterIndexes.add(index);
        }
      }
      return acc;
    },
  );

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
