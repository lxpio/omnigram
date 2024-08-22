import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:omnigram/entities/logger_message.entity.dart';
import 'package:omnigram/entities/isar_store.entity.dart';
import 'package:omnigram/services/logger.service.dart';
import 'package:omnigram/utils/migration.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest.dart';
import 'package:logging/logging.dart';

class BuildConfig {
 

  static final BuildConfig instance = BuildConfig._internal();

  BuildConfig._internal();

  static Future<Isar> initialize() async {

    //初始化数据库
    final db = await loadDb();


    //初始化日志
    OmnigramLogger();

    var log = Logger("ImmichErrorLogger");

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      log.severe(
        'FlutterError - Catch all',
        "${details.toString()}\nException: ${details.exception}\nLibrary: ${details.library}\nContext: ${details.context}",
        details.stack,
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      log.severe('PlatformDispatcher - Catch all', error, stack);
      return true;
    };

    //初始化时区
    initializeTimeZones();


    await migrateDatabaseIfNeeded(db);


    await EasyLocalization.ensureInitialized();
  

    return db;
  }
}


Future<Isar> loadDb() async {
  final dir = await getApplicationDocumentsDirectory();
  Isar db = await Isar.open(
    [
      StoreValueSchema,
      LoggerMessageSchema,
      // if (Platform.isAndroid) AndroidDeviceAssetSchema,
      // if (Platform.isIOS) IOSDeviceAssetSchema,
    ],
    directory: dir.path,
    maxSizeMiB: 1024,
  );
  IsarStore.init(db);
  return db;
}