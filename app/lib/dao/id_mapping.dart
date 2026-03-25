import 'package:omnigram/dao/database.dart';

/// DAO for local↔server ID mapping (D-1).
///
/// Maintains a mapping between local IDs and server IDs for entities
/// (books, annotations, etc.) to handle ID mismatches across sync.
class IdMappingDao {
  static const _table = 'tb_id_mapping';

  /// Insert or update a mapping.
  static Future<void> upsert(String localId, String serverId, String entityType) async {
    final db = await DBHelper().database;
    await db.rawInsert(
      '''
      INSERT OR REPLACE INTO $_table (local_id, server_id, entity_type)
      VALUES (?, ?, ?)
    ''',
      [localId, serverId, entityType],
    );
  }

  /// Get server ID for a local ID.
  static Future<String?> getServerId(String localId, String entityType) async {
    final db = await DBHelper().database;
    final results = await db.query(
      _table,
      columns: ['server_id'],
      where: 'local_id = ? AND entity_type = ?',
      whereArgs: [localId, entityType],
    );
    if (results.isEmpty) return null;
    return results.first['server_id'] as String;
  }

  /// Get local ID for a server ID.
  static Future<String?> getLocalId(String serverId, String entityType) async {
    final db = await DBHelper().database;
    final results = await db.query(
      _table,
      columns: ['local_id'],
      where: 'server_id = ? AND entity_type = ?',
      whereArgs: [serverId, entityType],
    );
    if (results.isEmpty) return null;
    return results.first['local_id'] as String;
  }

  /// Get all mappings for a given entity type.
  static Future<Map<String, String>> getAllMappings(String entityType) async {
    final db = await DBHelper().database;
    final results = await db.query(_table, where: 'entity_type = ?', whereArgs: [entityType]);
    return {for (var r in results) r['local_id'] as String: r['server_id'] as String};
  }

  /// Delete a mapping.
  static Future<void> delete(String localId, String entityType) async {
    final db = await DBHelper().database;
    await db.delete(_table, where: 'local_id = ? AND entity_type = ?', whereArgs: [localId, entityType]);
  }
}
