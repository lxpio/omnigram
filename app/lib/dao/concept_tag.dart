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
}
