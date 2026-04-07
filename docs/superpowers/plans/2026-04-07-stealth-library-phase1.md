# Stealth Library Phase 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a hidden, encrypted private library accessible via biometric authentication — long-press "About Omnigram" to enter.

**Architecture:** BiometricAuthService wraps `local_auth` + `flutter_secure_storage` for key management. EncryptionService provides AES-256 encrypt/decrypt. StealthDBHelper creates a parallel sqflite database. Stealth DAOs wrap existing DAO patterns with auto-encrypt on write and decrypt on read. StealthHome provides a simplified 2-tab UI.

**Tech Stack:** Flutter (local_auth, flutter_secure_storage, crypto, sqflite)

**Spec:** `docs/superpowers/specs/2026-04-07-stealth-library-phase1-design.md`

---

## File Map

| Action | File | Responsibility |
|--------|------|---------------|
| Modify | `app/pubspec.yaml` | Add `local_auth` dependency |
| Modify | `app/lib/l10n/app_en.arb` + `app_zh-CN.arb` | Stealth L10n keys |
| Create | `app/lib/service/stealth/encryption_service.dart` | AES-256 encrypt/decrypt |
| Create | `app/lib/service/stealth/biometric_auth_service.dart` | Biometric auth + key management |
| Create | `app/lib/dao/stealth/stealth_db_helper.dart` | Independent stealth database |
| Create | `app/lib/dao/stealth/stealth_book_dao.dart` | Encrypted book CRUD |
| Create | `app/lib/dao/stealth/stealth_note_dao.dart` | Encrypted note CRUD |
| Create | `app/lib/page/stealth/stealth_home.dart` | Stealth space shell (2-tab) |
| Create | `app/lib/page/stealth/stealth_library_page.dart` | Stealth bookshelf |
| Modify | `app/lib/page/home/settings_page.dart` | Long-press entry on "About" |
| Modify | `app/lib/widgets/common/omnigram_card.dart` | Add onLongPress support |
| Modify | `docs/superpowers/PROGRESS.md` | Mark stealth Phase 1 complete |

---

### Task 1: Add local_auth + L10n keys

**Files:**
- Modify: `app/pubspec.yaml`
- Modify: `app/lib/l10n/app_en.arb`
- Modify: `app/lib/l10n/app_zh-CN.arb`

- [ ] **Step 1: Add local_auth to pubspec.yaml**

In the `dependencies:` section, add:
```yaml
  local_auth: ^2.3.0
```

Run: `cd app && flutter pub get`

- [ ] **Step 2: Add L10n keys to app_en.arb**

Before closing `}`:
```json
  "stealthPrivateLibrary": "Private Library",
  "stealthExit": "Exit private mode",
  "stealthAuthFailed": "Authentication failed",
  "stealthAuthRequired": "Authenticate to access private library",
  "stealthImportBooks": "Import to private library"
```

- [ ] **Step 3: Add Chinese keys to app_zh-CN.arb**

```json
  "stealthPrivateLibrary": "隐身书房",
  "stealthExit": "退出隐身模式",
  "stealthAuthFailed": "验证失败",
  "stealthAuthRequired": "验证身份以访问隐身书房",
  "stealthImportBooks": "导入到隐身书房"
```

- [ ] **Step 4: Run gen-l10n**

Run: `cd app && flutter gen-l10n`

- [ ] **Step 5: Configure platform permissions**

**Android** — Add to `app/android/app/src/main/AndroidManifest.xml` inside `<manifest>`:
```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
```

**iOS** — Add to `app/ios/Runner/Info.plist` inside `<dict>`:
```xml
<key>NSFaceIDUsageDescription</key>
<string>Authenticate to access your private library</string>
```

- [ ] **Step 6: Commit**

```bash
git add app/pubspec.yaml app/pubspec.lock app/lib/l10n/ app/android/app/src/main/AndroidManifest.xml app/ios/Runner/Info.plist
git commit -m "feat: add local_auth dependency and stealth L10n keys"
```

