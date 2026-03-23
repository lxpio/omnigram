import 'dart:io';

import 'package:omnigram/dao/book.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/models/sync_status.dart';
import 'package:omnigram/utils/get_path/get_base_path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_status.g.dart';

@Riverpod(keepAlive: true)
class SyncStatus extends _$SyncStatus {
  List<Book> allBooksInBookShelf = [];
  @override
  Future<SyncStatusModel> build() async {
    allBooksInBookShelf = await _listAllBooksInBookShelf();
    final localFiles = await _listLocalFiles(allBooksInBookShelf);

    return SyncStatusModel(
      localOnly: localFiles,
      remoteOnly: [],
      both: [],
      nonExistent: [],
      downloading: [],
      uploading: [],
    );
  }

  Future<void> refresh() async {
    state = AsyncData(await build());
  }

  Future<List<int>> _listLocalFiles(List<Book> books) async {
    final localFiles = (await getFileDir().list().toList())
        .map((e) => e.path.split(Platform.pathSeparator).last)
        .toList();

    final localFilesIds = books
        .map((e) {
          final filePath = e.filePath.split('/').last;
          final isExist = localFiles.contains(filePath);
          return isExist ? e.id : null;
        })
        .whereType<int>()
        .toList();
    return localFilesIds;
  }

  Future<List<Book>> _listAllBooksInBookShelf() async {
    return await bookDao.selectNotDeleteBooks();
  }
}
