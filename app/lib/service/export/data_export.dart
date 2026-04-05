import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:omnigram/dao/book.dart';
import 'package:omnigram/dao/book_note.dart';
import 'package:omnigram/dao/concept_tag.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/models/book_note.dart';
import 'package:omnigram/utils/convert_string_to_uint8list.dart';
import 'package:omnigram/utils/save_file_to_download.dart';

class DataExport {
  DataExport._();

  /// Export all notes from all books as a single Markdown file.
  /// Returns the file path on success, null if no notes exist.
  static Future<String?> exportAllNotes() async {
    final bookDao = BookDao();
    final noteDao = BookNoteDao();
    final books = await bookDao.selectNotDeleteBooks();

    final buffer = StringBuffer();
    buffer.writeln('# Omnigram Notes Export');
    buffer.writeln(
        '> Exported on ${DateFormat('yyyy-MM-dd').format(DateTime.now())}');
    buffer.writeln();

    int noteCount = 0;

    for (final book in books) {
      final notes = await noteDao.selectBookNotesByBookId(book.id);
      if (notes.isEmpty) continue;

      buffer.writeln('---');
      buffer.writeln();
      buffer.writeln('## ${book.title} — ${book.author}');
      buffer.writeln();

      // Group by chapter
      final byChapter = <String, List<BookNote>>{};
      for (final note in notes) {
        final chapter = note.chapter.isEmpty ? 'Unknown' : note.chapter;
        byChapter.putIfAbsent(chapter, () => []).add(note);
      }

      for (final entry in byChapter.entries) {
        buffer.writeln('### ${entry.key}');
        buffer.writeln();
        for (final note in entry.value) {
          buffer.writeln('> ${note.content}');
          if (note.readerNote != null && note.readerNote!.trim().isNotEmpty) {
            buffer.writeln();
            buffer.writeln(note.readerNote);
          }
          buffer.writeln();
          noteCount++;
        }
      }
    }

    if (noteCount == 0) return null;

    final fileName =
        'omnigram_notes_${DateFormat('yyyyMMdd').format(DateTime.now())}.md';
    final filePath = await saveFileToDownload(
      bytes: convertStringToUint8List(buffer.toString()),
      fileName: fileName,
      mimeType: 'text/markdown',
    );
    return filePath;
  }

  /// Export knowledge network (concept tags + edges) as JSON.
  /// Returns the file path on success, null if no data exists.
  static Future<String?> exportKnowledge() async {
    final dao = ConceptTagDao();
    final tags = await dao.getAll();
    final edges = await dao.getAllEdges();

    if (tags.isEmpty) return null;

    // Build name lookup for edges
    final tagById = <int, ConceptTag>{};
    for (final t in tags) {
      if (t.id != null) tagById[t.id!] = t;
    }

    // Get book names for context
    final bookDao = BookDao();
    final books = await bookDao.selectNotDeleteBooks();
    final bookById = <int, Book>{};
    for (final b in books) {
      bookById[b.id] = b;
    }

    final nodes = tags
        .map((t) => <String, dynamic>{
              'name': t.name,
              'book': bookById[t.bookId]?.title ?? 'Unknown',
              'source': t.source ?? '',
            })
        .toList();

    final edgeList = edges
        .where((e) =>
            tagById.containsKey(e.sourceTagId) &&
            tagById.containsKey(e.targetTagId))
        .map((e) => <String, dynamic>{
              'source': tagById[e.sourceTagId]!.name,
              'target': tagById[e.targetTagId]!.name,
              'weight': e.weight,
              'reason': e.reason ?? '',
            })
        .toList();

    final data = <String, dynamic>{
      'exported_at': DateTime.now().toIso8601String(),
      'nodes': nodes,
      'edges': edgeList,
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    final fileName =
        'omnigram_knowledge_${DateFormat('yyyyMMdd').format(DateTime.now())}.json';
    final filePath = await saveFileToDownload(
      bytes: convertStringToUint8List(jsonString),
      fileName: fileName,
      mimeType: 'application/json',
    );
    return filePath;
  }
}
