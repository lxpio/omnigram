import 'package:omnigram/dao/base_dao.dart';

/// Persistent margin notes — AI-generated cross-book connections.
/// Displayed in the reading margin, max 3 per chapter.
class MarginNoteDao extends BaseDao {
  static const String table = 'tb_margin_notes';

  /// Get margin notes for a specific book + chapter.
  Future<List<MarginNote>> getByChapter(int bookId, String chapter) async {
    return queryList<MarginNote>(
      table,
      mapper: MarginNote.fromRow,
      where: 'book_id = ? AND chapter = ? AND dismissed = 0',
      whereArgs: [bookId, chapter],
      orderBy: 'confidence DESC',
      limit: 3,
    );
  }

  /// Get all margin notes for a book.
  Future<List<MarginNote>> getByBook(int bookId) async {
    return queryList<MarginNote>(
      table,
      mapper: MarginNote.fromRow,
      where: 'book_id = ?',
      whereArgs: [bookId],
      orderBy: 'created_at DESC',
    );
  }

  /// Add a margin note.
  Future<int> addNote(MarginNote note) async {
    return insert(table, note.toMap());
  }

  /// Dismiss a margin note (mark not relevant).
  Future<void> dismiss(int noteId) async {
    await update(table, {'dismissed': 1}, where: 'id = ?', whereArgs: [noteId]);
  }

  /// Mark a margin note as helpful (positive feedback).
  Future<void> markHelpful(int noteId) async {
    await update(table, {'helpful': 1}, where: 'id = ?', whereArgs: [noteId]);
  }

  /// Delete old dismissed notes to free storage.
  Future<int> cleanDismissed() async {
    return delete(table, where: 'dismissed = 1');
  }

  /// Count notes for a chapter (for density cap check).
  Future<int> countByChapter(int bookId, String chapter) async {
    final result = await rawQueryList<int>(
      'SELECT COUNT(*) as cnt FROM $table WHERE book_id = ? AND chapter = ? AND dismissed = 0',
      arguments: [bookId, chapter],
      mapper: (row) => row['cnt'] as int,
    );
    return result.firstOrNull ?? 0;
  }

  /// Get unsynced margin notes for server push (M-2).
  Future<List<MarginNote>> getUnsynced() async {
    return queryList('tb_margin_notes', mapper: MarginNote.fromRow, where: 'synced = 0');
  }

  /// Mark margin notes as synced after successful push (M-2).
  Future<void> markSynced(List<int> ids) async {
    if (ids.isEmpty) return;
    final db = await database;
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.rawUpdate('UPDATE tb_margin_notes SET synced = 1 WHERE id IN ($placeholders)', ids);
  }

  /// Upsert a margin note from server using Server Wins strategy.
  /// Dedup key: (book_id, chapter, cfi, content).
  /// If exists: update dismissed/helpful/confidence. If not: insert.
  Future<void> upsertFromServer(MarginNote note) async {
    final db = await database;
    final existing = await db.query(
      'tb_margin_notes',
      where: 'book_id = ? AND chapter = ? AND cfi = ? AND content = ?',
      whereArgs: [note.bookId, note.chapter, note.cfi ?? '', note.content],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      await db.update(
        'tb_margin_notes',
        {
          'dismissed': note.dismissed ? 1 : 0,
          'helpful': note.helpful ? 1 : 0,
          'confidence': note.confidence,
          'synced': 1,
        },
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    } else {
      final map = note.toMap();
      map['synced'] = 1;
      await db.insert('tb_margin_notes', map);
    }
  }
}

/// A single margin note — AI-generated cross-book connection.
class MarginNote {
  final int? id;
  final int bookId;
  final String chapter;
  final String? cfi;
  final String content;
  final int? relatedBookId;
  final String? relatedBookTitle;
  final String? relatedHighlight;
  final double confidence;
  final bool dismissed;
  final bool helpful;
  final String createdAt;
  final bool synced;

  const MarginNote({
    this.id,
    required this.bookId,
    required this.chapter,
    this.cfi,
    required this.content,
    this.relatedBookId,
    this.relatedBookTitle,
    this.relatedHighlight,
    this.confidence = 0.5,
    this.dismissed = false,
    this.helpful = false,
    required this.createdAt,
    this.synced = false,
  });

  static MarginNote fromRow(Map<String, dynamic> row) {
    return MarginNote(
      id: row['id'] as int?,
      bookId: row['book_id'] as int,
      chapter: row['chapter'] as String,
      cfi: row['cfi'] as String?,
      content: row['content'] as String,
      relatedBookId: row['related_book_id'] as int?,
      relatedBookTitle: row['related_book_title'] as String?,
      relatedHighlight: row['related_highlight'] as String?,
      confidence: (row['confidence'] as num?)?.toDouble() ?? 0.5,
      dismissed: (row['dismissed'] as int?) == 1,
      helpful: (row['helpful'] as int?) == 1,
      createdAt: row['created_at'] as String,
      synced: (row['synced'] as int?) == 1,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'book_id': bookId,
      'chapter': chapter,
      'cfi': cfi,
      'content': content,
      'related_book_id': relatedBookId,
      'related_book_title': relatedBookTitle,
      'related_highlight': relatedHighlight,
      'confidence': confidence,
      'dismissed': dismissed ? 1 : 0,
      'helpful': helpful ? 1 : 0,
      'created_at': createdAt,
      'synced': synced ? 1 : 0,
    };
  }

  /// Construct from server JSON response, mapping server book_id to local book_id.
  factory MarginNote.fromServerJson(Map<String, dynamic> json, int localBookId) {
    return MarginNote(
      bookId: localBookId,
      chapter: json['chapter'] as String,
      cfi: json['cfi'] as String?,
      content: json['content'] as String,
      relatedBookId: null,
      relatedBookTitle: json['related_book_title'] as String?,
      relatedHighlight: json['related_highlight'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
      dismissed: json['dismissed'] as bool? ?? false,
      helpful: json['helpful'] as bool? ?? false,
      createdAt: json['ctime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['ctime'] as int).toIso8601String()
          : DateTime.now().toIso8601String(),
      synced: true,
    );
  }
}

final marginNoteDao = MarginNoteDao();
