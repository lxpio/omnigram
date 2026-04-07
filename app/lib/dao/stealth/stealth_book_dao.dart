import 'package:omnigram/dao/stealth/stealth_db_helper.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/service/stealth/encryption_service.dart';

class StealthBookDao {
  final String _key;

  StealthBookDao(this._key);

  Future<int> insertBook(Book book) async {
    final db = await StealthDBHelper().database;
    final map = book.toMap();
    map['title'] = EncryptionService.encrypt(map['title'] as String? ?? '', _key);
    map['author'] = EncryptionService.encrypt(map['author'] as String? ?? '', _key);
    map['description'] = EncryptionService.encrypt(map['description'] as String? ?? '', _key);
    return await db.insert('tb_books', map);
  }

  Future<List<Book>> selectBooks() async {
    final db = await StealthDBHelper().database;
    final results = await db.query(
      'tb_books',
      where: 'is_deleted = 0',
    );
    return results.map((row) {
      final decrypted = Map<String, dynamic>.from(row);
      decrypted['title'] = EncryptionService.decrypt(decrypted['title'] as String? ?? '', _key);
      decrypted['author'] = EncryptionService.decrypt(decrypted['author'] as String? ?? '', _key);
      decrypted['description'] = EncryptionService.decrypt(decrypted['description'] as String? ?? '', _key);
      return Book.fromDb(decrypted);
    }).toList();
  }

  Future<int> deleteBook(int id) async {
    final db = await StealthDBHelper().database;
    return await db.update(
      'tb_books',
      {'is_deleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
