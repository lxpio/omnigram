import 'package:omnigram/utils/get_path/databases_path.dart';
import 'package:omnigram/utils/log/common.dart';
import 'package:omnigram/utils/platform_utils.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const _createBookSQL = '''
CREATE TABLE tb_books (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT,
  cover_path TEXT,
  file_path TEXT,
  last_read_position TEXT,
  reading_percentage REAL,
  author TEXT,
  is_deleted INTEGER DEFAULT 0,
  description TEXT,
  rating REAL DEFAULT 0,
  group_id INTEGER DEFAULT 0,
  file_md5 TEXT,
  is_dirty INTEGER DEFAULT 0,
  create_time TEXT,
  update_time TEXT
)
''';

const _createNoteSQL = '''
CREATE TABLE tb_notes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  book_id INTEGER,
  content TEXT,
  cfi TEXT,
  chapter TEXT,
  type TEXT,
  color TEXT,
  reader_note TEXT,
  create_time TEXT,
  update_time TEXT
)
''';

class StealthDBHelper {
  static final StealthDBHelper _instance = StealthDBHelper._internal();
  static Database? _database;

  factory StealthDBHelper() {
    return _instance;
  }

  StealthDBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    const dbVersion = 1;
    switch (AnxPlatform.type) {
      case AnxPlatformEnum.macos:
      case AnxPlatformEnum.android:
      case AnxPlatformEnum.ohos:
        final databasePath = await getAnxDataBasesPath();
        final path = join(databasePath, 'stealth_database.db');
        return await openDatabase(
          path,
          version: dbVersion,
          onCreate: _onCreate,
        );
      case AnxPlatformEnum.ios:
      case AnxPlatformEnum.windows:
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;

        final databasePath = await getAnxDataBasesPath();
        AnxLog.info('StealthDB: database path: $databasePath');
        final path = join(databasePath, 'stealth_database.db');

        return await databaseFactory.openDatabase(
          path,
          options: OpenDatabaseOptions(
            version: dbVersion,
            onCreate: _onCreate,
          ),
        );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    AnxLog.info('StealthDB: create database version $version');
    await db.execute(_createBookSQL);
    await db.execute(_createNoteSQL);
  }

  static Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
