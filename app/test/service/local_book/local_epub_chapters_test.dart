import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/service/local_book/local_epub_chapters.dart';
import 'package:path/path.dart' as p;

/// Build a minimal EPUB at the given [path] with [chapters] spine items.
/// Manifest deliberately uses `media-type="application/xhtml+xml"` (with the
/// slash that broke the original regex) and includes both self-closing and
/// non-self-closing `<item>` forms to exercise both branches.
String _buildEpub(
  String path, {
  required List<({String href, String title, String body})> chapters,
}) {
  final archive = Archive();
  archive.add(ArchiveFile('mimetype', 20, utf8.encode('application/epub+zip')));

  const containerXml = '''<?xml version="1.0"?>
<container xmlns="urn:oasis:names:tc:opendocument:xmlns:container" version="1.0">
  <rootfiles><rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/></rootfiles>
</container>''';
  archive.add(ArchiveFile('META-INF/container.xml', containerXml.length,
      utf8.encode(containerXml)));

  final manifestItems = StringBuffer();
  final spineItems = StringBuffer();
  for (var i = 0; i < chapters.length; i++) {
    final c = chapters[i];
    // Mix self-closing / non-self-closing tag styles.
    if (i.isEven) {
      manifestItems.writeln(
          '    <item href="${c.href}" id="ch$i" media-type="application/xhtml+xml"/>');
    } else {
      manifestItems.writeln(
          '    <item href="${c.href}" id="ch$i" media-type="application/xhtml+xml"></item>');
    }
    spineItems.writeln('    <itemref idref="ch$i"/>');
  }
  final opf = '''<?xml version="1.0" encoding="UTF-8"?>
<package xmlns="http://www.idpf.org/2007/opf" version="2.0" unique-identifier="bid">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:identifier id="bid">test</dc:identifier>
    <dc:title>Test Book</dc:title>
  </metadata>
  <manifest>
$manifestItems  </manifest>
  <spine>
$spineItems  </spine>
</package>''';
  archive.add(
      ArchiveFile('OEBPS/content.opf', opf.length, utf8.encode(opf)));

  for (final c in chapters) {
    final xhtml = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml"><head><title>${c.title}</title></head>
<body><h1>${c.title}</h1>${c.body}</body></html>''';
    archive.add(ArchiveFile('OEBPS/${c.href}', xhtml.length, utf8.encode(xhtml)));
  }

  final bytes = ZipEncoder().encode(archive);
  File(path).writeAsBytesSync(bytes);
  return path;
}

void main() {
  late String tmpRoot;

  setUp(() {
    tmpRoot = Directory.systemTemp.createTempSync('epub_test_').path;
  });

  tearDown(() {
    try {
      Directory(tmpRoot).deleteSync(recursive: true);
    } catch (_) {}
  });

  test('parses manifest items with slash-containing media-type', () async {
    // Regression: original parser used `[^/>]*` to capture attributes which
    // tripped on `media-type="application/xhtml+xml"` — a real-world Epubor
    // book ended up with 0 chapters because every item was truncated.
    final epubPath = p.join(tmpRoot, 'sample.epub');
    _buildEpub(epubPath, chapters: [
      (href: 'cover.html', title: 'Cover', body: '<p>cover</p>'),
      (
        href: 'ch1.html',
        title: 'Chapter One',
        body: '<p>Hello world. This is a test sentence.</p>',
      ),
      (
        href: 'ch2.html',
        title: 'Chapter Two',
        body: '<p>Second chapter body text here.</p>',
      ),
    ]);

    final chapters = await readEpubChapters(epubPath);
    expect(chapters, hasLength(3));
    expect(chapters[0].href, 'cover.html');
    expect(chapters[1].href, 'ch1.html');
    expect(chapters[2].href, 'ch2.html');
    expect(chapters[1].title, 'Chapter One');
    expect(chapters[1].plainText, contains('Hello world'));
  });

  test('skips spine items marked linear="no"', () async {
    final epubPath = p.join(tmpRoot, 'sample.epub');
    final archive = Archive();
    archive.add(
        ArchiveFile('mimetype', 20, utf8.encode('application/epub+zip')));
    const container = '''<?xml version="1.0"?>
<container xmlns="urn:oasis:names:tc:opendocument:xmlns:container" version="1.0">
  <rootfiles><rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/></rootfiles>
</container>''';
    archive.add(ArchiveFile(
        'META-INF/container.xml', container.length, utf8.encode(container)));
    const opf = '''<?xml version="1.0"?>
<package xmlns="http://www.idpf.org/2007/opf" version="2.0" unique-identifier="bid">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:identifier id="bid">x</dc:identifier>
    <dc:title>x</dc:title>
  </metadata>
  <manifest>
    <item href="ch1.html" id="ch1" media-type="application/xhtml+xml"/>
    <item href="ch2.html" id="ch2" media-type="application/xhtml+xml"/>
  </manifest>
  <spine>
    <itemref idref="ch1"/>
    <itemref idref="ch2" linear="no"/>
  </spine>
</package>''';
    archive
        .add(ArchiveFile('OEBPS/content.opf', opf.length, utf8.encode(opf)));
    const ch1 =
        '<html><body><h1>One</h1><p>linear chapter content</p></body></html>';
    const ch2 =
        '<html><body><h1>Two</h1><p>excluded back matter</p></body></html>';
    archive.add(ArchiveFile('OEBPS/ch1.html', ch1.length, utf8.encode(ch1)));
    archive.add(ArchiveFile('OEBPS/ch2.html', ch2.length, utf8.encode(ch2)));
    File(epubPath).writeAsBytesSync(ZipEncoder().encode(archive));

    final chapters = await readEpubChapters(epubPath);
    expect(chapters, hasLength(1));
    expect(chapters[0].href, 'ch1.html');
  });

  test('falls back to first short paragraph as chapter title (no h1/h2)', () async {
    // Real-world Epubor exports don't put chapter titles in heading tags —
    // they're styled `<p>`s. Without a fallback the chapter list shows nothing
    // but #1 / #2.
    final epubPath = p.join(tmpRoot, 'sample.epub');
    _buildEpub(epubPath, chapters: [
      (
        href: 'ch1.html',
        title: '',
        body: '<p>五　治伤</p><p>仪琳和那女童到了厅外，问道：好长的一段正文。</p>',
      ),
    ]);
    // strip <h1> from the body the helper inserted by writing a custom one.
    // Easiest: rebuild without _buildEpub's auto-h1.
    final archive = Archive();
    archive.add(
        ArchiveFile('mimetype', 20, utf8.encode('application/epub+zip')));
    const container = '''<?xml version="1.0"?>
<container xmlns="urn:oasis:names:tc:opendocument:xmlns:container" version="1.0">
  <rootfiles><rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/></rootfiles>
</container>''';
    archive.add(ArchiveFile(
        'META-INF/container.xml', container.length, utf8.encode(container)));
    const opf = '''<?xml version="1.0"?>
<package xmlns="http://www.idpf.org/2007/opf" version="2.0" unique-identifier="bid">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:identifier id="bid">x</dc:identifier>
    <dc:title>x</dc:title>
  </metadata>
  <manifest>
    <item href="ch1.html" id="ch1" media-type="application/xhtml+xml"/>
  </manifest>
  <spine><itemref idref="ch1"/></spine>
</package>''';
    archive
        .add(ArchiveFile('OEBPS/content.opf', opf.length, utf8.encode(opf)));
    const ch1 =
        '<html><head><title></title></head><body><p>五　治伤</p><p>正文很长，仪琳和那女童到了厅外，问道：哎呀这是一句完整的话。</p></body></html>';
    archive.add(ArchiveFile('OEBPS/ch1.html', ch1.length, utf8.encode(ch1)));
    File(epubPath).writeAsBytesSync(ZipEncoder().encode(archive));

    final chapters = await readEpubChapters(epubPath);
    expect(chapters, hasLength(1));
    expect(chapters[0].title, '五　治伤');
  });

  test('extracts paragraph breaks for sentence splitter to consume', () async {
    final epubPath = p.join(tmpRoot, 'sample.epub');
    _buildEpub(epubPath, chapters: [
      (
        href: 'ch1.html',
        title: 'C',
        body: '<p>First paragraph here.</p><p>Second paragraph here.</p>',
      ),
    ]);
    final chapters = await readEpubChapters(epubPath);
    expect(chapters, hasLength(1));
    expect(chapters.first.plainText, contains('First paragraph'));
    expect(chapters.first.plainText, contains('Second paragraph'));
    // Two block-level <p>s should produce a paragraph break (\n\n).
    expect(chapters.first.plainText, contains('\n\n'));
  });
}
