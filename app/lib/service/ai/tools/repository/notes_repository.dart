import 'package:omnigram/dao/book.dart';
import 'package:omnigram/dao/book_note.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/models/book_note.dart';

class NoteSearchResult {
  NoteSearchResult({
    required this.book,
    required this.note,
  });

  final Book book;
  final BookNote note;

  Map<String, dynamic> toMap() {
    final snippet = _buildSnippet();
    return {
      'bookId': book.id,
      'bookTitle': book.title,
      'author': book.author,
      'noteId': note.id,
      'chapter': note.chapter,
      'snippet': snippet,
      'content': note.content,
      'readerNote': note.readerNote,
      'cfi': note.cfi,
      'updatedAt': note.updateTime.toIso8601String(),
    };
  }

  String _buildSnippet() {
    final readerNote = note.readerNote?.trim();
    if (readerNote != null && readerNote.isNotEmpty) {
      return readerNote;
    }
    final content = note.content.trim();
    if (content.length > 160) {
      return '${content.substring(0, 157)}…';
    }
    return content;
  }
}

class NotesRepository {
  const NotesRepository();

  Future<List<NoteSearchResult>> searchNotes({
    String? keyword,
    int? bookId,
    DateTime? from,
    DateTime? to,
    int limit = 10,
  }) async {
    final query = keyword?.trim();

    final notes = await bookNoteDao.searchBookNotesAdvanced(
      keyword: query,
      bookId: bookId,
      from: from,
      to: to,
      limit: limit,
    );

    if (notes.isEmpty) {
      return const [];
    }

    final bookIds = notes.map((note) => note.bookId).toSet().toList();
    final books = await bookDao.selectBooksByIds(bookIds);
    final bookMap = {for (final book in books) book.id: book};

    final results = <NoteSearchResult>[];
    for (final note in notes) {
      final book = bookMap[note.bookId];
      if (book == null) {
        continue;
      }
      results.add(NoteSearchResult(book: book, note: note));
      if (results.length >= limit) {
        break;
      }
    }

    return results;
  }
}
