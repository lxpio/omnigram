import 'package:omnigram/dao/base_dao.dart';

/// Persistent companion chat history stored in sqflite.
/// Each conversation is scoped to a book. Messages are stored chronologically.
class CompanionChatDao extends BaseDao {
  static const String table = 'tb_companion_chat';

  /// Get all messages for a book, ordered chronologically.
  Future<List<CompanionMessage>> getByBook(int bookId, {int? limit, int? offset}) async {
    return queryList<CompanionMessage>(
      table,
      mapper: CompanionMessage.fromRow,
      where: 'book_id = ?',
      whereArgs: [bookId],
      orderBy: 'created_at ASC',
      limit: limit,
      offset: offset,
    );
  }

  /// Get recent messages for a book (for context window).
  Future<List<CompanionMessage>> getRecent(int bookId, {int limit = 20}) async {
    // Get last N messages in reverse, then reverse back
    final messages = await queryList<CompanionMessage>(
      table,
      mapper: CompanionMessage.fromRow,
      where: 'book_id = ?',
      whereArgs: [bookId],
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return messages.reversed.toList();
  }

  /// Add a message to the conversation.
  Future<int> addMessage(CompanionMessage message) async {
    return insert(table, message.toMap());
  }

  /// Delete all messages for a book.
  Future<int> clearBook(int bookId) async {
    return delete(table, where: 'book_id = ?', whereArgs: [bookId]);
  }

  /// Get message count for a book.
  Future<int> countByBook(int bookId) async {
    final result = await rawQueryList<int>(
      'SELECT COUNT(*) as cnt FROM $table WHERE book_id = ?',
      arguments: [bookId],
      mapper: (row) => row['cnt'] as int,
    );
    return result.firstOrNull ?? 0;
  }

  /// Get all books that have companion conversations.
  Future<List<int>> getBooksWithChats() async {
    return rawQueryList<int>(
      'SELECT DISTINCT book_id FROM $table ORDER BY book_id',
      mapper: (row) => row['book_id'] as int,
    );
  }

  /// Get unsynced messages for server push (M-2).
  Future<List<CompanionMessage>> getUnsynced() async {
    return queryList(table, mapper: CompanionMessage.fromRow, where: 'synced = 0');
  }

  /// Mark messages as synced after successful push (M-2).
  Future<void> markSynced(List<int> ids) async {
    if (ids.isEmpty) return;
    final db = await database;
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.rawUpdate('UPDATE $table SET synced = 1 WHERE id IN ($placeholders)', ids);
  }

  /// Insert a message from server. Returns the local auto-increment ID.
  /// Dedup is handled by SyncManager via IdMappingDao (server ID check).
  Future<int> insertFromServer(CompanionMessage msg) async {
    final db = await database;
    final map = msg.toMap();
    map['synced'] = 1;
    return await db.insert('tb_companion_chat', map);
  }
}

/// Roles in a companion conversation.
enum ChatRole { user, companion, system }

/// A single message in a companion conversation.
class CompanionMessage {
  final int? id;
  final int bookId;
  final String role;
  final String content;
  final String? chapter;
  final String? cfi;
  final String createdAt;
  final bool synced;

  const CompanionMessage({
    this.id,
    required this.bookId,
    required this.role,
    required this.content,
    this.chapter,
    this.cfi,
    required this.createdAt,
    this.synced = false,
  });

  static CompanionMessage fromRow(Map<String, dynamic> row) {
    return CompanionMessage(
      id: row['id'] as int?,
      bookId: row['book_id'] as int,
      role: row['role'] as String,
      content: row['content'] as String,
      chapter: row['chapter'] as String?,
      cfi: row['cfi'] as String?,
      createdAt: row['created_at'] as String,
      synced: (row['synced'] as int?) == 1,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'book_id': bookId,
      'role': role,
      'content': content,
      'chapter': chapter,
      'cfi': cfi,
      'created_at': createdAt,
      'synced': synced ? 1 : 0,
    };
  }

  bool get isUser => role == ChatRole.user.name;
  bool get isCompanion => role == ChatRole.companion.name;

  /// Construct from server JSON response, mapping server book_id to local book_id.
  factory CompanionMessage.fromServerJson(Map<String, dynamic> json, int localBookId) {
    return CompanionMessage(
      bookId: localBookId,
      role: json['role'] as String,
      content: json['content'] as String,
      chapter: json['chapter'] as String?,
      cfi: json['cfi'] as String?,
      createdAt: json['ctime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['ctime'] as int).toIso8601String()
          : DateTime.now().toIso8601String(),
      synced: true,
    );
  }
}

final companionChatDao = CompanionChatDao();
