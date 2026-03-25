import 'package:omnigram/dao/base_dao.dart';
import 'package:omnigram/utils/log/common.dart';

/// Persistent AI cache stored in sqflite.
/// Two-tier strategy: in-memory Map (hot) + sqflite (warm) + Server PG (cold/truth).
class AiCacheDao extends BaseDao {
  static const String table = 'tb_ai_cache';

  /// Get a cached AI result by type + key.
  Future<AiCacheEntry?> get(String type, String key) async {
    return querySingle<AiCacheEntry>(
      table,
      mapper: AiCacheEntry.fromRow,
      where: 'type = ? AND cache_key = ?',
      whereArgs: [type, key],
    );
  }

  /// Get all cached results for a book.
  Future<List<AiCacheEntry>> getByBook(int bookId) async {
    return queryList<AiCacheEntry>(
      table,
      mapper: AiCacheEntry.fromRow,
      where: 'book_id = ?',
      whereArgs: [bookId],
      orderBy: 'updated_at DESC',
    );
  }

  /// Insert or update a cache entry (upsert).
  Future<void> put(AiCacheEntry entry) async {
    final existing = await get(entry.type, entry.cacheKey);
    if (existing != null) {
      await update(table, entry.toMap(), where: 'id = ?', whereArgs: [existing.id]);
    } else {
      await insert(table, entry.toMap());
    }
  }

  /// Invalidate a specific cache entry.
  Future<void> invalidate(String type, String key) async {
    await delete(table, where: 'type = ? AND cache_key = ?', whereArgs: [type, key]);
  }

  /// Invalidate all cache entries for a book.
  Future<void> invalidateByBook(int bookId) async {
    await delete(table, where: 'book_id = ?', whereArgs: [bookId]);
  }

  /// Remove expired entries.
  Future<int> cleanExpired() async {
    final now = DateTime.now().toIso8601String();
    final count = await delete(table, where: 'expires_at IS NOT NULL AND expires_at < ?', whereArgs: [now]);
    if (count > 0) {
      AnxLog.info('AiCache: cleaned $count expired entries');
    }
    return count;
  }

  /// Get total cache size (row count).
  Future<int> count() async {
    final result = await rawQueryList<int>('SELECT COUNT(*) as cnt FROM $table', mapper: (row) => row['cnt'] as int);
    return result.firstOrNull ?? 0;
  }

  /// Get unsynced entries for server push (M-2).
  Future<List<AiCacheEntry>> getUnsynced() async {
    return queryList(table, mapper: AiCacheEntry.fromRow, where: 'synced = 0');
  }

  /// Mark entries as synced after successful push (M-2).
  Future<void> markSynced(List<int> ids) async {
    if (ids.isEmpty) return;
    final db = await database;
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.rawUpdate('UPDATE $table SET synced = 1 WHERE id IN ($placeholders)', ids);
  }
}

class AiCacheEntry {
  final int? id;
  final String type;
  final int? bookId;
  final String cacheKey;
  final String content;
  final String createdAt;
  final String updatedAt;
  final String? expiresAt;
  final bool synced;

  const AiCacheEntry({
    this.id,
    required this.type,
    this.bookId,
    required this.cacheKey,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.expiresAt,
    this.synced = false,
  });

  static AiCacheEntry fromRow(Map<String, dynamic> row) {
    return AiCacheEntry(
      id: row['id'] as int?,
      type: row['type'] as String,
      bookId: row['book_id'] as int?,
      cacheKey: row['cache_key'] as String,
      content: row['content'] as String,
      createdAt: row['created_at'] as String,
      updatedAt: row['updated_at'] as String,
      expiresAt: row['expires_at'] as String?,
      synced: (row['synced'] as int?) == 1,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'type': type,
      'book_id': bookId,
      'cache_key': cacheKey,
      'content': content,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'expires_at': expiresAt,
      'synced': synced ? 1 : 0,
    };
  }
}

final aiCacheDao = AiCacheDao();
