import 'package:omnigram/dao/book_note.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/models/book_note.dart';

/// A single clipping entry parsed from Kindle's My Clippings.txt.
class KindleClipping {
  final String bookTitle;
  final String? author;
  final String type; // 'highlight', 'note', or 'bookmark'
  final String content;
  final String? location;
  final DateTime? createdAt;

  const KindleClipping({
    required this.bookTitle,
    this.author,
    required this.type,
    required this.content,
    this.location,
    this.createdAt,
  });
}

/// Result summary after importing Kindle clippings into the library.
class KindleImportResult {
  final int importedCount;
  final int matchedBooks;
  final int skippedCount;

  const KindleImportResult({
    required this.importedCount,
    required this.matchedBooks,
    required this.skippedCount,
  });
}

/// Service for parsing and importing Kindle My Clippings.txt files.
class KindleImport {
  KindleImport._();

  static const _separator = '==========';
  static const _defaultColor = 'FFF9A825';

  // Multi-language keywords for clipping type detection
  static const _highlightKeywords = [
    'Highlight',
    '标注',
    'ハイライト',
    'Markierung',
    'Subrayado',
    'Surlignement',
  ];
  static const _noteKeywords = [
    'Note',
    '笔记',
    'メモ',
    'Notiz',
    'Nota',
  ];
  static const _bookmarkKeywords = [
    'Bookmark',
    '书签',
    'ブックマーク',
  ];

  /// Parse a My Clippings.txt file content into a list of [KindleClipping].
  static List<KindleClipping> parseClippings(String content) {
    final entries = content.split(_separator);
    final clippings = <KindleClipping>[];

    for (final entry in entries) {
      final trimmed = entry.trim();
      if (trimmed.isEmpty) continue;

      final lines = trimmed.split('\n').map((l) => l.trim()).toList();
      // Minimum: title line + metadata line + blank + content
      if (lines.length < 3) continue;

      final titleLine = lines[0];
      final metadataLine = lines[1];

      // Extract title and author from first line
      // Format: "Book Title (Author Name)" or just "Book Title"
      final (title, author) = _parseTitleAuthor(titleLine);
      if (title.isEmpty) continue;

      // Detect type from metadata line
      final type = _detectType(metadataLine);
      if (type == 'bookmark') continue; // skip bookmarks

      // Extract location from metadata line
      final location = _parseLocation(metadataLine);

      // Content: everything after the blank line following metadata
      // Lines[0] = title, Lines[1] = metadata, Lines[2] = blank, Lines[3..] = content
      final contentStartIndex =
          lines.length > 2 && lines[2].isEmpty ? 3 : 2;
      if (contentStartIndex >= lines.length) continue;

      final noteContent =
          lines.sublist(contentStartIndex).join('\n').trim();
      if (noteContent.isEmpty) continue;

      clippings.add(KindleClipping(
        bookTitle: title,
        author: author,
        type: type,
        content: noteContent,
        location: location,
      ));
    }

    return clippings;
  }

  /// Import parsed clippings into the Omnigram library by matching against
  /// existing books. Returns an import result summary.
  static Future<KindleImportResult> importToLibrary(
    List<KindleClipping> clippings,
    List<Book> books,
  ) async {
    // Group clippings by book title
    final grouped = <String, List<KindleClipping>>{};
    for (final clip in clippings) {
      grouped.putIfAbsent(clip.bookTitle, () => []).add(clip);
    }

    final dao = BookNoteDao();
    var importedCount = 0;
    var skippedCount = 0;
    final matchedBookIds = <int>{};

    for (final entry in grouped.entries) {
      final clipTitle = entry.key;
      final bookClippings = entry.value;

      final matchedBook = _findBestMatch(clipTitle, books);
      if (matchedBook == null) {
        skippedCount += bookClippings.length;
        continue;
      }

      matchedBookIds.add(matchedBook.id);

      // Fetch existing notes for dedup
      final existingNotes =
          await dao.selectBookNotesByBookId(matchedBook.id);
      final existingContents =
          existingNotes.map((n) => n.content).toSet();

      // Merge adjacent highlight + note pairs
      final merged = _mergeHighlightNotePairs(bookClippings);

      for (final item in merged) {
        if (existingContents.contains(item.content)) continue;

        final now = DateTime.now();
        final note = BookNote(
          bookId: matchedBook.id,
          content: item.content,
          cfi: '',
          chapter: '',
          type: 'highlight',
          color: _defaultColor,
          readerNote: item.readerNote,
          createTime: now,
          updateTime: now,
        );

        await dao.save(note);
        importedCount++;
      }
    }

    return KindleImportResult(
      importedCount: importedCount,
      matchedBooks: matchedBookIds.length,
      skippedCount: skippedCount,
    );
  }

