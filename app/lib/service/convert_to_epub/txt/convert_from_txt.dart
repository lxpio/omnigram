import 'dart:convert';
import 'dart:io';

import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/models/chapter_split_presets.dart';
import 'package:omnigram/service/convert_to_epub/create_epub.dart';
import 'package:omnigram/service/convert_to_epub/section.dart';
import 'package:omnigram/utils/log/common.dart';
import 'package:charset/charset.dart';
import 'package:path/path.dart' as path;

String readFileWithEncoding(File file) {
  bool checkGarbled(String content) {
    final garbledPattern = RegExp(
        r'Õ|Ê|�|Ç|³|¾|Ð|Ó|Î|Á|É|�|Ã|Ä|Å|Æ|Ë|Ì|Í|Ï|Ò|Ó|Ô|Õ|Ö|Ù|Ú|Û|Ü|Ý|à|á|â|ã|ä|å|æ|è|é|ê|ë|ì|í|î|ï|ð|ñ|ò|ó|ô|õ|ö|ù|ú|û|ü|ý|ÿ|\x00-\x1F\x7F|｡｢｣､･ｦｧｨｩｪｫｬｭｮｯｰｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ|€|�');
    final sampleContent =
        content.length > 500 ? content.substring(0, 500) : content;

    final matches = garbledPattern.allMatches(sampleContent);

    final garbledCount = matches.length;

    return garbledCount / sampleContent.length > 20 / 500;
  }

  final decoder = {
    'utf8': utf8.decode,
    'gbk': gbk.decode,
    'latin1': latin1.decode,
    'utf16': utf16.decode,
    'utf32': utf32.decode,
  };

  for (final entry in decoder.entries) {
    try {
      AnxLog.info('Convert: Reading file with encoding: ${entry.key}');
      final content = entry.value(file.readAsBytesSync());
      if (!checkGarbled(content)) {
        return content;
      }
      AnxLog.info('Convert: Detected garbled text ${entry.key}');
    } catch (e) {
      AnxLog.warning(
          'Convert: Failed to read file with encoding: ${entry.key}');
    }
  }

  throw Exception('Convert: Failed to read file with any encoding');
}

String _normalizeLineBreaks(String input) {
  return input.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
}

List<Section> _buildSectionsFromMatches({
  required String content,
  required List<RegExpMatch> matches,
  required String fallbackTitle,
}) {
  final sections = <Section>[];
  const singleLevel = 1;

  final firstMatch = matches.first;
  if (firstMatch.start > 0) {
    final intro = content.substring(0, firstMatch.start).trim();
    if (intro.isNotEmpty) {
      sections.add(Section('', intro, singleLevel));
    }
  }

  for (var i = 0; i < matches.length; i++) {
    final match = matches[i];
    final title = match.group(0)?.trim() ?? 'Chapter ${i + 1}';

    final startPos = match.end;
    final endPos =
        i < matches.length - 1 ? matches[i + 1].start : content.length;

    final rawBody = content.substring(startPos, endPos);
    final body = rawBody.trim();

    sections.add(Section(title, body, singleLevel));
  }

  if (sections.isEmpty) {
    sections.add(Section(fallbackTitle, content.trim(), singleLevel));
  }

  return sections;
}

List<Section> _fallbackChunking(String filename, String content) {
  final sections = <Section>[];
  const singleLevel = 1;
  if (content.length <= 20000) {
    sections.add(Section(filename, content.trim(), singleLevel));
    return sections;
  }

  var startIndex = 0;
  while (startIndex < content.length) {
    final endIndex = startIndex + 20000;
    if (endIndex >= content.length) {
      sections.add(Section('No.${sections.length + 1}',
          content.substring(startIndex).trim(), singleLevel));
      break;
    }

    final nextNewline = content.indexOf('\n', endIndex);
    final chapterEndIndex = nextNewline == -1 ? content.length : nextNewline;

    sections.add(Section('No.${sections.length + 1}',
        content.substring(startIndex, chapterEndIndex).trim(), singleLevel));
    startIndex = chapterEndIndex + 1;
  }

  return sections;
}

Future<File> convertFromTxt(File file) async {
  // Use path.basename to extract filename cross-platform (handles both / and \)
  var filename = path.basenameWithoutExtension(file.path);

  final titleString =
      RegExp(r'(?<=《)[^》]+').firstMatch(filename)?.group(0) ?? filename;
  final authorString =
      RegExp(r'(?<=作者：).*').firstMatch(filename)?.group(0) ?? 'Unknown';

  AnxLog.info('convert from txt. title: $titleString, author: $authorString');

  // read file
  String content = readFileWithEncoding(file);
  content = _normalizeLineBreaks(content);

  // content = content.replaceAll(RegExp(r'(\n*|^)(\s|　)+'), '\n');

  AnxLog.info('convert from txt. content: ${content.length}');

  final rule = Prefs().activeChapterSplitRule;
  RegExp patternStr;
  try {
    patternStr = rule.buildRegExp();
  } catch (error) {
    AnxLog.warning(
        'Convert: Invalid chapter split rule ${rule.name}, using default. $error');
    patternStr = getDefaultChapterSplitRule().buildRegExp();
  }

  final matches = patternStr.allMatches(content).toList();
  AnxLog.info('matches: ${matches.length}');

  List<Section> sections;
  if (matches.isEmpty) {
    AnxLog.info('Convert: No chapters matched, using fallback chunking');
    sections = _fallbackChunking(filename, content);
    AnxLog.info('Convert: Created ${sections.length} sections via fallback');
  } else {
    AnxLog.info('Convert: Building ${matches.length} sections from matches');
    sections = _buildSectionsFromMatches(
      content: content,
      matches: matches,
      fallbackTitle: filename,
    );
    AnxLog.info('Convert: Created ${sections.length} sections');
  }

  AnxLog.info('Convert: Starting EPUB creation...');
  try {
    final epubFile = await createEpub(titleString, authorString, sections);
    AnxLog.info('Convert: EPUB created successfully at ${epubFile.path}');
    return epubFile;
  } catch (e) {
    AnxLog.severe('Convert: Failed to create EPUB: $e');
    rethrow;
  }
}
