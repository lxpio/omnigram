import 'dart:io' as io;
import 'package:omnigram/enums/sync_direction.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/main.dart';
import 'package:omnigram/models/sync_state_model.dart';
import 'package:omnigram/providers/book_list.dart';
import 'package:omnigram/providers/tb_groups.dart';
import 'package:omnigram/service/database_sync_manager.dart';
import 'package:omnigram/dao/database.dart';
import 'package:omnigram/utils/get_path/databases_path.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:path/path.dart';
import 'package:omnigram/utils/log/common.dart';
import 'package:omnigram/utils/toast/common.dart';
import 'package:omnigram/dao/book.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync.g.dart';

@Riverpod(keepAlive: true)
class Sync extends _$Sync {
  static final Sync _instance = Sync._internal();

  factory Sync() {
    return _instance;
  }

  Sync._internal();

  @override
  SyncStateModel build() {
    return const SyncStateModel(
      direction: SyncDirection.both,
      isSyncing: false,
      total: 0,
      count: 0,
      fileName: '',
    );
  }

  void changeState(SyncStateModel s) {
    state = s;
  }

  Future<bool> isCurrentEmpty() async {
    List<String> currentBooks = await bookDao.getCurrentBooks();
    List<String> currentCover = await bookDao.getCurrentCover();
    List<String> totalCurrentFiles = [...currentCover, ...currentBooks];
    return totalCurrentFiles.isEmpty;
  }

  /// Get available database backup list
  Future<List<String>> getAvailableBackups() async {
    return await DatabaseSyncManager.getAvailableBackups();
  }

  /// Show database backup management dialog
  Future<void> showBackupManagementDialog() async {
    try {
      final backups = await getAvailableBackups();

      await SmartDialog.show(
        builder: (context) => AlertDialog(
          title: Text(L10n.of(context).databaseBackupManagement),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(L10n.of(context).availableBackups),
                const SizedBox(height: 12),
                if (backups.isEmpty)
                  Text(
                    L10n.of(context).noBackupsAvailable,
                    style: const TextStyle(color: Colors.grey),
                  )
                else
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: backups.length,
                      itemBuilder: (context, index) {
                        final backup = backups[index];
                        final fileName = backup.split('/').last;
                        final timestamp = fileName
                            .replaceAll('backup_database_', '')
                            .replaceAll('.db', '');

                        return ListTile(
                          title: Text('Backup ${index + 1}'),
                          subtitle: Text(timestamp),
                          trailing: ElevatedButton(
                            onPressed: () async {
                              await _restoreFromBackup(backup);
                            },
                            child: Text(L10n.of(context).restore),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(L10n.of(context).commonCancel),
            ),
          ],
        ),
      );
    } catch (e) {
      AnxLog.severe('Failed to show backup management dialog: $e');
      AnxToast.show('Failed to get backup list: $e');
    }
  }

  /// Restore database from specified backup
  Future<void> _restoreFromBackup(String backupPath) async {
    try {
      final databasePath = await getAnxDataBasesPath();
      final localDbPath = join(databasePath, 'app_database.db');

      // Confirmation dialog
      final confirmed = await SmartDialog.show<bool>(
        builder: (context) => AlertDialog(
          title: Text(L10n.of(context).confirmRestore),
          content: Text(L10n.of(context).restoreWarning),
          actions: [
            TextButton(
              onPressed: () => SmartDialog.dismiss(result: false),
              child: Text(L10n.of(context).commonCancel),
            ),
            FilledButton(
              onPressed: () => SmartDialog.dismiss(result: true),
              child: Text(L10n.of(context).commonConfirm),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Execute restore
      await DBHelper.close();
      await io.File(backupPath).copy(localDbPath);
      await DBHelper().initDB();

      // Refresh related providers
      try {
        ref.read(bookListProvider.notifier).refresh();
        ref.read(groupDaoProvider.notifier).refresh();
      } catch (e) {
        AnxLog.info('Failed to refresh providers after restore: $e');
      }

      AnxToast.show(L10n.of(navigatorKey.currentContext!).restoreSuccess);
      AnxLog.info('Database restored from backup: $backupPath');
    } catch (e) {
      AnxLog.severe('Failed to restore from backup: $e');
      AnxToast.show('Restore failed: $e');
    }
  }
}
