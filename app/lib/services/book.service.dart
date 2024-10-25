import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';
import 'package:logging/logging.dart';
import 'package:omnigram/entities/book.entity.dart';
import 'package:openapi/openapi.dart';
//BookService 提供获取书籍信息的服务，这里以本地文件优先，但是也要考虑网络请求

class BookService {
  final log = Logger('AssetService');
  final Isar _db;
  final DefaultApi _apiService;

  BookService(
    this._db,
    this._apiService,
  );

  Future<BookNav> getNavBook(int limit) async {
    final recents =
        _db.bookEntitys.where().sortByCtimeDesc().findAll(limit: limit);

    final readings =
        _db.bookEntitys.where().sortByUtimeDesc().findAll(limit: limit);

    final likes = _db.bookEntitys
        .where()
        .favStatusEqualTo(true)
        .sortByUtimeDesc()
        .findAll(limit: limit);

    // final randoms =
    //     await _db.books.where().sortByRandom().limit(limit).findAll();

    final nav = BookNav(
      recents: recents,
      randoms: recents,
      readings: readings,
      likes: likes,
    );
    return nav;
  }

  Future<(List<BookEntity>? toUpsert, List<String>? toDelete)> getChangedBooks(
      int since) async {
    try {
      final fullSyncDto = FullSyncDto((d) => d
        ..utime = since
        ..limit = 500);
      final resp = await _apiService.syncDeltaPost(fullSyncDto: fullSyncDto);

      if (resp.statusCode != 200) {
        log.severe('getChangedBooks', resp.statusCode);
        return (null, null);
      }

      final changes = resp.data!;

      return changes.needFullSync
          ? (null, null)
          : (
              changes.upserted.map((e) => BookEntity.remote(e)).toList(),
              changes.deleted.toList()
            );
    } catch (e) {
      log.severe('getChangedBooks', e);
      return (null, null);
    }
  }

  Future<List<BookEntity>?> loadBooks(int userID, int until) async {
    try {
      final fullSyncDto = FullSyncDto((d) => d
        ..utime = until
        ..limit = 100);

      final List<BookEntity> result = [];
      final bookStream = _apiService.syncFullPost(fullSyncDto: fullSyncDto);

      await for (var data in bookStream) {
        //save to local file
        final books = data.map((e) => BookEntity.remote(e)).toList();

        result.addAll(books);
      }

      return result;
    } catch (e) {
      log.severe('loadBooks', e);
      return null;
    }
  }

  // Future<Book?> getBookById(int id) async {
  //   return await _db.books.get(id);
  // }

  // Future<Book?> getBookByIsbn(String isbn) async {
  //   return await _db.books.where().filter().isbnEqualTo(isbn).findFirst();
  // }

  // Future<Book?> getBookByTitle(String title) async {
  //   return await _db.books.where().filter().titleEqualTo(title).findFirst(
  // );
}
