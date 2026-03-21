import 'package:omnigram/dao/book.dart';
import 'package:omnigram/dao/book_note.dart';
import 'package:omnigram/models/book_note.dart';
import 'package:omnigram/models/search_note_group.dart';
import 'package:omnigram/models/search_result_data.dart';

class SearchRepository {
  const SearchRepository();

  Future<SearchResultData> search(
    String keyword, {
    int? bookId,
    DateTime? from,
    DateTime? to,
    int? limit,
  }) async {
    final query = keyword.trim();
    if (query.isEmpty) {
      return SearchResultData.empty;
    }

    final books = await bookDao.searchBooks(query);
    final notes = await bookNoteDao.searchBookNotesAdvanced(
      keyword: query,
      bookId: bookId,
      from: from,
      to: to,
      limit: limit,
    );

    if (notes.isEmpty) {
      return SearchResultData(
          books: books, noteGroups: const <SearchNoteGroup>[]);
    }

    final notesByBookId = <int, List<BookNote>>{};
    for (final note in notes) {
      notesByBookId.putIfAbsent(note.bookId, () => []).add(note);
    }

    final relatedBookIds = notesByBookId.keys.toList(growable: false);
    final relatedBooks = await bookDao.selectBooksByIds(relatedBookIds);
    final relatedBookMap = {
      for (final book in relatedBooks) book.id: book,
    };

    final seenBookIds = <int>{};
    final noteGroups = <SearchNoteGroup>[];
    for (final note in notes) {
      final bookId = note.bookId;
      if (!seenBookIds.add(bookId)) {
        continue;
      }

      final book = relatedBookMap[bookId];
      if (book == null) {
        continue;
      }

      final groupNotes = List<BookNote>.from(notesByBookId[bookId] ?? const []);
      noteGroups.add(
        SearchNoteGroup(
          book: book,
          notes: groupNotes,
        ),
      );
    }

    return SearchResultData(books: books, noteGroups: noteGroups);
  }
}
