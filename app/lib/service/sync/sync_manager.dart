import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dao/book.dart';
import '../../dao/book_note.dart';
import '../../models/book.dart';
import '../../models/book_note.dart';
import '../../models/server/server_annotation.dart';
import '../../models/server/server_book.dart';
import '../../providers/server_connection_provider.dart';

part 'sync_manager.g.dart';

/// Sync status for UI display.
enum SyncStatus { idle, syncing, success, error, offline }

/// State of the incremental sync.
class SyncState {
  const SyncState({this.status = SyncStatus.idle, this.lastSyncTime, this.message, this.progress = 0.0});

  final SyncStatus status;
  final DateTime? lastSyncTime;
  final String? message;
  final double progress;

  SyncState copyWith({SyncStatus? status, DateTime? lastSyncTime, String? message, double? progress}) {
    return SyncState(
      status: status ?? this.status,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      message: message,
      progress: progress ?? this.progress,
    );
  }
}

/// Bidirectional incremental sync manager.
///
/// Uses timestamps to detect changes and syncs data between
/// local sqflite and Omnigram Server REST API.
@Riverpod(keepAlive: true)
class SyncManager extends _$SyncManager {
  Timer? _autoSyncTimer;

  @override
  SyncState build() {
    ref.onDispose(() => _autoSyncTimer?.cancel());
    return const SyncState();
  }

  /// Perform full bidirectional sync.
  Future<void> sync() async {
    final connection = ref.read(serverConnectionProvider);
    if (!connection.isConnected) {
      state = state.copyWith(status: SyncStatus.offline);
      return;
    }

    if (state.status == SyncStatus.syncing) return;

    state = state.copyWith(status: SyncStatus.syncing, message: '正在同步...', progress: 0.0);

    try {
      // 1. Push local changes to server
      await _pushBooks();
      state = state.copyWith(progress: 0.25, message: '上传书籍变更...');

      await _pushAnnotations();
      state = state.copyWith(progress: 0.5, message: '上传笔记...');

      // 2. Pull remote changes from server
      await _pullBooks();
      state = state.copyWith(progress: 0.75, message: '下载更新...');

      await _pullAnnotations();
      state = state.copyWith(progress: 0.9, message: '同步笔记...');

      // 3. Pull reading progress
      await _pullProgress();

      final now = DateTime.now();
      state = SyncState(status: SyncStatus.success, lastSyncTime: now, message: '同步完成', progress: 1.0);

      // Reset to idle after showing success
      Future.delayed(const Duration(seconds: 3), () {
        if (state.status == SyncStatus.success) {
          state = state.copyWith(status: SyncStatus.idle);
        }
      });
    } catch (e) {
      debugPrint('[SyncManager] Sync error: $e');
      state = state.copyWith(
        status: SyncStatus.error,
        message: '同步失败: ${e.toString().substring(0, (e.toString().length).clamp(0, 100))}',
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

  // ── Push: Local → Server ────────────────────────────────────────

  Future<void> _pushBooks() async {
    final books = ref.read(serverConnectionProvider.notifier);
    final bookApi = books.books;
    if (bookApi == null) return;

    final localBooks = await BookDao().selectBooks(includeDeleted: false);
    for (final book in localBooks) {
      try {
        // Check if book exists on server by trying to get it
        final serverBookData = _localBookToServerFields(book);
        await bookApi.updateBook(book.id.toString(), serverBookData);
      } catch (e) {
        // Book doesn't exist on server — this is expected for local-only books
        debugPrint('[SyncManager] Push book ${book.id} skipped: $e');
      }
    }
  }

  Future<void> _pushAnnotations() async {
    final conn = ref.read(serverConnectionProvider.notifier);
    final annotationApi = conn.annotations;
    if (annotationApi == null) return;

    // Get all local notes
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

  // ── Pull: Server → Local ────────────────────────────────────────

  Future<void> _pullBooks() async {
    final conn = ref.read(serverConnectionProvider.notifier);
    final bookApi = conn.books;
    if (bookApi == null) return;

    try {
      final serverBooks = await bookApi.listBooks();
      final bookDao = BookDao();

      for (final serverBook in serverBooks) {
        // Check if book exists locally
        final bookId = int.tryParse(serverBook.id) ?? 0;
        try {
          final localBook = await bookDao.selectBookById(bookId);
          // Existing book — last-write-wins by timestamp
          final serverTime = DateTime.fromMillisecondsSinceEpoch(serverBook.uTime * 1000);
          if (serverTime.isAfter(localBook.updateTime)) {
            _updateLocalBookFromServer(localBook, serverBook);
            await bookDao.updateBook(localBook);
          }
        } catch (_) {
          // Book not found locally — create from server
          final newBook = _serverBookToLocal(serverBook);
          await bookDao.insertBook(newBook);
        }
      }
    } catch (e) {
      debugPrint('[SyncManager] Pull books error: $e');
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
          final serverAnnotations = await annotationApi.listAnnotations(book.id.toString());

          for (final sa in serverAnnotations) {
            // Check if annotation exists locally by CFI
            final existingList = await BookNoteDao().selectBookNoteByCfiAndBookId(sa.cfi ?? '', book.id);

            if (existingList.isEmpty) {
              // New from server
              final localNote = _serverAnnotationToLocal(sa, book.id);
              await BookNoteDao().save(localNote);
            } else {
              // Last-write-wins
              final existing = existingList.first;
              final serverTime = DateTime.fromMillisecondsSinceEpoch(sa.uTime * 1000);
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

          if (serverProgress.progress > book.readingPercentage) {
            book.readingPercentage = serverProgress.progress.toDouble();
            await bookDao.updateBook(book);
          }
        } catch (_) {
          // No progress on server — expected
        }
      }
    } catch (e) {
      debugPrint('[SyncManager] Pull progress error: $e');
    }
  }

  // ── Model Converters ────────────────────────────────────────────

  Map<String, dynamic> _localBookToServerFields(Book book) {
    return {'title': book.title, 'author': book.author, 'description': book.description ?? '', 'rating': book.rating};
  }

  Book _serverBookToLocal(ServerBook sb) {
    return Book(
      id: int.tryParse(sb.id) ?? 0,
      title: sb.title,
      author: sb.author,
      coverPath: sb.coverUrl,
      filePath: '',
      lastReadPosition: '',
      readingPercentage: 0.0,
      isDeleted: false,
      description: sb.description,
      rating: sb.rating,
      createTime: DateTime.fromMillisecondsSinceEpoch(sb.cTime * 1000),
      updateTime: DateTime.fromMillisecondsSinceEpoch(sb.uTime * 1000),
    );
  }

  void _updateLocalBookFromServer(Book local, ServerBook server) {
    local.title = server.title;
    local.author = server.author;
    if (server.description != null) local.description = server.description;
    local.rating = server.rating;
    local.updateTime = DateTime.fromMillisecondsSinceEpoch(server.uTime * 1000);
  }

  BookNote _serverAnnotationToLocal(ServerAnnotation sa, int bookId) {
    return BookNote(
      bookId: bookId,
      content: sa.content,
      cfi: sa.cfi ?? '',
      chapter: sa.chapter ?? '',
      type: sa.type,
      color: sa.color ?? 'FFF176',
      createTime: DateTime.fromMillisecondsSinceEpoch(sa.cTime * 1000),
      updateTime: DateTime.fromMillisecondsSinceEpoch(sa.uTime * 1000),
    );
  }
}
