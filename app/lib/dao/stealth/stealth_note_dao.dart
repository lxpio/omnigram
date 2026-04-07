import 'package:omnigram/dao/stealth/stealth_db_helper.dart';
import 'package:omnigram/models/book_note.dart';
import 'package:omnigram/service/stealth/encryption_service.dart';

class StealthNoteDao {
  final String _key;

  StealthNoteDao(this._key);

  Future<int> insertNote(BookNote note) async {
    final db = await StealthDBHelper().database;
    final map = note.toMap();
    map['content'] = EncryptionService.encrypt(map['content'] as String? ?? '', _key);
    map['reader_note'] = EncryptionService.encrypt(map['reader_note'] as String? ?? '', _key);
    // Remove id so SQLite auto-generates it
    map.remove('id');
    return await db.insert('tb_notes', map);
  }

  Future<List<BookNote>> selectByBookId(int bookId) async {
    final db = await StealthDBHelper().database;
    final results = await db.query(
      'tb_notes',
      where: 'book_id = ?',
      whereArgs: [bookId],
    );
    return results.map((row) {
      final decrypted = Map<String, dynamic>.from(row);
      decrypted['content'] = EncryptionService.decrypt(decrypted['content'] as String? ?? '', _key);
      decrypted['reader_note'] = EncryptionService.decrypt(decrypted['reader_note'] as String? ?? '', _key);
      return BookNote.fromDb(decrypted);
    }).toList();
  }
}
