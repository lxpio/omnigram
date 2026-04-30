import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:path/path.dart' as p;

/// One linear chapter pulled out of a local EPUB. The order of chapters in a
/// `List<EpubChapter>` is the EPUB spine order — the same order the reader
/// shows them — so client-side `chapterIndex` lines up with the server's
/// spine-based index.
class EpubChapter {
  const EpubChapter({
    required this.href,
    required this.title,
    required this.plainText,
  });

  final String href;
  final String title;
  final String plainText;
}

/// Parse the EPUB at [filePath] and return its linear chapter list with plain
/// text extracted. Skips non-linear spine items (covers, ads).
///
/// Implementation detail: this is a deliberately tiny parser that handles only
/// what audiobook playback needs (manifest + spine + XHTML → text). It uses
/// regex on the OPF rather than a full XML parser because the OPF schema is
/// well-defined and stable enough that targeted regex is robust in practice.
Future<List<EpubChapter>> readEpubChapters(String filePath) async {
  final bytes = await File(filePath).readAsBytes();
  final archive = ZipDecoder().decodeBytes(bytes);

  final container = _findFile(archive, 'META-INF/container.xml');
  if (container == null) {
    throw const FormatException('EPUB missing META-INF/container.xml');
  }
  final containerStr = _utf8(container);
  final rootfileMatch =
      RegExp(r'rootfile[^>]*full-path="([^"]+)"').firstMatch(containerStr);
  if (rootfileMatch == null) {
    throw const FormatException('EPUB container.xml has no rootfile');
  }
  final opfPath = rootfileMatch.group(1)!;
  final opfDir = p.posix.dirname(opfPath);

  final opfFile = _findFile(archive, opfPath);
  if (opfFile == null) {
    throw FormatException('EPUB OPF not found at $opfPath');
  }
  final opfStr = _utf8(opfFile);

  final manifest = <String, String>{};
  for (final m
      in RegExp(r'<item\b([^/>]*)/?>', dotAll: true).allMatches(opfStr)) {
    final attrs = m.group(1)!;
    final id = RegExp(r'id="([^"]+)"').firstMatch(attrs)?.group(1);
    final href = RegExp(r'href="([^"]+)"').firstMatch(attrs)?.group(1);
    if (id != null && href != null) manifest[id] = href;
  }

  final spineIds = <String>[];
  for (final m in RegExp(r'<itemref\b([^/>]*)/?>').allMatches(opfStr)) {
    final attrs = m.group(1)!;
    final idref = RegExp(r'idref="([^"]+)"').firstMatch(attrs)?.group(1);
    if (idref == null) continue;
    final linear = RegExp(r'linear="([^"]+)"').firstMatch(attrs)?.group(1);
    if (linear == 'no') continue;
    spineIds.add(idref);
  }

  final chapters = <EpubChapter>[];
  for (final id in spineIds) {
    final href = manifest[id];
    if (href == null) continue;
    final fullPath = opfDir.isEmpty || opfDir == '.'
        ? href
        : p.posix.normalize('$opfDir/$href');
    final file = _findFile(archive, fullPath);
    if (file == null) continue;
    final xhtmlStr = _utf8(file);
    final doc = html_parser.parse(xhtmlStr);
    final title = _extractTitle(doc);
    final body = doc.querySelector('body') ?? doc;
    final plainText = _extractText(body);
    if (plainText.trim().isEmpty) continue;
    chapters.add(EpubChapter(href: href, title: title, plainText: plainText));
  }
  return chapters;
}

ArchiveFile? _findFile(Archive archive, String name) {
  for (final f in archive) {
    if (f.name == name) return f;
  }
  return null;
}

String _utf8(ArchiveFile f) {
  return utf8.decode(f.content, allowMalformed: true);
}

String _extractTitle(dom.Document doc) {
  for (final sel in const ['h1', 'h2', 'h3', 'title']) {
    final el = doc.querySelector(sel);
    final text = el?.text.trim();
    if (text != null && text.isNotEmpty) return text;
  }
  return '';
}

const _blockTags = {
  'p', 'div', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
  'li', 'br', 'tr', 'blockquote', 'pre', 'section', 'article',
};

String _extractText(dom.Node node) {
  final buf = StringBuffer();
  void walk(dom.Node n) {
    if (n is dom.Text) {
      buf.write(n.text);
    } else if (n is dom.Element) {
      final tag = n.localName?.toLowerCase();
      final isBlock = tag != null && _blockTags.contains(tag);
      if (isBlock) buf.write('\n');
      for (final child in n.nodes) {
        walk(child);
      }
      if (isBlock) buf.write('\n');
    }
  }

  walk(node);
  return buf
      .toString()
      .replaceAll(RegExp(r'[ \t]+'), ' ')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
}
