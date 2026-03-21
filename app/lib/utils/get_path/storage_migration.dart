import 'dart:io';

import 'package:omnigram/utils/log/common.dart';
import 'package:path_provider/path_provider.dart';

/// Callback for migration progress updates
typedef MigrationProgressCallback = void Function(
    String currentItem, int progress, int total);

/// Performs data migration from source path to destination path.
/// Used for custom storage location feature on Windows/macOS.
/// Returns true if migration was successful.
Future<bool> performStorageMigration({
  required String sourcePath,
  required String destinationPath,
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

      final sourceDir =
          Directory('$sourcePath${Platform.pathSeparator}$folder');
      final destDir =
          Directory('$destinationPath${Platform.pathSeparator}$folder');

      if (!sourceDir.existsSync()) {
        continue;
      }

      // Create destination directory if it doesn't exist
      if (!destDir.existsSync()) {
        await destDir.create(recursive: true);
      }

      // Copy all contents
      await _copyDirectory(sourceDir, destDir);
      successfullyMigrated.add(folder);

      AnxLog.info('StorageMigration: Copied $folder successfully');
    }

    // Also copy the log file if it exists
    onProgress?.call('anx_reader.log', 6, totalItems);
    final sourceLogFile =
        File('$sourcePath${Platform.pathSeparator}anx_reader.log');
    if (sourceLogFile.existsSync()) {
      final destLogFile =
          File('$destinationPath${Platform.pathSeparator}anx_reader.log');
      await sourceLogFile.copy(destLogFile.path);
      AnxLog.info('StorageMigration: Copied log file successfully');
    }

    // All copies successful, now delete old data
    AnxLog.info(
        'StorageMigration: All data copied, cleaning up source data...');
    for (final folder in successfullyMigrated) {
      final sourceDir =
          Directory('$sourcePath${Platform.pathSeparator}$folder');
      if (sourceDir.existsSync()) {
        await sourceDir.delete(recursive: true);
        AnxLog.info('StorageMigration: Deleted source $folder');
      }
    }

    // Delete source log file
    if (sourceLogFile.existsSync()) {
      await sourceLogFile.delete();
    }

    AnxLog.info('StorageMigration: Completed successfully');
    return true;
  } catch (e) {
    AnxLog.severe('StorageMigration failed: $e');
    return false;
  }
}

/// Checks if a directory is empty (contains no files or subdirectories)
Future<bool> isDirectoryEmpty(String path) async {
  final dir = Directory(path);
  if (!dir.existsSync()) {
    return true;
  }
  final contents = await dir.list().toList();
  return contents.isEmpty;
}

/// Gets the default storage path for Windows/macOS
Future<String> getDefaultStoragePath() async {
  return (await getApplicationSupportDirectory()).path;
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
