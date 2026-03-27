import '../../models/server/server_book.dart';
import 'omnigram_api.dart';

/// Book management API — CRUD, search, upload/download.
class BookApi {
  BookApi(this._api);
  final OmnigramApi _api;

  // ── Book CRUD ───────────────────────────────────────────────────

  /// List all books with automatic pagination.
  Future<List<ServerBook>> listBooks({
    String? query,
    String? author,
    String? category,
    String? tag,
  }) async {
    const batchSize = 100;
    final allBooks = <ServerBook>[];
    var page = 1;

    while (true) {
      final result = await _api.get<Map<String, dynamic>>(
        '/reader/books',
        queryParameters: {
          'page': page,
          'page_size': batchSize,
          if (query != null) 'q': query,
          if (author != null) 'author': author,
          if (category != null) 'category': category,
          if (tag != null) 'tag': tag,
        },
        fromJson: (data) => data as Map<String, dynamic>,
      );
      final books = result['books'] as List? ?? [];
      allBooks.addAll(books.map((e) => ServerBook.fromJson(e as Map<String, dynamic>)));
      if (books.length < batchSize) break;
      page++;
    }
    return allBooks;
  }

  /// Get a single book by ID.
  Future<ServerBook> getBook(String bookId) async {
    return _api.get('/reader/books/$bookId', fromJson: (data) => ServerBook.fromJson(data));
  }

  /// Update book metadata.
  Future<ServerBook> updateBook(String bookId, Map<String, dynamic> fields) async {
    return _api.put('/reader/books/$bookId', data: fields, fromJson: (data) => ServerBook.fromJson(data));
  }

  /// Delete a book.
  Future<void> deleteBook(String bookId) async {
    await _api.delete('/reader/books/$bookId');
  }

  /// Upload a book file.
  Future<void> uploadBook(String filePath) async {
    await _api.uploadFile('/reader/upload', filePath: filePath);
  }

  /// Download a book file to local path.
  Future<void> downloadBook(String bookId, String savePath, {void Function(int, int)? onReceiveProgress}) async {
    await _api.downloadFile('/reader/download/books/$bookId', savePath: savePath, onReceiveProgress: onReceiveProgress);
  }

  /// Upload/replace a book's cover.
  Future<void> uploadCover(String bookId, String coverPath) async {
    await _api.uploadFile('/reader/books/$bookId/cover', filePath: coverPath);
  }

  /// Update book rating.
  Future<void> updateRating(String bookId, double rating) async {
    await _api.putVoid('/reader/books/$bookId/rating', data: {'rating': rating});
  }

  // ── Book Lists ──────────────────────────────────────────────────

  /// Get recently added books.
  Future<List<ServerBook>> getRecentBooks() async {
    return _api.getList('/reader/recent', fromJson: ServerBook.fromJson);
  }

  /// Get favorite books.
  Future<List<ServerBook>> getFavoriteBooks() async {
    return _api.getList('/reader/fav', fromJson: ServerBook.fromJson);
  }

  /// Get personal books.
  Future<List<ServerBook>> getPersonalBooks() async {
    return _api.getList('/reader/personal', fromJson: ServerBook.fromJson);
  }

  /// Enhanced search.
  Future<List<ServerBook>> search(String query, {String mode = 'text'}) async {
    return _api.getList('/reader/search', queryParameters: {'q': query, 'mode': mode}, fromJson: ServerBook.fromJson);
  }

  /// Get book statistics.
  Future<ServerBookStats> getStats() async {
    return _api.get('/reader/stats', fromJson: (data) => ServerBookStats.fromJson(data));
  }

  // ── Batch Operations ────────────────────────────────────────────

  /// Delete multiple books.
  Future<void> batchDelete(List<String> bookIds) async {
    await _api.postVoid('/reader/books/batch/delete', data: {'book_ids': bookIds});
  }

  /// Batch add tags to books.
  Future<void> batchTag(List<String> bookIds, List<int> tagIds) async {
    await _api.postVoid('/reader/books/batch/tag', data: {'book_ids': bookIds, 'tag_ids': tagIds});
  }

  /// Batch add books to shelf.
  Future<void> batchShelf(List<String> bookIds, int shelfId) async {
    await _api.postVoid('/reader/books/batch/shelf', data: {'book_ids': bookIds, 'shelf_id': shelfId});
  }

  // ── Cover Image ─────────────────────────────────────────────────

  /// Get cover image URL for a book.
  String getCoverUrl(String coverPath) {
    return '${_api.baseUrl}/img/covers/$coverPath';
  }
}
