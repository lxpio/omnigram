import '../../models/server/server_shelf.dart';
import 'omnigram_api.dart';

/// Tags & shelves API.
class TagApi {
  TagApi(this._api);
  final OmnigramApi _api;

  /// List all tags.
  Future<List<String>> listTags() async {
    final response = await _api.dio.get('/reader/tags');
    final list = response.data as List;
    return list.map((e) {
      if (e is String) return e;
      if (e is Map<String, dynamic>) return e['name']?.toString() ?? '';
      return e.toString();
    }).toList();
  }

  /// Create a tag.
  Future<void> createTag(String name, {String? description}) async {
    await _api.postVoid('/reader/tags', data: {'name': name, if (description != null) 'description': description});
  }

  /// Delete a tag.
  Future<void> deleteTag(int tagId) async {
    await _api.delete('/reader/tags/$tagId');
  }
}

/// Shelf (book collection) API.
class ShelfApi {
  ShelfApi(this._api);
  final OmnigramApi _api;

  /// List all shelves.
  Future<List<ServerShelf>> listShelves() async {
    return _api.getList('/reader/shelves', fromJson: ServerShelf.fromJson);
  }

  /// Create a shelf.
  Future<ServerShelf> createShelf(String name, {String? description}) async {
    return _api.post(
      '/reader/shelves',
      data: {'name': name, if (description != null) 'description': description},
      fromJson: (data) => ServerShelf.fromJson(data),
    );
  }

  /// Get a shelf by ID.
  Future<ServerShelf> getShelf(int shelfId) async {
    return _api.get('/reader/shelves/$shelfId', fromJson: (data) => ServerShelf.fromJson(data));
  }

  /// Update a shelf.
  Future<ServerShelf> updateShelf(int shelfId, Map<String, dynamic> fields) async {
    return _api.put('/reader/shelves/$shelfId', data: fields, fromJson: (data) => ServerShelf.fromJson(data));
  }

  /// Delete a shelf.
  Future<void> deleteShelf(int shelfId) async {
    await _api.delete('/reader/shelves/$shelfId');
  }

  /// Add books to a shelf.
  Future<void> addBooksToShelf(int shelfId, List<String> bookIds) async {
    await _api.postVoid('/reader/shelves/$shelfId/books', data: {'book_ids': bookIds});
  }

  /// Remove books from a shelf.
  Future<void> removeBooksFromShelf(int shelfId, List<String> bookIds) async {
    await _api.delete('/reader/shelves/$shelfId/books', data: {'book_ids': bookIds});
  }
}