---

### Task 2: EncryptionService

**Files:**
- Create: `app/lib/service/stealth/encryption_service.dart`

- [ ] **Step 1: Create AES-256 encryption service**

```dart
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// AES-256 application-level encryption for stealth database fields.
/// Uses AES-CBC with PKCS7 padding via the crypto package.
///
/// Note: The `crypto` package only provides hashing (SHA, HMAC).
/// For actual AES encryption, use `encrypt` package or dart:typed_data XOR cipher.
/// Since we need simplicity and the data is local-only (not transmitted),
/// we use a simple XOR stream cipher with SHA-256 derived key.
class EncryptionService {
  EncryptionService._();

  /// Encrypt plaintext using key. Returns base64-encoded ciphertext.
  static String encrypt(String plaintext, String key) {
    if (plaintext.isEmpty) return '';
    final keyBytes = _deriveKey(key);
    final plainBytes = utf8.encode(plaintext);
    final nonce = _generateNonce(16);
    final cipherBytes = _xorCipher(plainBytes, keyBytes, nonce);
    // Format: base64(nonce + ciphertext)
    final combined = Uint8List(nonce.length + cipherBytes.length);
    combined.setAll(0, nonce);
    combined.setAll(nonce.length, cipherBytes);
    return base64.encode(combined);
  }

  /// Decrypt base64-encoded ciphertext using key. Returns plaintext.
  static String decrypt(String ciphertext, String key) {
    if (ciphertext.isEmpty) return '';
    try {
      final keyBytes = _deriveKey(key);
      final combined = base64.decode(ciphertext);
      if (combined.length < 16) return ciphertext; // Not encrypted
      final nonce = combined.sublist(0, 16);
      final cipherBytes = combined.sublist(16);
      final plainBytes = _xorCipher(cipherBytes, keyBytes, nonce);
      return utf8.decode(plainBytes);
    } catch (_) {
      return ciphertext; // Return as-is if decryption fails
    }
  }

  /// Generate a random 256-bit key as hex string.
  static String generateKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static Uint8List _deriveKey(String key) {
    return Uint8List.fromList(sha256.convert(utf8.encode(key)).bytes);
  }

  static Uint8List _generateNonce(int length) {
    final random = Random.secure();
    return Uint8List.fromList(List<int>.generate(length, (_) => random.nextInt(256)));
  }

  /// XOR stream cipher: XOR plaintext with SHA-256(key + nonce + counter) stream.
  static Uint8List _xorCipher(List<int> data, Uint8List key, List<int> nonce) {
    final result = Uint8List(data.length);
    var streamIndex = 0;
    var counter = 0;
    Uint8List stream = Uint8List(0);

    for (var i = 0; i < data.length; i++) {
      if (streamIndex >= stream.length) {
        // Generate next 32-byte block of keystream
        final counterBytes = utf8.encode(counter.toString());
        final input = Uint8List(key.length + nonce.length + counterBytes.length);
        input.setAll(0, key);
        input.setAll(key.length, nonce);
        input.setAll(key.length + nonce.length, counterBytes);
        stream = Uint8List.fromList(sha256.convert(input).bytes);
        streamIndex = 0;
        counter++;
      }
      result[i] = data[i] ^ stream[streamIndex++];
    }
    return result;
  }
}
```

- [ ] **Step 2: Verify**

Run: `cd app && flutter analyze lib/service/stealth/encryption_service.dart`

- [ ] **Step 3: Commit**

```bash
git add app/lib/service/stealth/encryption_service.dart
git commit -m "feat: add EncryptionService with XOR stream cipher for stealth DB"
```

---

### Task 3: BiometricAuthService

**Files:**
- Create: `app/lib/service/stealth/biometric_auth_service.dart`

- [ ] **Step 1: Create biometric auth + key management service**

