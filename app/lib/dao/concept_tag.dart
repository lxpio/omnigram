import 'package:omnigram/dao/database.dart';

class ConceptTag {
  final int? id;
  final int bookId;
  final String name;
  final String? source;
  final int? noteId;
  final String? createTime;
  final int synced;

  ConceptTag({
    this.id,
    required this.bookId,
    required this.name,
    this.source,
    this.noteId,
    this.createTime,
    this.synced = 0,
  });

  Map<String, dynamic> toMap() => {
    'book_id': bookId,
    'name': name,
    'source': source,
    'note_id': noteId,
    'synced': synced,
  };

  factory ConceptTag.fromMap(Map<String, dynamic> map) => ConceptTag(
    id: map['id'] as int?,
    bookId: map['book_id'] as int,
    name: map['name'] as String,
    source: map['source'] as String?,
    noteId: map['note_id'] as int?,
    createTime: map['create_time'] as String?,
    synced: map['synced'] as int? ?? 0,
  );

  factory ConceptTag.fromServerJson(Map<String, dynamic> json, int localBookId) {
    return ConceptTag(
      bookId: localBookId,
      name: json['name'] as String,
      source: json['source'] as String?,
      noteId: json['note_id'] as int?,
      createTime: json['ctime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['ctime'] as int).toIso8601String()
          : null,
      synced: 1,
    );
  }
}

class ConceptEdge {
  final int? id;
  final int sourceTagId;
  final int targetTagId;
  final double weight;
  final String? reason;
  final String? createTime;
  final int synced;

  ConceptEdge({
    this.id,
    required this.sourceTagId,
    required this.targetTagId,
    this.weight = 1.0,
    this.reason,
    this.createTime,
    this.synced = 0,
  });

  Map<String, dynamic> toMap() => {
    'source_tag_id': sourceTagId,
    'target_tag_id': targetTagId,
    'weight': weight,
    'reason': reason,
    'synced': synced,
  };

  factory ConceptEdge.fromMap(Map<String, dynamic> map) => ConceptEdge(
    id: map['id'] as int?,
    sourceTagId: map['source_tag_id'] as int,
    targetTagId: map['target_tag_id'] as int,
    weight: (map['weight'] as num?)?.toDouble() ?? 1.0,
    reason: map['reason'] as String?,
    createTime: map['create_time'] as String?,
    synced: map['synced'] as int? ?? 0,
  );

  factory ConceptEdge.fromServerJson(
    Map<String, dynamic> json,
    int localSourceId,
    int localTargetId,
  ) {
    return ConceptEdge(
      sourceTagId: localSourceId,
      targetTagId: localTargetId,
      weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
      reason: json['reason'] as String?,
      createTime: json['ctime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['ctime'] as int).toIso8601String()
          : null,
      synced: 1,
    );
  }
}

class ConceptTagDao {
  Future<List<ConceptTag>> getAll() async {
    final db = await DBHelper().database;
    final maps = await db.query('tb_concept_tags', orderBy: 'create_time DESC');
    return maps.map(ConceptTag.fromMap).toList();
  }

  Future<List<ConceptTag>> getByBook(int bookId) async {
    final db = await DBHelper().database;
    final maps = await db.query(
      'tb_concept_tags',
      where: 'book_id = ?',
      whereArgs: [bookId],
      orderBy: 'create_time DESC',
    );
    return maps.map(ConceptTag.fromMap).toList();
  }

  Future<int> insert(ConceptTag tag) async {
    final db = await DBHelper().database;
    return db.insert('tb_concept_tags', tag.toMap());
  }

  Future<void> insertBatch(List<ConceptTag> tags) async {
    final db = await DBHelper().database;
    final batch = db.batch();
    for (final tag in tags) {
      batch.insert('tb_concept_tags', tag.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<List<ConceptEdge>> getAllEdges() async {
    final db = await DBHelper().database;
    final maps = await db.query('tb_concept_edges');
    return maps.map(ConceptEdge.fromMap).toList();
  }

  Future<void> insertEdge(ConceptEdge edge) async {
    final db = await DBHelper().database;
    await db.insert('tb_concept_edges', edge.toMap());
  }

  Future<void> insertEdgeBatch(List<ConceptEdge> edges) async {
    final db = await DBHelper().database;
    final batch = db.batch();
    for (final edge in edges) {
      batch.insert('tb_concept_edges', edge.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<List<ConceptTag>> getUnsynced() async {
    final db = await DBHelper().database;
    final maps = await db.query('tb_concept_tags', where: 'synced = 0');
    return maps.map(ConceptTag.fromMap).toList();
  }

  Future<void> markSynced(List<int> ids) async {
    if (ids.isEmpty) return;
    final db = await DBHelper().database;
    await db.update(
      'tb_concept_tags',
      {'synced': 1},
      where: 'id IN (${ids.map((_) => '?').join(',')})',
      whereArgs: ids,
    );
  }

  /// Insert a tag if it doesn't exist (dedup by book_id + name + note_id).
  /// Returns the local ID (existing or newly inserted).
  Future<int> insertTagIfNotExists(ConceptTag tag) async {
    final db = await DBHelper().database;
    final String whereClause;
    final List<Object?> whereArgs;
    if (tag.noteId != null) {
      whereClause = 'book_id = ? AND name = ? AND note_id = ?';
      whereArgs = [tag.bookId, tag.name, tag.noteId];
    } else {
      whereClause = 'book_id = ? AND name = ? AND (note_id IS NULL OR note_id = 0)';
      whereArgs = [tag.bookId, tag.name];
    }
    final existing = await db.query(
      'tb_concept_tags',
      columns: ['id'],
      where: whereClause,
      whereArgs: whereArgs,
      limit: 1,
    );
    if (existing.isNotEmpty) {
      return existing.first['id'] as int;
    }
    final map = tag.toMap();
    map['synced'] = 1;
    return await db.insert('tb_concept_tags', map);
  }

  /// Insert an edge if it doesn't exist (dedup by source_tag_id + target_tag_id).
  Future<void> insertEdgeIfNotExists(ConceptEdge edge) async {
    final db = await DBHelper().database;
    final existing = await db.query(
      'tb_concept_edges',
      columns: ['id'],
      where: 'source_tag_id = ? AND target_tag_id = ?',
      whereArgs: [edge.sourceTagId, edge.targetTagId],
      limit: 1,
    );
    if (existing.isNotEmpty) return;
    final map = edge.toMap();
    map['synced'] = 1;
    await db.insert('tb_concept_edges', map);
  }

  /// Get edges not yet synced to server.
  Future<List<ConceptEdge>> getUnsyncedEdges() async {
    final db = await DBHelper().database;
    final rows = await db.query('tb_concept_edges', where: 'synced = 0');
    return rows.map((r) => ConceptEdge.fromMap(r)).toList();
  }

  /// Mark edges as synced after successful push.
  Future<void> markEdgesSynced(List<int> ids) async {
    if (ids.isEmpty) return;
    final db = await DBHelper().database;
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.rawUpdate(
      'UPDATE tb_concept_edges SET synced = 1 WHERE id IN ($placeholders)',
      ids,
    );
  }
}
