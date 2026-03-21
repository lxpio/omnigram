import 'dart:io';

import 'package:omnigram/utils/log/common.dart';
import 'package:omnigram/utils/platform_utils.dart';
import 'package:path_provider/path_provider.dart';

/// Callback for migration progress updates
typedef MigrationProgressCallback = void Function(
    String currentItem, int progress, int total);

/// Result of migration check
class MigrationCheckResult {
  final bool needsMigration;
  final String? oldPath;
  final String? newPath;

  MigrationCheckResult({
    required this.needsMigration,
    this.oldPath,
    this.newPath,
  });
}

/// Checks if macOS data migration is needed.
/// Migration is needed when:
/// 1. Platform is macOS
/// 2. Old path (Documents) has data
/// 3. New path (Application Support) is empty or doesn't exist
Future<MigrationCheckResult> checkMigrationNeeded() async {
  if (!AnxPlatform.isMacOS) {
    return MigrationCheckResult(needsMigration: false);
  }

  try {
    final oldPath = (await getApplicationDocumentsDirectory()).path;
    final newPath = (await getApplicationSupportDirectory()).path;

    // Check if old path has any of our data directories or log file
    final dataFolders = ['file', 'cover', 'font', 'bgimg', 'databases'];
    bool oldHasData = false;

    for (final folder in dataFolders) {
      final oldDir = Directory('$oldPath${Platform.pathSeparator}$folder');
      if (oldDir.existsSync() && oldDir.listSync().isNotEmpty) {
        oldHasData = true;
        break;
      }
    }

    // Also check for log file
    final oldLogFile = File('$oldPath${Platform.pathSeparator}anx_reader.log');
    if (oldLogFile.existsSync()) {
      oldHasData = true;
    }

    if (!oldHasData) {
      return MigrationCheckResult(needsMigration: false);
    }

    // Check if new path already has data
    bool newHasData = false;
    for (final folder in dataFolders) {
      final newDir = Directory('$newPath${Platform.pathSeparator}$folder');
      if (newDir.existsSync() && newDir.listSync().isNotEmpty) {
        newHasData = true;
        break;
      }
    }

    // If new path already has data, skip migration
    if (newHasData) {
      AnxLog.info('Migration: New path already has data, skipping migration');
      return MigrationCheckResult(needsMigration: false);
    }

    return MigrationCheckResult(
      needsMigration: true,
      oldPath: oldPath,
      newPath: newPath,
    );
  } catch (e) {
    AnxLog.severe('Migration check failed: $e');
    return MigrationCheckResult(needsMigration: false);
  }
}

/// Performs the data migration from Documents to Application Support.
/// Returns true if migration was successful.
Future<bool> performMigration({
  required String oldPath,
  required String newPath,
  MigrationProgressCallback? onProgress,
}) async {
  // Items to migrate: 5 folders + 1 log file = 6 items
  final dataFolders = ['file', 'cover', 'font', 'bgimg', 'databases'];
  final successfullyMigrated = <String>[];
  const int totalItems = 6; // 5 folders + 1 log file

  try {
    for (int i = 0; i < dataFolders.length; i++) {
      final folder = dataFolders[i];
      onProgress?.call(folder, i + 1, totalItems);

      final oldDir = Directory('$oldPath${Platform.pathSeparator}$folder');
      final newDir = Directory('$newPath${Platform.pathSeparator}$folder');

      if (!oldDir.existsSync()) {
        continue;
      }

      // Create new directory if it doesn't exist
      if (!newDir.existsSync()) {
        await newDir.create(recursive: true);
      }

      // Copy all contents
      await _copyDirectory(oldDir, newDir);
      successfullyMigrated.add(folder);

      AnxLog.info('Migration: Copied $folder successfully');
    }

    // Also copy the log file if it exists
    onProgress?.call('anx_reader.log', 6, totalItems);
    final oldLogFile = File('$oldPath${Platform.pathSeparator}anx_reader.log');
    if (oldLogFile.existsSync()) {
      final newLogFile =
          File('$newPath${Platform.pathSeparator}anx_reader.log');
      await oldLogFile.copy(newLogFile.path);
      AnxLog.info('Migration: Copied log file successfully');
    }

    // All copies successful, now delete old data
    AnxLog.info('Migration: All data copied, cleaning up old data...');
    for (final folder in successfullyMigrated) {
      final oldDir = Directory('$oldPath${Platform.pathSeparator}$folder');
      if (oldDir.existsSync()) {
        await oldDir.delete(recursive: true);
        AnxLog.info('Migration: Deleted old $folder');
      }
    }

    // Delete old log file
    if (oldLogFile.existsSync()) {
      await oldLogFile.delete();
    }

    AnxLog.info('Migration: Completed successfully');
    return true;
  } catch (e) {
    AnxLog.severe('Migration failed: $e');
    return false;
  }
}

/// Recursively copies a directory
Future<void> _copyDirectory(Directory source, Directory destination) async {
  await for (final entity in source.list(recursive: false)) {
    final newPath =
        '${destination.path}${Platform.pathSeparator}${entity.path.split(Platform.pathSeparator).last}';

    if (entity is File) {
      await entity.copy(newPath);
    } else if (entity is Directory) {
      final newDir = Directory(newPath);
      await newDir.create(recursive: true);
      await _copyDirectory(entity, newDir);
    }
  }
}
