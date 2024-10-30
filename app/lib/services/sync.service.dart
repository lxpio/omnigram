import 'package:isar/isar.dart';
import 'package:logging/logging.dart';
import 'package:omnigram/entities/book.entity.dart';
import 'package:omnigram/entities/etag.entity.dart';
import 'package:omnigram/entities/isar_store.entity.dart';
import 'package:omnigram/providers/db.provider.dart';
import 'package:omnigram/utils/diff.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

final syncServiceProvider = Provider(
  (ref) => SyncService(ref.watch(dbProvider)),
);

class SyncService {
  final log = Logger('SyncService');
  final Isar _db;

  SyncService(this._db);

  // syncBooksToDB 同步远端的书籍到本地，这里通过传递函数参数来获取远端书籍的变化和加载远端书籍，因为考虑到远端可能是API Server ，或者云盘等
  Future<void> syncBooksToDB(
    Future<(List<BookEntity>? toUpsert, List<String>? toDelete)> Function(int since) getChangedAssets,
    Future<List<BookEntity>?> Function(int userID, int since) loadAssets,
  ) async {
    log.info('Syncing...');

    final currentUser = IsarStore.get(StoreKey.currentUser);

    // await _syncRemoteAssetChanges(getChangedAssets) ??
    await _syncRemoteAssetsForUser(currentUser.id, loadAssets);
  }

  /// Deletes remote-only assets, updates merged assets to be local-only
  Future<void> handleRemoteAssetRemoval(List<String> idsToDelete) {
    _db.write((db) {
      //查找所有需要删除的本地文件ID列表（ID在idsToDelete中，同时有没有本地文件）
      final idsToRemove = db.bookEntitys.remote(idsToDelete).localPathIsNotNull().idProperty().findAll();

      db.bookEntitys.deleteAll(idsToRemove);

      //查询所有未被删除的文件列表
      final onlyLocal = db.bookEntitys.remote(idsToDelete).findAll();
      if (onlyLocal.isNotEmpty) {
        onlyLocal.map((e) => e.copyWith(remoteId: null)).toList();
        db.bookEntitys.putAll(onlyLocal);
      }
    });
    return Future.value();
  }

  /// Inserts or updates the assets in the database with their ExifInfo (if any)
  Future<void> upsertBooks(List<BookEntity> books) async {
    if (books.isEmpty) {
      return;
    }

    try {
      _db.write((isar) {
        final exifInfos = books.map((e) => e.id == 0 ? e.copyWith(id: _db.bookEntitys.autoIncrement()) : e).toList();
        isar.bookEntitys.putAll(exifInfos);
      });
      log.info("Upserted ${books.length} assets into the DB");
    } on IsarError catch (e) {
      log.severe("Failed to upsert ${books.length} assets into the DB", e);
    }
  }

  /// Efficiently syncs assets via changes. Returns `null` when a full sync is required.
  Future<bool?> _syncRemoteAssetChanges(
    Future<(List<BookEntity>? toUpsert, List<String>? toDelete)> Function(
      int since,
    ) getChangedAssets,
  ) async {
    final currentUser = IsarStore.get(StoreKey.currentUser);

    final since = _db.eTags.get(currentUser.id)?.utime;
    log.severe("Syncing remote assets via changes", since);
    if (since == null) return null;

    final (toUpsert, toDelete) = await getChangedAssets(since);

    if (toUpsert == null || toDelete == null) {
      await _clearUserBooksETag(currentUser.id);
      return null;
    }
    try {
      if (toDelete.isNotEmpty) {
        await handleRemoteAssetRemoval(toDelete);
      }

      if (toUpsert.isNotEmpty) {
        final (_, updated) = await _linkWithExistingFromDb(toUpsert);
        await upsertBooks(updated);
      }
      if (toUpsert.isNotEmpty || toDelete.isNotEmpty) {
        final now = DateTime.now().millisecondsSinceEpoch;
        await _updateUserBooksETag(currentUser.id, now);
        return true;
      }
      return false;
    } on IsarError catch (e) {
      log.severe("Failed to sync remote assets to db", e);
    }
    return null;
  }

