import 'dart:io';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:omnigram/entities/book.entity.dart';
import 'package:omnigram/entities/etag.entity.dart';
import 'package:omnigram/entities/logger_message.entity.dart';
import 'package:omnigram/entities/isar_store.entity.dart';
import 'package:omnigram/entities/note.entity.dart';
import 'package:omnigram/entities/user.entity.dart';
import 'package:omnigram/providers/tts/tts.service.dart';
import 'package:omnigram/services/logger.service.dart';
import 'package:omnigram/utils/constants.dart';
import 'package:omnigram/utils/migration.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest.dart';
import 'package:logging/logging.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:timeago/timeago.dart' as timeago;

class BuildConfig {
  static final BuildConfig instance = BuildConfig._internal();

  BuildConfig._internal();

  static Future<Isar> initialize() async {
    //初始化数据库
    final dir = await getApplicationDocumentsDirectory();
    globalDBPath = '${dir.path}/local_cache';
    globalEpubPath = '${dir.path}/local_epubs';
    globalCachePath = '${dir.path}/local_cache';

    if (!await Directory(globalDBPath).exists()) {
      await Directory(globalDBPath).create(recursive: true);
    }
    final db = await loadDb(globalDBPath);

    var log = Logger("OmnigramErrorLogger");

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
      //创建文档存储目录
      if (!await Directory(globalEpubPath).exists()) {
        await Directory(globalEpubPath).create(recursive: true);
      }

      if (!await Directory(globalCachePath).exists()) {
        await Directory(globalCachePath).create(recursive: true);
      }

      //创建TTS缓存目录
      final ttsCacheDir = await TTS.getCacheDir();

      if (!await ttsCacheDir.exists()) {
        await ttsCacheDir.create(recursive: true);
      }
    }

    timeago.setLocaleMessages('zh', timeago.ZhCnMessages());

    await migrateDatabaseIfNeeded(db);

    await EasyLocalization.ensureInitialized();

    return db;
  }
}

Future<Isar> loadDb(String dbPath) async {
  final db = Isar.open(
    schemas: [
      StoreValueSchema,
      LoggerMessageSchema,
      BookEntitySchema,
      UserSchema,
      ETagSchema, //存储扫描相关结果
      NoteEntitySchema, //笔记
      // if (Platform.isAndroid) AndroidDeviceAssetSchema,
      // if (Platform.isIOS) IOSDeviceAssetSchema,
    ],
    directory: dbPath,
    maxSizeMiB: 1024,
  );
  IsarStore.init(db);

  //初始化日志
  OmnigramLogger.instance.initialize(db);
  return db;
}
