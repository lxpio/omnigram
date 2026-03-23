import 'package:omnigram/dao/search_repository.dart';
import 'package:omnigram/models/search_note_group.dart';
import 'package:omnigram/models/search_result_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return const SearchRepository();
});

final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

/// Search mode: 'text' (tsvector) or 'semantic' (pgvector).
final searchModeProvider = StateProvider<String>((ref) => 'text');

final searchResultProvider = FutureProvider.autoDispose<SearchResultData>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final repository = ref.watch(searchRepositoryProvider);
  final trimmed = query.trim();

  if (trimmed.isEmpty) {
    return SearchResultData.empty;
  }

  final result = await repository.search(trimmed);
  final noteGroups = result.noteGroups
      .map((entry) => SearchNoteGroup(book: entry.book, notes: entry.notes))
      .toList(growable: false);

  return SearchResultData(books: result.books, noteGroups: noteGroups);
});
