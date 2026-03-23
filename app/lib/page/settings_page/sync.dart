import 'dart:convert';
import 'dart:io';

import 'package:omnigram/dao/database.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/main.dart';
import 'package:omnigram/providers/sync.dart';
import 'package:omnigram/utils/platform_utils.dart';
import 'package:omnigram/utils/save_file_to_download.dart';
import 'package:omnigram/utils/get_path/get_temp_dir.dart';
import 'package:omnigram/utils/get_path/databases_path.dart';
import 'package:omnigram/utils/get_path/get_base_path.dart';
import 'package:omnigram/utils/log/common.dart';
import 'package:omnigram/utils/toast/common.dart';
import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/widgets/settings/settings_title.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:path/path.dart' as path;
import 'package:omnigram/widgets/settings/settings_section.dart';
import 'package:omnigram/widgets/settings/settings_tile.dart';

const String _prefsBackupFileName = 'anx_shared_prefs.json';

class SyncSetting extends ConsumerStatefulWidget {
  const SyncSetting({super.key});

  @override
  ConsumerState<SyncSetting> createState() => _SyncSettingState();
}

class _SyncSettingState extends ConsumerState<SyncSetting> {
  @override
  Widget build(BuildContext context) {
    return settingsSections(
      sections: [
        SettingsSection(
          title: Text(L10n.of(context).restoreBackup),
          tiles: [
            SettingsTile.navigation(
              title: Text(L10n.of(context).restoreBackup),
              leading: const Icon(Icons.restore),
              onPressed: (context) {
                ref.read(syncProvider.notifier).showBackupManagementDialog();
              },
            ),
          ],
        ),
        SettingsSection(
          title: Text(L10n.of(context).exportAndImport),
          tiles: [
            SettingsTile.navigation(
              title: Text(L10n.of(context).exportAndImportExport),
              leading: const Icon(Icons.cloud_upload),
              onPressed: (context) {
                exportData(context);
              },
            ),
            SettingsTile.navigation(
              title: Text(L10n.of(context).exportAndImportImport),
              leading: const Icon(Icons.cloud_download),
              onPressed: (context) {
                importData();
              },
            ),
          ],
        ),
      ],
    );
  }

  void _showDataDialog(String title) {
    Future.microtask(() {
      SmartDialog.show(
        builder: (BuildContext context) => SimpleDialog(
          title: Center(child: Text(title)),
          children: const [Center(child: CircularProgressIndicator())],
        ),
      );
    });
  }

  Future<void> exportData(BuildContext context) async {
    AnxLog.info('exportData: start');
    if (!mounted) return;

    _showDataDialog(L10n.of(context).exporting);

    final File prefsBackupFile = await _createPrefsBackupFile();

    RootIsolateToken token = RootIsolateToken.instance!;
    final zipPath = await compute(createZipFile, {'token': token, 'prefsBackupFilePath': prefsBackupFile.path});

    final file = File(zipPath);
    SmartDialog.dismiss();
    if (await file.exists()) {
      String fileName = 'Omnigram-Backup-${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}-v3.zip';

      String? filePath = await saveFileToDownload(
        sourceFilePath: file.path,
        fileName: fileName,
        mimeType: 'application/zip',
      );

      await file.delete();

      if (filePath != null) {
        AnxLog.info('exportData: Saved to: $filePath');
        AnxToast.show(L10n.of(navigatorKey.currentContext!).exportTo(filePath));
      } else {
        AnxLog.info('exportData: Cancelled');
        AnxToast.show(L10n.of(navigatorKey.currentContext!).commonCanceled);
      }
    }
  }

  Future<void> importData() async {
    AnxLog.info('importData: start');
    if (!mounted) return;

    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['zip']);

    if (result == null) {
      return;
    }

    String? filePath = result.files.single.path;
    if (filePath == null) {
      AnxLog.info('importData: cannot get file path');
      AnxToast.show(L10n.of(navigatorKey.currentContext!).importCannotGetFilePath);
      return;
    }

    File zipFile = File(filePath);
    if (!await zipFile.exists()) {
      AnxLog.info('importData: zip file not found');
      AnxToast.show(L10n.of(navigatorKey.currentContext!).importCannotGetFilePath);
      return;
    }
    _showDataDialog(L10n.of(navigatorKey.currentContext!).importing);

    String pathSeparator = Platform.pathSeparator;

    Directory cacheDir = await getAnxTempDir();
    String cachePath = cacheDir.path;
    String extractPath = '$cachePath${pathSeparator}omnigram_import';