  // --- Private helpers ---

  static (String title, String? author) _parseTitleAuthor(String line) {
    // Remove BOM if present
    final cleaned =
        line.startsWith('\uFEFF') ? line.substring(1) : line;

    // Find last '(' to separate title from author
    final lastParen = cleaned.lastIndexOf('(');
    if (lastParen > 0 && cleaned.endsWith(')')) {
      final title = cleaned.substring(0, lastParen).trim();
      final author =
          cleaned.substring(lastParen + 1, cleaned.length - 1).trim();
      return (title, author.isEmpty ? null : author);
    }

    return (cleaned.trim(), null);
  }

  static String _detectType(String metadataLine) {
    final lower = metadataLine.toLowerCase();

    for (final kw in _bookmarkKeywords) {
      if (metadataLine.contains(kw) || lower.contains(kw.toLowerCase())) {
        return 'bookmark';
      }
    }
    for (final kw in _noteKeywords) {
      if (metadataLine.contains(kw) || lower.contains(kw.toLowerCase())) {
        return 'note';
      }
    }
    for (final kw in _highlightKeywords) {
      if (metadataLine.contains(kw) || lower.contains(kw.toLowerCase())) {
        return 'highlight';
      }
    }

    // Default to highlight if unknown
    return 'highlight';
  }

  static String? _parseLocation(String metadataLine) {
    // Try to extract location/position numbers
    final locMatch =
        RegExp(r'(?:Loc(?:ation)?|位置|loc)\.\s*(\d+(?:-\d+)?)', caseSensitive: false)
            .firstMatch(metadataLine);
    if (locMatch != null) return locMatch.group(1);

    final posMatch =
        RegExp(r'#(\d+(?:-\d+)?)').firstMatch(metadataLine);
    if (posMatch != null) return posMatch.group(1);

    return null;
  }

  static Book? _findBestMatch(String clipTitle, List<Book> books) {
    final lower = clipTitle.toLowerCase().trim();
    if (lower.isEmpty) return null;

    for (final book in books) {
      if (book.isDeleted) continue;
      final bookLower = book.title.toLowerCase().trim();
      if (bookLower.isEmpty) continue;

      if (bookLower == lower ||
          bookLower.contains(lower) ||
          lower.contains(bookLower)) {
        return book;
      }
    }
    return null;
  }

  /// Merge adjacent highlight + note pairs: if a note immediately follows
  /// a highlight for the same book and location, attach the note as
  /// readerNote on the highlight.
  static List<_MergedClipping> _mergeHighlightNotePairs(
    List<KindleClipping> clippings,
  ) {
    final result = <_MergedClipping>[];

    for (var i = 0; i < clippings.length; i++) {
      final clip = clippings[i];

      if (clip.type == 'highlight') {
        String? readerNote;

        // Check if next clipping is a note for the same location
        if (i + 1 < clippings.length) {
          final next = clippings[i + 1];
          if (next.type == 'note' &&
              next.bookTitle == clip.bookTitle &&
              next.location == clip.location &&
              clip.location != null) {
            readerNote = next.content;
            i++; // skip the paired note
          }
        }

        result.add(_MergedClipping(
          content: clip.content,
          readerNote: readerNote,
        ));
      } else if (clip.type == 'note') {
        // Standalone note — treat as highlight with reader note
        result.add(_MergedClipping(
          content: clip.content,
          readerNote: null,
        ));
      }
    }

    return result;
  }
}

class _MergedClipping {
  final String content;
  final String? readerNote;

  const _MergedClipping({required this.content, this.readerNote});
}