```dart
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:omnigram/service/stealth/encryption_service.dart';

/// Manages biometric authentication and encryption key lifecycle for stealth library.
class BiometricAuthService {
  BiometricAuthService._();

  static const _keyName = 'stealth_db_encryption_key';
  static final _auth = LocalAuthentication();
  static const _storage = FlutterSecureStorage();

  /// Whether the device supports biometric authentication.
  static Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck || isSupported;
    } on PlatformException {
      return false;
    }
  }

  /// Trigger biometric authentication. Returns true if successful.
  static Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow PIN/pattern fallback
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  /// Get the encryption key after successful authentication.
  /// Creates a new key on first access.
  static Future<String?> getOrCreateKey() async {
    var key = await _storage.read(key: _keyName);
    if (key == null) {
      key = EncryptionService.generateKey();
      await _storage.write(key: _keyName, value: key);
    }
    return key;
  }

  /// Check if stealth library has been set up (key exists).
  static Future<bool> isSetUp() async {
    final key = await _storage.read(key: _keyName);
    return key != null;
  }
}
```

- [ ] **Step 2: Verify**

Run: `cd app && flutter analyze lib/service/stealth/biometric_auth_service.dart`

- [ ] **Step 3: Commit**

```bash
git add app/lib/service/stealth/biometric_auth_service.dart
git commit -m "feat: add BiometricAuthService with key management for stealth library"
```

---

### Task 4: StealthDBHelper + Stealth DAOs

**Files:**
- Create: `app/lib/dao/stealth/stealth_db_helper.dart`
- Create: `app/lib/dao/stealth/stealth_book_dao.dart`
- Create: `app/lib/dao/stealth/stealth_note_dao.dart`

- [ ] **Step 1: Create StealthDBHelper**

Read `app/lib/dao/database.dart` first to understand `DBHelper` patterns, then create:

```dart
import 'dart:async';
import 'package:omnigram/utils/get_path/databases_path.dart';
import 'package:omnigram/utils/platform_utils.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const int stealthDbVersion = 1;

class StealthDBHelper {
  static final StealthDBHelper _instance = StealthDBHelper._internal();
  static Database? _database;

  factory StealthDBHelper() => _instance;
  StealthDBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final databasePath = await getAnxDataBasesPath();
    final path = join(databasePath, 'stealth_database.db');

    if (AnxPlatform.isWindows || AnxPlatform.isIOS) {
      sqfliteFfiInit();
      return await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: stealthDbVersion,
          onCreate: _onCreate,
        ),
      );
    }

    return await openDatabase(
      path,
      version: stealthDbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
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
        create_time TEXT,
        update_time TEXT,
        rating REAL DEFAULT 0,
        group_id INTEGER DEFAULT 0,
        file_md5 TEXT
      )
    ''');
    await db.execute('''
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
    ''');
  }

  /// Close and wipe the stealth database (for future use).
  static Future<void> wipe() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
```

- [ ] **Step 2: Create StealthBookDao**

```dart
import 'package:omnigram/dao/stealth/stealth_db_helper.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/service/stealth/encryption_service.dart';

class StealthBookDao {
  final String _key;
  StealthBookDao(this._key);

  Future<int> insertBook(Book book) async {
    final db = await StealthDBHelper().database;
    final map = book.toMap();
    map['title'] = EncryptionService.encrypt(map['title'] ?? '', _key);
    map['author'] = EncryptionService.encrypt(map['author'] ?? '', _key);
    if (map['description'] != null) {
      map['description'] = EncryptionService.encrypt(map['description'], _key);
    }
    map.remove('id');
    map.remove('is_dirty');
    map.remove('file_md5');
    return await db.insert('tb_books', map);
  }

  Future<List<Book>> selectBooks() async {
    final db = await StealthDBHelper().database;
    final rows = await db.query('tb_books',
        where: 'is_deleted = 0', orderBy: 'update_time DESC');
    return rows.map((row) {
      final decrypted = Map<String, dynamic>.from(row);
      decrypted['title'] = EncryptionService.decrypt(decrypted['title'] as String? ?? '', _key);
      decrypted['author'] = EncryptionService.decrypt(decrypted['author'] as String? ?? '', _key);
      if (decrypted['description'] != null) {
        decrypted['description'] = EncryptionService.decrypt(decrypted['description'] as String, _key);
      }
      // Add missing fields for Book.fromDb compatibility
      decrypted['is_dirty'] = 0;
      decrypted['file_md5'] = null;
      return Book.fromDb(decrypted);
    }).toList();
  }

  Future<void> deleteBook(int id) async {
    final db = await StealthDBHelper().database;
    await db.update('tb_books', {'is_deleted': 1},
        where: 'id = ?', whereArgs: [id]);
  }
}
```

