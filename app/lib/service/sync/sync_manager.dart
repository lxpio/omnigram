import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/get_path/get_base_path.dart';

import '../../dao/ai_cache.dart';
import '../../dao/book.dart';
import '../../dao/book_note.dart';
import '../../dao/companion_chat.dart';
import '../../dao/concept_tag.dart';
import '../../dao/id_mapping.dart';
import '../../dao/margin_note.dart';
import '../../models/book.dart';
import '../../models/book_note.dart';
import '../../models/server/server_annotation.dart';
import '../../models/server/server_book.dart';
import '../../providers/server_connection_provider.dart';

part 'sync_manager.g.dart';

/// Sync status for UI display.
enum SyncStatus { idle, syncing, success, error, offline }

/// Categorized sync error types for actionable user feedback (U-2).
enum SyncErrorType { network, auth, server, data, unknown }

/// Conflict record for user notification.
class SyncConflict {
  const SyncConflict({required this.bookId, required this.field, required this.localValue, required this.serverValue});
  final int bookId;
  final String field;
  final String localValue;
  final String serverValue;
}

/// State of the incremental sync.
class SyncState {
  const SyncState({
    this.status = SyncStatus.idle,
    this.lastSyncTime,
    this.message,
    this.progress = 0.0,
    this.errorType,
    this.conflicts = const [],
  });

  final SyncStatus status;
  final DateTime? lastSyncTime;
  final String? message;
  final double progress;
  final SyncErrorType? errorType;
  final List<SyncConflict> conflicts;

  SyncState copyWith({
    SyncStatus? status,
    DateTime? lastSyncTime,
    String? message,
    double? progress,
    SyncErrorType? errorType,
    List<SyncConflict>? conflicts,
  }) {
    return SyncState(
      status: status ?? this.status,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      message: message,
      progress: progress ?? this.progress,
      errorType: errorType,
      conflicts: conflicts ?? this.conflicts,
    );
  }
}

/// Keys for persisting sync state.
class _SyncKeys {
  static const lastSyncTime = 'sync_last_sync_time_ms';
  static const syncCheckpoint = 'sync_checkpoint_step';
}

/// Bidirectional incremental sync manager.
///
/// Features: delta sync, batch push, retry with exponential backoff,
/// conflict logging, server time for LWW, pagination, offline queue,
/// AI data sync, error classification, atomic checkpoint.
@Riverpod(keepAlive: true)
class SyncManager extends _$SyncManager {
  Timer? _autoSyncTimer;
  static const _maxRetries = 3;
  static const _pageSize = 500;

  @override
  SyncState build() {
    ref.onDispose(() => _autoSyncTimer?.cancel());
    _restoreLastSyncTime();
    return const SyncState();
  }