    try {
      await Directory(extractPath).create(recursive: true);

      await compute(extractZipFile, {'zipFilePath': zipFile.path, 'destinationPath': extractPath});

      String docPath = await getAnxDocumentsPath();
      _copyDirectorySync(Directory('$extractPath${pathSeparator}file'), getFileDir(path: docPath));
      _copyDirectorySync(Directory('$extractPath${pathSeparator}cover'), getCoverDir(path: docPath));
      _copyDirectorySync(Directory('$extractPath${pathSeparator}font'), getFontDir(path: docPath));
      _copyDirectorySync(Directory('$extractPath${pathSeparator}bgimg'), getBgimgDir(path: docPath));

      DBHelper.close();
      _copyDirectorySync(Directory('$extractPath${pathSeparator}databases'), await getAnxDataBasesDir());
      DBHelper().initDB();

      await _restorePrefsFromBackup(extractPath);

      AnxLog.info('importData: import success');
      AnxToast.show(L10n.of(navigatorKey.currentContext!).importSuccessRestartApp);
    } catch (e) {
      AnxLog.info('importData: error while unzipping or copying files: $e');
      AnxToast.show(L10n.of(navigatorKey.currentContext!).importFailed(e.toString()));
    } finally {
      SmartDialog.dismiss();
      await Directory(extractPath).delete(recursive: true);
    }
  }

  void _copyDirectorySync(Directory source, Directory destination) {
    if (!source.existsSync()) {
      return;
    }
    if (destination.existsSync()) {
      destination.deleteSync(recursive: true);
    }
    destination.createSync(recursive: true);
    source.listSync(recursive: false).forEach((entity) {
      final newPath = destination.path + Platform.pathSeparator + path.basename(entity.path);
      if (entity is File) {
        entity.copySync(newPath);
      } else if (entity is Directory) {
        _copyDirectorySync(entity, Directory(newPath));
      }
    });
  }
}

Future<String> createZipFile(Map<String, dynamic> params) async {
  RootIsolateToken token = params['token'];
  final String prefsBackupFilePath = params['prefsBackupFilePath'];
  final File prefsBackupFile = File(prefsBackupFilePath);
  BackgroundIsolateBinaryMessenger.ensureInitialized(token);
  final date = '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
  final zipPath = '${(await getAnxTempDir()).path}/Omnigram-Backup-$date.zip';
  final docPath = await getAnxDocumentsPath();
  final directoryList = [
    getFileDir(path: docPath),
    getCoverDir(path: docPath),
    getFontDir(path: docPath),
    getBgimgDir(path: docPath),
    if (!AnxPlatform.isOhos) await getAnxDataBasesDir(),
    prefsBackupFile,
  ];

  AnxLog.info('exportData: directoryList: $directoryList');

  final encoder = ZipFileEncoder();
  encoder.create(zipPath);

  if (AnxPlatform.isOhos) {
    final dbDir = await getAnxDataBasesDir();
    final dbFile = File('${dbDir.path}/app_database.db');
    if (await dbFile.exists()) {
      await encoder.addFile(dbFile, 'databases/app_database.db');
    }
  } else {
    final dbDir = await getAnxDataBasesDir();
    await encoder.addDirectory(dbDir);
  }

  for (final dir in directoryList) {
    if (dir is Directory) {
      await encoder.addDirectory(dir);
    } else if (dir is File) {
      await encoder.addFile(dir);
    }
  }
  encoder.close();
  if (await prefsBackupFile.exists()) {
    await prefsBackupFile.delete();
  }
  return zipPath;
}

Future<void> extractZipFile(Map<String, String> params) async {
  final zipFilePath = params['zipFilePath']!;
  final destinationPath = params['destinationPath']!;

  final input = InputFileStream(zipFilePath);
  try {
    final archive = ZipDecoder().decodeStream(input);
    extractArchiveToDiskSync(archive, destinationPath);
    archive.clearSync();
  } finally {
    await input.close();
  }
}

Future<File> _createPrefsBackupFile() async {
  final Directory tempDir = await getAnxTempDir();
  final File backupFile = File('${tempDir.path}/$_prefsBackupFileName');
  final Map<String, dynamic> prefsMap = await Prefs().buildPrefsBackupMap();
  await backupFile.writeAsString(jsonEncode(prefsMap));
  return backupFile;
}

Future<bool> _restorePrefsFromBackup(String extractPath) async {
  final File backupFile = File('$extractPath/$_prefsBackupFileName');
  if (!await backupFile.exists()) {
    return false;
  }
  try {
    final dynamic decoded = jsonDecode(await backupFile.readAsString());
    if (decoded is Map<String, dynamic>) {
      await Prefs().applyPrefsBackupMap(decoded);
      return true;
    }
    AnxLog.info('importData: prefs backup has unexpected format');
  } catch (e) {
    AnxLog.info('importData: failed to restore prefs backup: $e');
  }
  return false;
}