  /// Returns a tuple (existing, updated)
  Future<(List<BookEntity> existing, List<BookEntity> updated)> _linkWithExistingFromDb(
    List<BookEntity> books,
  ) async {
    if (books.isEmpty) return ([].cast<BookEntity>(), [].cast<BookEntity>());

    final inDB = _db.bookEntitys.where().anyOf(books, (q, book) => q.identifierEqualTo(book.identifier)).findAll();

    assert(inDB.length == books.length);
    final List<BookEntity> existing = [], toUpsert = [];

    for (int i = 0; i < books.length; i++) {
      inDB.contains(books[i]) ? existing.add(books[i]) : toUpsert.add(books[i]);
    }

    return (existing, toUpsert);
  }

  Future<bool> _syncRemoteAssetsForUser(
    int userId,
    Future<List<BookEntity>?> Function(int userId, int until) loadAssets,
  ) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final List<BookEntity>? remote = await loadAssets(userId, now);
    if (remote == null) {
      return false;
    }
    final List<BookEntity> inDb = _db.bookEntitys.where().findAll();

    remote.sort(BookEntity.compareByChecksum);

    // filter our duplicates that might be introduced by the chunked retrieval
    // remote.uniqueConsecutive(compare: BookEntity.compareByChecksum);

    final (toAdd, toUpdate, toRemove) = _diffBooks(remote, inDb, remote: true);
    if (toAdd.isEmpty && toUpdate.isEmpty && toRemove.isEmpty) {
      await _updateUserBooksETag(userId, now);
      return false;
    }
    final idsToDelete = toRemove.map((e) => e.id).toList();
    try {
      _db.write((db) => db.bookEntitys.deleteAll(idsToDelete));
      await upsertBooks(toAdd + toUpdate);
    } on IsarError catch (e) {
      log.severe("Failed to sync remote assets to db", e);
    }
    await _updateUserBooksETag(userId, now);
    return true;
  }

  Future<void> _clearUserBooksETag(int id) async {
    return _db.write((db) => db.eTags.delete(id));
  }

  Future<void> _updateUserBooksETag(int id, int utime) async {
    return _db.write((db) {
      final etag = db.eTags.get(id) ?? ETag(id: id, utime: utime);
      db.eTags.put(etag.copyWith(utime: utime));
    });
  }

  /// Returns a triple(toAdd, toUpdate, toRemove)
  (List<BookEntity> toAdd, List<BookEntity> toUpdate, List<BookEntity> toRemove) _diffBooks(
    List<BookEntity> assets,
    List<BookEntity> inDb, {
    bool? remote,
    int Function(BookEntity, BookEntity) compare = BookEntity.compareByChecksum,
  }) {
    // fast paths for trivial cases: reduces memory usage during initial sync etc.
    if (assets.isEmpty && inDb.isEmpty) {
      return const ([], [], []);
    } else if (assets.isEmpty && remote == null) {
      // remove all from database
      return (const [], const [], inDb);
    } else if (inDb.isEmpty) {
      // add all assets
      return (assets, const [], const []);
    }

    final List<BookEntity> toAdd = [];
    final List<BookEntity> toUpdate = [];
    final List<BookEntity> toRemove = [];
    diffSortedListsSync(
      inDb,
      assets,
      compare: compare,
      both: (BookEntity a, BookEntity b) {
        if (a.canUpdate(b)) {
          toUpdate.add(b);
          return true;
        }
        return false;
      },
      onlyFirst: (BookEntity a) {
        if (remote == true && a.isLocal) {
          if (a.remoteId != null) {
            toUpdate.add(a.copyWith(remoteId: null));
          }
        } else if (remote == false && a.isRemote) {
          if (a.isLocal) {
            toUpdate.add(a.copyWith(localPath: null));
          }
        } else {
          toRemove.add(a);
        }
      },
      onlySecond: (BookEntity b) => toAdd.add(b),
    );
    return (toAdd, toUpdate, toRemove);
  }
}
