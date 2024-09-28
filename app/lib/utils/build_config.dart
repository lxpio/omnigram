import 'dart:io';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:omnigram/entities/book.entity.dart';
import 'package:omnigram/entities/logger_message.entity.dart';
import 'package:omnigram/entities/isar_store.entity.dart';
import 'package:omnigram/entities/user.entity.dart';
import 'package:omnigram/services/logger.service.dart';
import 'package:omnigram/utils/constants.dart';
import 'package:omnigram/utils/migration.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest.dart';
import 'package:logging/logging.dart';
import 'package:universal_platform/universal_platform.dart';

class BuildConfig {
 

  static final BuildConfig instance = BuildConfig._internal();

  BuildConfig._internal();

  static Future<Isar> initialize() async {

    //初始化数据库
    final db = await loadDb();




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

if (UniversalPlatform.isWeb) {
      //TODO 使用远程API接口调用返回
    } else {
      final docsDir = await getApplicationDocumentsDirectory();
  //创建文档存储目录
      globalEpubPath = '${docsDir.path}/local_epubs';

      if (!await Directory(globalEpubPath).exists()) {
        await Directory(globalEpubPath).create(recursive: true);
      }
      globalCachePath = '${docsDir.path}/local_cache';
      if (!await Directory(globalCachePath).exists()) {
        await Directory(globalCachePath).create(recursive: true);
      }
    }

    await migrateDatabaseIfNeeded(db);


    await EasyLocalization.ensureInitialized();
  

    return db;
  }
}


Future<Isar> loadDb() async {
  final dir = await getApplicationDocumentsDirectory();


  final db =  Isar.open(
    schemas: [
      StoreValueSchema,
      LoggerMessageSchema,
      BookEntitySchema,
      UserSchema,
      // if (Platform.isAndroid) AndroidDeviceAssetSchema,
      // if (Platform.isIOS) IOSDeviceAssetSchema,
    ],
    directory: dir.path,
    maxSizeMiB: 1024,
  );
  IsarStore.init(db);

      //初始化日志
  OmnigramLogger.instance.initialize(db);
  return db;
}