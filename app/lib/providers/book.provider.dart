// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:omnigram/entities/book.entity.dart';
import 'package:omnigram/providers/db.provider.dart';
import 'package:omnigram/services/book.service.dart';
import 'package:omnigram/services/sync.service.dart';

part 'book.provider.g.dart';

class BookState {
  final List<BookEntity> items;
  final int page;
  final String? search;
  final bool loading;
  final bool noMore;

  BookState({
    required this.items,
    required this.page,
    required this.search,
    required this.loading,
    required this.noMore,
  });

  BookState copyWith({
    List<BookEntity>? items,
    int? page,
    String? search,
    bool? loading,
    bool? noMore,
  }) {
    return BookState(
      items: items ?? this.items,
      page: page ?? this.page,
      search: search ?? this.search,
      loading: loading ?? this.loading,
      noMore: noMore ?? this.noMore,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'items': items.map((x) => x.toMap()).toList(),
      'page': page,
      'search': search,
      'loading': loading,
      'noMore': noMore,
    };
  }

  factory BookState.fromMap(Map<String, dynamic> map) {
    return BookState(
      items: List<BookEntity>.from(
        (map['items'] as List<int>).map<BookEntity>(
          (x) => BookEntity.fromMap(x as Map<String, dynamic>),
        ),
      ),
      page: map['page'] as int,
      search: map['search'] as String,
      loading: map['loading'] as bool,
      noMore: map['noMore'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory BookState.fromJson(String source) => BookState.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BookState(items: $items, page: $page, search: $search, loading: $loading, noMore: $noMore)';
  }

  @override
  bool operator ==(covariant BookState other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.items, items) &&
        other.page == page &&
        other.search == search &&
        other.loading == loading &&
        other.noMore == noMore;
  }

  @override
  int get hashCode {
    return items.hashCode ^ page.hashCode ^ search.hashCode ^ loading.hashCode ^ noMore.hashCode;
  }
}

typedef QueryFn = QueryBuilder<BookEntity, BookEntity, QAfterSortBy> Function(
    QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition>);

// typedef QueryFn<T extends QueryBuilder> = QueryBuilder<BookEntity, BookEntity, QAfterSortBy> Function(T queryBuilder);

enum BookQuery {
  recents('recents', recentsFilter),
  likes('likes', likesFilter),
  readings('readings', readingsFilter);

  final String name;
  final QueryFn fn;

  const BookQuery(this.name, this.fn);
}

final queryFnMap = {
  BookQuery.recents: recentsFilter,
  BookQuery.likes: likesFilter,
  BookQuery.readings: readingsFilter,
};

QueryBuilder<BookEntity, BookEntity, QAfterSortBy> recentsFilter(
    QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> condition) {
  return condition.sortByUtime();
}

QueryBuilder<BookEntity, BookEntity, QAfterSortBy> likesFilter(
    QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> condition) {
  // debugPrint('build books with favStatusEqualTo true query');
  return condition.favStatusEqualTo(true).sortByUtime();
}

QueryBuilder<BookEntity, BookEntity, QAfterSortBy> readingsFilter(
    QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> condition) {
  return condition.sortByAtime();
}

@Riverpod(keepAlive: true)
class BookSearch extends _$BookSearch {
  @override
  BookState build(BookQuery query) {
    debugPrint('build book search riverpod with query: $query');
    final items = _getRecentBook(0);
    return BookState(page: 0, items: items, loading: false, search: null, noMore: items.length < 12);
  }

  List<BookEntity> _getRecentBook(int page, {String? search}) {
    final db = ref.watch(dbProvider);

    final condition = (search == null)
        ? db.bookEntitys.where().idGreaterThan(0)
        : db.bookEntitys
            .where()
            .titleContains(search, caseSensitive: false)
            .or()
            .authorContains(search, caseSensitive: false); //QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition>

    return query.fn(condition).findAll(offset: page * 12, limit: 12);
  }

  Future<void> search(String? keyword) async {
    debugPrint(' book search  keyword: $keyword loading: ${state.loading} noMore: ${state.noMore}');
    if (state.loading) return;
    state = state.copyWith(loading: true);
    final items = _getRecentBook(0, search: keyword);

    state = BookState(page: 0, items: items, search: keyword, loading: false, noMore: items.length < 12);
    debugPrint(' book search  keyword: $keyword more: ${items.isEmpty} length: ${state.items.length}');
    // state = BookState(page: 0, items: items, search: keyword, loading: false, noMore: false);
  }

  Future<void> loadMore(String? keyword) async {
    if (state.loading || state.noMore) return;

    state = state.copyWith(loading: true);

    final more = _getRecentBook(state.page + 1, search: keyword);

    if (state.search != keyword) {
      state = BookState(page: 0, items: more, search: keyword, loading: false, noMore: more.length < 12);
      debugPrint(' book search  keyword: $keyword more: ${more.isEmpty} length: ${state.items.length}');
    } else {
      state = BookState(
          loading: false,
          noMore: more.isEmpty,
          search: keyword,
          items: [...state.items, ...more],
          page: state.page + 1);

      debugPrint(' book  load More keyword: $keyword more: ${more.isEmpty} length: ${state.items.length}');
    }
  }
}

@riverpod
class Books extends _$Books {
  @override
  BookState build(BookQuery query) {
    // debugPrint('build books with query: ${query.label}');
    final items = _getRecentBook(0);
    return BookState(page: 0, items: items, search: null, loading: false, noMore: false);
  }

  List<BookEntity> _getRecentBook(int page) {
    final db = ref.watch(dbProvider);

    final condition = db.bookEntitys.where().idGreaterThan(0);

    return query.fn(condition).findAll(offset: page * 12, limit: 12);
  }

  Future<void> loadMore() async {
    if (state.loading) return;

    state = state.copyWith(loading: true);

    final more = _getRecentBook(state.page + 1);

    state = BookState(
        loading: false, search: null, noMore: more.isEmpty, items: [...state.items, ...more], page: state.page + 1);
  }
}

@Riverpod(keepAlive: true)
class BookNotifier extends _$BookNotifier {
  final log = Logger('BookNotifier');

  @override
  bool build() {
    return false;
  }

  Future<void> syncBooksToDB() async {
    if (state) return;

    state = true;
    log.info('start sync remote books to db...');
    final bookService = ref.watch(bookServiceProvider);
    final syncService = ref.watch(syncServiceProvider);
    await syncService.syncBooksToDB(bookService.getChangedBooks, bookService.loadBooks);
    log.info('sync remote books to db done');
    state = false;
  }
}
