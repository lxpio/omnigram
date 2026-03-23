import 'package:omnigram/dao/search_repository.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/models/search_note_group.dart';
import 'package:omnigram/models/search_result_data.dart';
import 'package:omnigram/providers/server_connection_provider.dart';
import 'package:omnigram/service/api/book_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return const SearchRepository();
});

final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

/// Search mode: 'text' (tsvector) or 'semantic' (pgvector).
final searchModeProvider = StateProvider<String>((ref) => 'text');

final searchResultProvider = FutureProvider.autoDispose<SearchResultData>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final mode = ref.watch(searchModeProvider);
  final trimmed = query.trim();

  if (trimmed.isEmpty) {
    return SearchResultData.empty;
  }

  // Semantic mode requires server connection
  if (mode == 'semantic') {
    final conn = ref.read(serverConnectionProvider);
    if (conn.isConnected) {
      final notifier = ref.read(serverConnectionProvider.notifier);
      final api = notifier.api;
      if (api != null) {
        final bookApi = BookApi(api);
        try {
          final serverBooks = await bookApi.search(trimmed, mode: 'semantic');
          final books = serverBooks.map((sb) => Book(
            id: int.tryParse(sb.id) ?? 0,
            title: sb.title,
            coverPath: sb.coverUrl,
            filePath: '',
            lastReadPosition: '',
            readingPercentage: 0,
            author: sb.author,
            isDeleted: false,
            rating: 0,
            createTime: DateTime.now(),
            updateTime: DateTime.now(),
          )).toList();
          return SearchResultData(books: books, noteGroups: const []);
        } catch (_) {
          // Fall through to local search
        }
      }
    }
  }

  final repository = ref.watch(searchRepositoryProvider);
  final result = await repository.search(trimmed);
  final noteGroups = result.noteGroups
      .map((entry) => SearchNoteGroup(book: entry.book, notes: entry.notes))
      .toList(growable: false);

  return SearchResultData(books: result.books, noteGroups: noteGroups);
});
