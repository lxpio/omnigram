import 'package:get/get.dart';

import '../models/message_model.dart';
import 'package:sqflite/sqflite.dart';

abstract class MessageProvider {
  factory MessageProvider(Database database) {
    return MessagesDao(database);
  }

  Future<Iterable<Message>> list({
    required int conversationId,
    String? serviceId,
    MessageType? type,
    int offset = 0,
    int limit = 16,
  });

  Future<int> create(Message message);

  Future<int> delete(Message message);
}

class MessagesDao implements MessageProvider {
  static const table = 'tb_messages';

  final Database db;
  MessagesDao(this.db);

  static Future<void> onCreate(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $table (
        id TEXT NOT NULL PRIMARY KEY,
        type INTEGER,
        from_type INTEGER,
        service_name TEXT,
        service_avatar TEXT,
        content TEXT,
        create_at DATETIME,
        request_message TEXT,
        quote_message TEXT,
        response_data TEXT,
        conversation_id TEXT,
        service_id TEXT
      );
    ''');
  }

  static Future<void> onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // do nothing
  }

  Future<void> dropTable({required String conversationId}) {
    return db.execute('DROP TABLE $table');
  }

  @override
  Future<Iterable<Message>> list({
    required int conversationId,
    String? serviceId,
    MessageType? type,
    int offset = 0,
    int limit = 16,
  }) async {
    return (await db.rawQuery(
      'SELECT * FROM $table ${_buildWhere(
        serviceId: serviceId,
        type: type,
      )}ORDER BY create_at DESC LIMIT $limit OFFSET $offset',
    ))
        .map((e) => Message.fromJson(e));
  }

  String _buildWhere({
    String? serviceId,
    MessageType? type,
  }) {
    List<String> where = [];
    if (serviceId != null) {
      where.add('service_id = "$serviceId"');
    }
    if (type != null) {
      where.add('type = ${type.index}');
    }
    return where.isEmpty ? '' : 'WHERE ${where.join(' AND ')} ';
  }

  @override
  Future<int> create(Message message) async {
    return await db.insert(table, message.toJson());
  }

  @override
  Future<int> delete(Message message) async {
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [message.id],
    );
  }
}