  /// Restore lastSyncTime from SharedPreferences.
  Future<void> _restoreLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_SyncKeys.lastSyncTime);
    if (ms != null && ms > 0) {
      state = state.copyWith(lastSyncTime: DateTime.fromMillisecondsSinceEpoch(ms));
    }
  }

  /// Persist lastSyncTime to SharedPreferences.
  Future<void> _persistLastSyncTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_SyncKeys.lastSyncTime, time.millisecondsSinceEpoch);
  }

  /// Get the last sync timestamp in milliseconds (for server API).
  int get _lastSyncTimeMs => state.lastSyncTime?.millisecondsSinceEpoch ?? 0;

  // ── Checkpoint for atomic sync (R-1) ──────────────────────────

  Future<void> _saveCheckpoint(int step) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_SyncKeys.syncCheckpoint, step);
  }

  Future<void> _clearCheckpoint() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_SyncKeys.syncCheckpoint);
  }

  // ── Retry with exponential backoff ────────────────────────────

  Future<T> _withRetry<T>(String label, Future<T> Function() action) async {
    for (var attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        return await action();
      } catch (e) {
        if (attempt == _maxRetries) rethrow;
        final delay = Duration(milliseconds: 500 * pow(2, attempt).toInt());
        debugPrint('[SyncManager] $label attempt ${attempt + 1} failed, retry in ${delay.inMilliseconds}ms: $e');
        await Future.delayed(delay);
      }
    }
    throw StateError('Unreachable');
  }

  // ── Error classification (U-2) ────────────────────────────────

  SyncErrorType _classifyError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('socketexception') || msg.contains('timeout') || msg.contains('connection')) {
      return SyncErrorType.network;
    }
    if (msg.contains('401') || msg.contains('403') || msg.contains('unauthorized')) {
      return SyncErrorType.auth;
    }
    if (msg.contains('500') || msg.contains('502') || msg.contains('503')) {
      return SyncErrorType.server;
    }
    if (msg.contains('format') || msg.contains('parse') || msg.contains('cast')) {
      return SyncErrorType.data;
    }
    return SyncErrorType.unknown;
  }

  String _errorMessage(SyncErrorType type) {
    switch (type) {
      case SyncErrorType.network:
        return '网络连接失败，请检查网络设置';
      case SyncErrorType.auth:
        return '认证失败，请重新登录';
      case SyncErrorType.server:
        return '服务器暂时不可用，稍后重试';
      case SyncErrorType.data:
        return '数据格式异常，请联系支持';
      case SyncErrorType.unknown:
        return '同步失败，稍后重试';
    }
  }

  /// Perform full bidirectional sync with retry and checkpoint.
  Future<void> sync() async {
    final connection = ref.read(serverConnectionProvider);
    if (!connection.isConnected) {
      state = state.copyWith(status: SyncStatus.offline);
      return;
    }

    if (state.status == SyncStatus.syncing) return;

    state = state.copyWith(status: SyncStatus.syncing, message: '正在同步...', progress: 0.0, conflicts: []);

    final conflicts = <SyncConflict>[];

    try {
      // Step 1: Push local changes to server
      await _saveCheckpoint(1);
      await _withRetry('pushBooks', _pushBooks);
      state = state.copyWith(progress: 0.15, message: '上传书籍变更...');

      await _saveCheckpoint(2);
      await _withRetry('pushAnnotations', _pushAnnotations);
      state = state.copyWith(progress: 0.3, message: '上传笔记...');

      // Step 3: Push AI data (M-2)
      await _saveCheckpoint(3);
      await _withRetry('pushAiData', _pushAiData);
      state = state.copyWith(progress: 0.4, message: '同步 AI 数据...');

      // Step 4: Pull remote changes from server
      await _saveCheckpoint(4);
      await _withRetry('pullBooks', () => _pullBooks(conflicts));
      state = state.copyWith(progress: 0.6, message: '下载更新...');

      await _saveCheckpoint(5);
      await _withRetry('pullAnnotations', _pullAnnotations);
      state = state.copyWith(progress: 0.8, message: '同步笔记...');

      // Step 6: Pull reading progress
      await _saveCheckpoint(6);
      await _withRetry('pullProgress', _pullProgress);
      state = state.copyWith(progress: 0.95, message: '同步进度...');

      // Step 7: Process offline queue
      await _processOfflineQueue();

      final now = DateTime.now();
      await _persistLastSyncTime(now);
      await _clearCheckpoint();

      state = SyncState(
        status: SyncStatus.success,
        lastSyncTime: now,
        message: conflicts.isEmpty ? '同步完成' : '同步完成，${conflicts.length} 个冲突已自动解决',
        progress: 1.0,
        conflicts: conflicts,
      );

      // Reset to idle after showing success
      Future.delayed(const Duration(seconds: 3), () {
        if (state.status == SyncStatus.success) {
          state = state.copyWith(status: SyncStatus.idle);
        }
      });
    } catch (e) {
      debugPrint('[SyncManager] Sync error: $e');
      final errorType = _classifyError(e);
      state = state.copyWith(
        status: SyncStatus.error,
        errorType: errorType,
        message: _errorMessage(errorType),
      );
    }
  }

  /// Start auto-sync with given interval.
  void startAutoSync({Duration interval = const Duration(minutes: 15)}) {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer.periodic(interval, (_) => sync());
  }

  /// Stop auto-sync.
  void stopAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
  }

  /// Download book file on demand.
  Future<void> downloadBookFile(int bookId, String savePath) async {
    final conn = ref.read(serverConnectionProvider.notifier);
    final bookApi = conn.books;
    if (bookApi == null) return;

    try {
      await bookApi.downloadBook(bookId.toString(), savePath);
      final bookDao = BookDao();
      final book = await bookDao.selectBookById(bookId);
      book.filePath = savePath;
      await bookDao.updateBook(book);
    } catch (e) {
      debugPrint('[SyncManager] Download book $bookId failed: $e');
      rethrow;
    }
  }

  // ── Push: Local → Server ────────────────────────────────────────

  Future<void> _pushBooks() async {
    final conn = ref.read(serverConnectionProvider.notifier);
    final syncApi = conn.sync;
    if (syncApi == null) return;

    final bookDao = BookDao();
    final dirtyBooks = await bookDao.selectDirtyBooks();
    if (dirtyBooks.isEmpty) return;

    // P-1: Batch push instead of N+1 individual requests
    final batchData = dirtyBooks.map((b) => _localBookToServerFields(b)..['id'] = b.id.toString()).toList();

    try {
      final result = await syncApi.batchPushBooks(batchData);
      final failedIndices = (result['failed_indices'] as List?)?.cast<int>() ?? [];

      final pushedIds = <int>[];
      for (var i = 0; i < dirtyBooks.length; i++) {
        if (!failedIndices.contains(i)) {
          pushedIds.add(dirtyBooks[i].id);
        }
      }
      await bookDao.clearDirtyFlags(pushedIds);
    } catch (e) {
      // Fallback to individual push if batch endpoint not available
      debugPrint('[SyncManager] Batch push failed, falling back to individual: $e');
      final pushedIds = <int>[];
      final bookApi = conn.books;
      if (bookApi == null) return;
      for (final book in dirtyBooks) {
        try {
          await bookApi.updateBook(book.id.toString(), _localBookToServerFields(book));
          pushedIds.add(book.id);
        } catch (e2) {
          debugPrint('[SyncManager] Push book ${book.id} skipped: $e2');
        }
      }
      await bookDao.clearDirtyFlags(pushedIds);
    }
  }

  Future<void> _pushAnnotations() async {
    final conn = ref.read(serverConnectionProvider.notifier);
    final annotationApi = conn.annotations;
    if (annotationApi == null) return;

    final bookDao = BookDao();
    final books = await bookDao.selectBooks(includeDeleted: false);

    for (final book in books) {
      final notes = await BookNoteDao().selectBookNotesByBookId(book.id);
      if (notes.isEmpty) continue;

      final serverAnnotations = notes
          .map(
            (note) => ServerAnnotation(
              bookId: book.id.toString(),
              chapter: note.chapter,
              content: note.content,
              selectedText: note.content,
              cfi: note.cfi,
              color: note.color,
              type: note.type,
              cTime: note.createTime?.millisecondsSinceEpoch ?? 0,
              uTime: note.updateTime.millisecondsSinceEpoch,
            ),
          )
          .toList();

      try {
        await annotationApi.syncAnnotations(serverAnnotations);
      } catch (e) {
        debugPrint('[SyncManager] Push annotations for book ${book.id}: $e');
      }
    }
  }

  /// Push AI data types to server (M-2).
  Future<void> _pushAiData() async {
    final conn = ref.read(serverConnectionProvider.notifier);
    if (!conn.state.isConnected) return;
    final api = conn.api;
    if (api == null) return;

    // Concept tags
    try {
      final conceptDao = ConceptTagDao();
      final unsyncedTags = await conceptDao.getUnsynced();
      if (unsyncedTags.isNotEmpty) {
        final tagMaps = unsyncedTags.map((t) => t.toMap()).toList();
        await api.postVoid('/reader/knowledge/tags', data: tagMaps);
        await conceptDao.markSynced(unsyncedTags.where((t) => t.id != null).map((t) => t.id!).toList());
      }
    } catch (e) {
      debugPrint('[SyncManager] Push concept tags: $e');
    }

    // AI cache
    try {
      final aiDao = AiCacheDao();
      final unsyncedCache = await aiDao.getUnsynced();
      if (unsyncedCache.isNotEmpty) {
        final cacheMaps = unsyncedCache.map((c) => c.toMap()).toList();
        await api.postVoid('/ai/cache/sync', data: cacheMaps);
        await aiDao.markSynced(unsyncedCache.where((c) => c.id != null).map((c) => c.id!).toList());
      }
    } catch (e) {
      debugPrint('[SyncManager] Push AI cache: $e');
    }

    // Companion chat
    try {
      final chatDao = CompanionChatDao();
      final unsyncedChats = await chatDao.getUnsynced();
      if (unsyncedChats.isNotEmpty) {
        final byBook = <int, List<CompanionMessage>>{};
        for (final msg in unsyncedChats) {
          byBook.putIfAbsent(msg.bookId, () => []).add(msg);
        }
        for (final entry in byBook.entries) {
          try {
            await api.postVoid(
              '/reader/books/${entry.key}/companion/chat',
              data: entry.value.map((m) => m.toMap()).toList(),
            );
            await chatDao.markSynced(entry.value.where((m) => m.id != null).map((m) => m.id!).toList());
          } catch (e) {
            debugPrint('[SyncManager] Push chat for book ${entry.key}: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('[SyncManager] Push companion chat: $e');
    }

    // Margin notes
    try {
      final marginDao = MarginNoteDao();
      final unsyncedNotes = await marginDao.getUnsynced();
      if (unsyncedNotes.isNotEmpty) {
        final byBook = <int, List<MarginNote>>{};
        for (final note in unsyncedNotes) {
          byBook.putIfAbsent(note.bookId, () => []).add(note);
        }
        for (final entry in byBook.entries) {
          try {
            await api.postVoid(
              '/reader/books/${entry.key}/margin-notes',
              data: entry.value.map((n) => n.toMap()).toList(),
            );
            await marginDao.markSynced(entry.value.where((n) => n.id != null).map((n) => n.id!).toList());
          } catch (e) {
            debugPrint('[SyncManager] Push margin notes for book ${entry.key}: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('[SyncManager] Push margin notes: $e');
    }
  }

  // ── Pull: Server → Local ────────────────────────────────────────

  Future<void> _pullBooks(List<SyncConflict> conflicts) async {
    final conn = ref.read(serverConnectionProvider.notifier);
    final syncApi = conn.sync;
    final bookApi = conn.books;
    if (syncApi == null || bookApi == null) return;

   try {
      List<ServerBook> serverBooks;
      final bookDao = BookDao();

      // Check if local DB is empty — if so, always do full sync
      final localBooks = await bookDao.selectBooks(includeDeleted: false);
      final isLocalEmpty = localBooks.isEmpty;
      debugPrint('[SyncManager] _pullBooks: lastSyncTimeMs=$_lastSyncTimeMs, localBooks=${localBooks.length}, isLocalEmpty=$isLocalEmpty');

      if (_lastSyncTimeMs > 0 && !isLocalEmpty) {
        // Incremental: use delta API with pagination
        final delta = await syncApi.deltaSync({'utime': _lastSyncTimeMs, 'limit': _pageSize});

        // Handle deleted books (tombstone)
        final deleted = (delta['deleted'] as List?)?.cast<String>() ?? [];
        if (deleted.isNotEmpty) {
          for (final serverId in deleted) {
            final localIdStr = await IdMappingDao.getLocalId(serverId, 'book');
            if (localIdStr != null) {
              final localId = int.tryParse(localIdStr) ?? 0;
              if (localId > 0) {
                try {
                  final book = await bookDao.selectBookById(localId);
                  book.isDeleted = true;
                  await bookDao.updateBook(book);
                } catch (_) {}
              }
            }
          }
        }

        final needFullSync = delta['need_full_sync'] as bool? ?? false;
        if (needFullSync) {
          serverBooks = await bookApi.listBooks();
        } else {
          final upserted = (delta['upserted'] as List?) ?? [];
          serverBooks = upserted.map((b) => ServerBook.fromJson(b as Map<String, dynamic>)).toList();
        }
      } else {
        // First sync or local empty: full pull
        debugPrint('[SyncManager] Full pull: fetching all books from server...');
        serverBooks = await bookApi.listBooks();
        debugPrint('[SyncManager] Full pull: got ${serverBooks.length} books');
      }

      final total = serverBooks.length;
      debugPrint('[SyncManager] Processing $total server books...');

      for (var i = 0; i < total; i++) {
        final serverBook = serverBooks[i];
        if (total > 0) {
          final pullProgress = 0.4 + (i / total) * 0.2;
          state = state.copyWith(progress: pullProgress, message: '下载书籍 ${i + 1}/$total...');
        }

        try {
          // Look up local ID via mapping table
          final localIdStr = await IdMappingDao.getLocalId(serverBook.id, 'book');
          if (localIdStr != null) {
            final localId = int.tryParse(localIdStr) ?? 0;
            if (localId > 0) {
              final localBook = await bookDao.selectBookById(localId);
              // Download cover if missing locally
              if (localBook.coverPath.isEmpty && serverBook.coverUrl.isNotEmpty) {
                final localCoverPath = await _downloadCover(serverBook.coverUrl);
                if (localCoverPath.isNotEmpty) {
                  localBook.coverPath = localCoverPath;
                  await bookDao.updateBook(localBook);
                }
              }
              final serverTime = DateTime.fromMillisecondsSinceEpoch(serverBook.uTime);
              if (serverTime.isAfter(localBook.updateTime)) {
                if (localBook.isDirty) {
                  conflicts.add(SyncConflict(
                    bookId: localId,
                    field: 'metadata',
                    localValue: '${localBook.title} (${localBook.updateTime})',
                    serverValue: '${serverBook.title} ($serverTime)',
                  ));
                }
                _updateLocalBookFromServer(localBook, serverBook);
                await bookDao.updateBook(localBook);
              }
              continue;
            }
          }
          // New book: insert and create mapping
          final newBook = _serverBookToLocal(serverBook);
          // Download cover from server
          if (serverBook.coverUrl.isNotEmpty) {
            final localCoverPath = await _downloadCover(serverBook.coverUrl);
            if (localCoverPath.isNotEmpty) {
              newBook.coverPath = localCoverPath;
            }
          }
          final insertedId = await bookDao.insertBook(newBook);
          await IdMappingDao.upsert(insertedId.toString(), serverBook.id, 'book');
        } catch (e) {
          debugPrint('[SyncManager] Insert book ${serverBook.id} error: $e');
        }
      }

      // Backfill covers for existing books missing local cover files
      await _backfillCovers(bookDao);
    } catch (e) {
      debugPrint('[SyncManager] Pull books error: $e');
      rethrow;
    }
  }

  Future<void> _pullAnnotations() async {
    final conn = ref.read(serverConnectionProvider.notifier);
    final annotationApi = conn.annotations;
    if (annotationApi == null) return;

    try {
      final bookDao = BookDao();
      final localBooks = await bookDao.selectBooks(includeDeleted: false);

      for (final book in localBooks) {
        try {
          final serverId = await IdMappingDao.getServerId(book.id.toString(), 'book');
          if (serverId == null) continue;
          final serverAnnotations = await annotationApi.listAnnotations(serverId);
          if (serverAnnotations.isEmpty) continue;

          // P-3: Batch load local annotations instead of O(N) per-annotation queries
          final localNotes = await BookNoteDao().selectBookNotesByBookId(book.id);
          final localByCfi = <String, BookNote>{};
          for (final note in localNotes) {
            localByCfi[note.cfi] = note;
          }

          for (final sa in serverAnnotations) {
            final existing = localByCfi[sa.cfi ?? ''];

            if (existing == null) {
              final localNote = _serverAnnotationToLocal(sa, book.id);
              await BookNoteDao().save(localNote);
            } else {
              final serverTime = DateTime.fromMillisecondsSinceEpoch(sa.uTime);
              if (serverTime.isAfter(existing.updateTime)) {
                existing.content = sa.content;
                existing.color = sa.color ?? existing.color;
                existing.type = sa.type;
                existing.updateTime = serverTime;
                await BookNoteDao().updateBookNoteById(existing);
              }
            }
          }
        } catch (e) {
          debugPrint('[SyncManager] Pull annotations for ${book.id}: $e');
        }
      }
    } catch (e) {
      debugPrint('[SyncManager] Pull annotations error: $e');
    }
  }

  Future<void> _pullProgress() async {
    final conn = ref.read(serverConnectionProvider.notifier);
    final progressApi = conn.progress;
    if (progressApi == null) return;

    try {
      final bookDao = BookDao();
      final localBooks = await bookDao.selectBooks(includeDeleted: false);

      for (final book in localBooks) {
        try {
          final serverProgress = await progressApi.getProgress(book.id.toString());
          final serverUpdatedAt = DateTime.fromMillisecondsSinceEpoch(serverProgress.updatedAt);
          if (serverUpdatedAt.isAfter(book.updateTime)) {
            book.readingPercentage = serverProgress.progress.toDouble();
            await bookDao.updateBook(book);
          }
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('[SyncManager] Pull progress error: $e');
    }
  }

  // ── Offline queue ────────────────────────────────────────────────

  Future<void> _processOfflineQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList('sync_offline_queue') ?? [];
    if (queue.isEmpty) return;

    debugPrint('[SyncManager] Processing ${queue.length} offline operations');
    final remaining = <String>[];

    for (final op in queue) {
      try {
        await _executeOfflineOp(op);
      } catch (e) {
        debugPrint('[SyncManager] Offline op failed, will retry: $op');
        remaining.add(op);
      }
    }

    await prefs.setStringList('sync_offline_queue', remaining);
  }

  Future<void> _executeOfflineOp(String op) async {
    final parts = op.split(':');
    if (parts.length < 2) return;
    final type = parts[0];
    final bookId = parts[1];

    final conn = ref.read(serverConnectionProvider.notifier);
    switch (type) {
      case 'update_rating':
        final bookApi = conn.books;
        if (bookApi != null && parts.length >= 3) {
          await bookApi.updateRating(bookId, double.parse(parts[2]));
        }
      case 'delete_book':
        final bookApi = conn.books;
        if (bookApi != null) {
          await bookApi.deleteBook(bookId);
        }
    }
  }

  /// Enqueue an operation for offline retry.
  static Future<void> enqueueOfflineOp(String op) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList('sync_offline_queue') ?? [];
    queue.add(op);
    await prefs.setStringList('sync_offline_queue', queue);
  }

  // ── Cover Download ──────────────────────────────────────────────

  /// Download book cover from server and save to local filesystem.
  /// Returns the local relative path if successful, or empty string.
  Future<String> _downloadCover(String coverUrl) async {
    if (coverUrl.isEmpty) return '';
    final conn = ref.read(serverConnectionProvider.notifier);
    final api = conn.api;
    if (api == null) return '';
    try {
      final coverDir = getCoverDir();
      if (!coverDir.existsSync()) coverDir.createSync(recursive: true);
      final localPath = 'cover/$coverUrl';
      final localFile = File(getBasePath(localPath));
      if (localFile.existsSync()) return localPath;

      await api.downloadFile('/img/covers/$coverUrl', savePath: localFile.path);
      if (localFile.existsSync()) return localPath;
    } catch (e) {
      debugPrint('[SyncManager] Download cover failed: $e');
    }
    return '';
  }

  /// Backfill covers for books that have no local cover file.
  Future<void> _backfillCovers(BookDao bookDao) async {
    final conn = ref.read(serverConnectionProvider.notifier);
    final bookApi = conn.books;
    if (bookApi == null) return;

    final allBooks = await bookDao.selectBooks(includeDeleted: false);
    final missingCover = allBooks.where((b) {
      if (b.coverPath.isEmpty) return true;
      final f = File(b.coverFullPath);
      return !f.existsSync();
    }).toList();

    if (missingCover.isEmpty) return;
    debugPrint('[SyncManager] Backfilling covers for ${missingCover.length} books...');

    // Fetch server book list to get cover_url mapping
    final serverBooks = await bookApi.listBooks();
    final coverMap = <String, String>{}; // serverId -> coverUrl
    for (final sb in serverBooks) {
      if (sb.coverUrl.isNotEmpty) coverMap[sb.id] = sb.coverUrl;
    }

    var downloaded = 0;
    for (final book in missingCover) {
      final serverId = await IdMappingDao.getServerId(book.id.toString(), 'book');
      if (serverId == null) continue;
      final coverUrl = coverMap[serverId];
      if (coverUrl == null || coverUrl.isEmpty) continue;

      final localPath = await _downloadCover(coverUrl);
      if (localPath.isNotEmpty) {
        book.coverPath = localPath;
        await bookDao.updateBook(book);
        downloaded++;
      }
    }
    debugPrint('[SyncManager] Backfilled $downloaded covers');
  }

  // ── Model Converters ────────────────────────────────────────────

  Map<String, dynamic> _localBookToServerFields(Book book) {
    return {'title': book.title, 'author': book.author, 'description': book.description ?? '', 'rating': book.rating};
  }

  Book _serverBookToLocal(ServerBook sb) {
    return Book(
      id: -1,
      title: sb.title,
      author: sb.author,
      coverPath: sb.coverUrl,
      filePath: '',
      lastReadPosition: '',
      readingPercentage: 0.0,
      isDeleted: false,
      description: sb.description,
      rating: sb.rating,
      createTime: DateTime.fromMillisecondsSinceEpoch(sb.cTime),
      updateTime: DateTime.fromMillisecondsSinceEpoch(sb.uTime),
    );
  }

  void _updateLocalBookFromServer(Book local, ServerBook server) {
    local.title = server.title;
    local.author = server.author;
    if (server.description != null) local.description = server.description;
    local.rating = server.rating;
    local.updateTime = DateTime.fromMillisecondsSinceEpoch(server.uTime);
  }

  BookNote _serverAnnotationToLocal(ServerAnnotation sa, int bookId) {
    return BookNote(
      bookId: bookId,
      content: sa.content,
      cfi: sa.cfi ?? '',
      chapter: sa.chapter ?? '',
      type: sa.type,
      color: sa.color ?? 'FFF176',
      createTime: DateTime.fromMillisecondsSinceEpoch(sa.cTime),
      updateTime: DateTime.fromMillisecondsSinceEpoch(sa.uTime),
    );
  }
}