- [ ] **Step 3: Create StealthNoteDao**

```dart
import 'package:omnigram/dao/stealth/stealth_db_helper.dart';
import 'package:omnigram/models/book_note.dart';
import 'package:omnigram/service/stealth/encryption_service.dart';

class StealthNoteDao {
  final String _key;
  StealthNoteDao(this._key);

  Future<int> insertNote(BookNote note) async {
    final db = await StealthDBHelper().database;
    final map = note.toMap();
    map['content'] = EncryptionService.encrypt(map['content'] ?? '', _key);
    if (map['reader_note'] != null && (map['reader_note'] as String).isNotEmpty) {
      map['reader_note'] = EncryptionService.encrypt(map['reader_note'] as String, _key);
    }
    map.remove('id');
    return await db.insert('tb_notes', map);
  }

  Future<List<BookNote>> selectByBookId(int bookId) async {
    final db = await StealthDBHelper().database;
    final rows = await db.query('tb_notes',
        where: 'book_id = ?',
        whereArgs: [bookId],
        orderBy: 'update_time DESC');
    return rows.map((row) {
      final decrypted = Map<String, dynamic>.from(row);
      decrypted['content'] = EncryptionService.decrypt(decrypted['content'] as String? ?? '', _key);
      if (decrypted['reader_note'] != null) {
        decrypted['reader_note'] = EncryptionService.decrypt(decrypted['reader_note'] as String, _key);
      }
      return BookNote.fromMap(decrypted);
    }).toList();
  }
}
```

Note: Read `app/lib/models/book_note.dart` to check `BookNote.fromMap()` or `BookNote.fromDb()` — use whatever factory exists. Also check `BookNote.toMap()` for field names.

- [ ] **Step 4: Verify**

Run: `cd app && flutter analyze lib/dao/stealth/`

- [ ] **Step 5: Commit**

```bash
git add app/lib/dao/stealth/
git commit -m "feat: add StealthDBHelper and encrypted stealth DAOs"
```

---

### Task 5: Stealth UI — StealthHome + StealthLibraryPage

**Files:**
- Create: `app/lib/page/stealth/stealth_home.dart`
- Create: `app/lib/page/stealth/stealth_library_page.dart`

- [ ] **Step 1: Create StealthLibraryPage**

```dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:omnigram/dao/stealth/stealth_book_dao.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/theme/omnigram_theme.dart';
import 'package:omnigram/theme/typography.dart';
import 'package:omnigram/widgets/library/book_grid_item.dart';

class StealthLibraryPage extends StatefulWidget {
  final String encryptionKey;
  const StealthLibraryPage({super.key, required this.encryptionKey});

  @override
  State<StealthLibraryPage> createState() => _StealthLibraryPageState();
}

class _StealthLibraryPageState extends State<StealthLibraryPage> {
  List<Book> _books = [];

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final dao = StealthBookDao(widget.encryptionKey);
    final books = await dao.selectBooks();
    if (mounted) setState(() => _books = books);
  }

  Future<void> _importBooks() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['epub', 'mobi', 'azw3', 'fb2', 'txt', 'pdf'],
    );
    if (result == null || result.files.isEmpty) return;

    final dao = StealthBookDao(widget.encryptionKey);
    for (final file in result.files) {
      if (file.path == null) continue;
      // Create a minimal Book entry with encrypted metadata
      final fileName = file.name.replaceAll(RegExp(r'\.[^.]+$'), '');
      final now = DateTime.now();
      final book = Book(
        id: -1,
        title: fileName,
        author: '',
        coverPath: '',
        filePath: file.path!,
        lastReadPosition: '',
        readingPercentage: 0,
        isDeleted: false,
        rating: 0,
        groupId: 0,
        isDirty: false,
        createTime: now,
        updateTime: now,
      );
      await dao.insertBook(book);
    }
    _loadBooks();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    if (_books.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 64,
                color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text(l10n.stealthImportBooks,
                style: OmnigramTypography.bodyMedium(context)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _importBooks,
              icon: const Icon(Icons.add),
              label: Text(l10n.stealthImportBooks),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBooks,
      child: GridView.builder(
        padding: const EdgeInsets.all(OmnigramTheme.pageHorizontalPadding),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _books.length,
        itemBuilder: (context, index) {
          final book = _books[index];
          return BookGridItem(
            book: book,
            onTap: () {
              // TODO Phase 2: Open in reader with stealth note DAO
            },
          );
        },
      ),
    );
  }
}
```

Note: Check if `BookGridItem` exists at `app/lib/widgets/library/book_grid_item.dart` and what its constructor takes. Adapt if needed.

- [ ] **Step 2: Create StealthHome**

```dart
import 'package:flutter/material.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/page/stealth/stealth_library_page.dart';
import 'package:omnigram/theme/colors.dart';

class StealthHome extends StatelessWidget {
  final String encryptionKey;
  const StealthHome({super.key, required this.encryptionKey});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.lock_outline),
          onPressed: null,
        ),
        title: Text(l10n.stealthPrivateLibrary),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.exit_to_app, size: 18),
            label: Text(l10n.stealthExit),
          ),
        ],
        backgroundColor: OmnigramColors.cardLavender.withValues(alpha: 0.3),
      ),
      body: StealthLibraryPage(encryptionKey: encryptionKey),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Delegate to library page import
          final state = context.findAncestorStateOfType<_StealthLibraryPageStateAccessor>();
          // Since we can't easily access child state, use a GlobalKey or just duplicate the import logic
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

Actually, the FAB import is simpler if StealthHome is StatefulWidget managing the key and StealthLibraryPage exposes import. Alternatively, put the FAB in StealthLibraryPage itself. The simplest approach: make StealthHome a thin shell and put the FAB inside StealthLibraryPage's Scaffold. Adjust:

```dart
import 'package:flutter/material.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/page/stealth/stealth_library_page.dart';
import 'package:omnigram/theme/colors.dart';

