import 'package:omnigram/dao/database.dart';

class Thought {
  final int? id;
  final String content;
  final String? conceptName;
  final int? bookId;
  final int? edgeId;
  final String createdAt;
  final bool synced;

  const Thought({
    this.id,
    required this.content,
    this.conceptName,
    this.bookId,
    this.edgeId,
    required this.createdAt,
    this.synced = false,
  });

  factory Thought.fromMap(Map<String, dynamic> map) {
    return Thought(
      id: map['id'] as int?,
      content: map['content'] as String,
      conceptName: map['concept_name'] as String?,
      bookId: map['book_id'] as int?,
      edgeId: map['edge_id'] as int?,
      createdAt: map['created_at'] as String,
      synced: (map['synced'] as int?) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'content': content,
      'concept_name': conceptName,
      'book_id': bookId,
      'edge_id': edgeId,
      'created_at': createdAt,
      'synced': synced ? 1 : 0,
    };
  }
}

class ThoughtDao {
  Future<List<Thought>> getAll() async {
    final db = await DBHelper().database;
    final rows = await db.query('tb_thoughts', orderBy: 'created_at DESC');
    return rows.map((r) => Thought.fromMap(r)).toList();
  }

  Future<int> insert(Thought thought) async {
    final db = await DBHelper().database;
    return await db.insert('tb_thoughts', thought.toMap());
  }

  Future<void> delete(int id) async {
    final db = await DBHelper().database;
    await db.delete('tb_thoughts', where: 'id = ?', whereArgs: [id]);
  }
}
