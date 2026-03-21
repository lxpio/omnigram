import 'package:omnigram/dao/book.dart';
import 'package:omnigram/models/book.dart';

class BookSearchResult {
  BookSearchResult(this.book);

  final Book book;

  Map<String, dynamic> toMap() {
    return {
      'bookId': book.id,
      'title': book.title,
      'author': book.author,
      'description': book.description,
      'readingPercentage': book.readingPercentage,
      'lastReadPosition': book.lastReadPosition,
      'groupId': book.groupId,
      'updatedAt': book.updateTime.toIso8601String(),
      'isDeleted': book.isDeleted,
    };
  }
}

class BooksRepository {
  const BooksRepository();

  Future<Map<int, Book>> fetchByIds(Iterable<int> ids) async {
    final uniqueIds = ids.where((id) => id > 0).toSet().toList();
    if (uniqueIds.isEmpty) {
      return const <int, Book>{};
    }

    final books = await bookDao.selectBooksByIds(uniqueIds);
    return {for (final book in books) book.id: book};
  }

  Future<List<BookSearchResult>> searchBooks({
    String? keyword,
    int? groupId,
    bool includeDeleted = false,
    int limit = 10,
  }) async {
    final query = keyword?.trim() ?? '';

    List<Book> books;
    if (query.isEmpty) {
      books = await bookDao.selectBooks();
    } else {
      books = await bookDao.searchBooks(query);
    }

    if (!includeDeleted) {
      books = books.where((book) => !book.isDeleted).toList();
    }

    if (groupId != null) {
      books = books.where((book) => book.groupId == groupId).toList();
    }

    final sliced = books.take(limit).toList();
    return sliced.map(BookSearchResult.new).toList();
  }
}