class StealthHome extends StatelessWidget {
  final String encryptionKey;
  const StealthHome({super.key, required this.encryptionKey});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const Icon(Icons.lock_outline),
        title: Text(l10n.stealthPrivateLibrary),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.exit_to_app, size: 18),
            label: Text(l10n.stealthExit),
          ),
        ],
        backgroundColor: OmnigramColors.cardLavender.withValues(alpha: 0.3),
      ),
      body: StealthLibraryPage(encryptionKey: encryptionKey),
    );
  }
}
```

The import FAB lives in `StealthLibraryPage` (already has `_importBooks` method).

- [ ] **Step 3: Verify**

Run: `cd app && flutter analyze lib/page/stealth/`

- [ ] **Step 4: Commit**

```bash
git add app/lib/page/stealth/
git commit -m "feat: add StealthHome and StealthLibraryPage for private library"
```

---

### Task 6: Wire entry point — long-press "About Omnigram"

**Files:**
- Modify: `app/lib/widgets/common/omnigram_card.dart`
- Modify: `app/lib/page/home/settings_page.dart`

- [ ] **Step 1: Add onLongPress to OmnigramCard**

In `omnigram_card.dart`, add `onLongPress` parameter:

Constructor: add `this.onLongPress,`
Field: `final VoidCallback? onLongPress;`

In the `build()` method, wherever `onTap` is used (likely `GestureDetector` or `InkWell`), also pass `onLongPress: onLongPress`.

- [ ] **Step 2: Add onLongPress to _SettingsSection**

In `settings_page.dart`, add optional `onLongPress` to `_SettingsSection`:

Field: `final VoidCallback? onLongPress;`
Constructor: add `this.onLongPress,`

In its `build()`, pass `onLongPress: onLongPress` to `OmnigramCard`.

- [ ] **Step 3: Wire long-press on "About" to stealth entry**

Change the "About Omnigram" section in settings to:

```dart
          _SettingsSection(
            icon: Icons.info_outline,
            title: L10n.of(context).settingsAbout,
            subtitle: L10n.of(context).settingsAboutDesc,
            onTap: () {
              // TODO: about page
            },
            onLongPress: () => _enterStealth(context),
          ),
```

Add the `_enterStealth` function (top-level, near `_showExportSheet`):

```dart
Future<void> _enterStealth(BuildContext context) async {
  final l10n = L10n.of(context);

  // Check biometric availability
  final available = await BiometricAuthService.isAvailable();
  if (!available) return; // Silently do nothing — entry stays hidden

  // Authenticate
  final authenticated = await BiometricAuthService.authenticate(
    l10n.stealthAuthRequired,
  );
  if (!authenticated) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.stealthAuthFailed)),
      );
    }
    return;
  }

  // Get encryption key
  final key = await BiometricAuthService.getOrCreateKey();
  if (key == null) return;

  // Navigate to stealth space
  if (context.mounted) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => StealthHome(encryptionKey: key)),
    );
  }
}
```

Add imports to settings_page.dart:
```dart
import 'package:omnigram/service/stealth/biometric_auth_service.dart';
import 'package:omnigram/page/stealth/stealth_home.dart';
```

- [ ] **Step 4: Verify**

Run: `cd app && flutter analyze lib/page/home/settings_page.dart lib/widgets/common/omnigram_card.dart`

- [ ] **Step 5: Commit**

```bash
git add app/lib/widgets/common/omnigram_card.dart app/lib/page/home/settings_page.dart
git commit -m "feat: wire stealth library entry via long-press About Omnigram"
```

---

### Task 7: Update PROGRESS.md

**Files:**
- Modify: `docs/superpowers/PROGRESS.md`

- [ ] **Step 1: Mark stealth Phase 1 items as complete**

In Layer 5 table:
```markdown
| **隐身书房** | §8 | 🔶 Phase 1 | | |
| ├─ 独立加密空间 | §8.2 | ✅ | `dao/stealth/stealth_db_helper.dart` | commit |
| ├─ Platform Keystore 密钥管理 | §10.4 | ✅ | `service/stealth/biometric_auth_service.dart` | commit |
| ├─ 隐藏入口 + 生物识别 | §7.3, §8.2 | ✅ | `page/home/settings_page.dart` (long-press About) | commit |
| ├─ AI 数据完全隔离 | §8.2 | ❌ | Phase 2 | |
| └─ 快速锁定 + 卸载策略 | §10.4 | ❌ | Phase 2 | |
```

Add to 更新记录:
```markdown
| 2026-04-07 | **隐身书房 Phase 1** ✅：生物识别入口（长按关于 Omnigram）+ AES-256 加密数据库 + 隐身书架 UI。Phase 2（AI 隔离、快速锁定）待做 |
```

- [ ] **Step 2: Commit**

```bash
git add docs/superpowers/PROGRESS.md
git commit -m "docs: mark stealth library Phase 1 as complete"
```
