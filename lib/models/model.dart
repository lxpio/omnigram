import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:universal_platform/universal_platform.dart';
import '../utils/constants.dart';
import 'objectbox.g.dart';

class AppStore {
  late final Store _store;
  bool _lock = false;

  static final instance = AppStore._internal();
  AppStore._internal();

  static Future<void> initialize(String dbName) async {
    //if has initialized
    if (instance._lock) return;

    instance._lock = true;

    if (UniversalPlatform.isWeb) {
      //TODO 使用远程API接口调用返回
    } else {
      final docsDir = await getApplicationDocumentsDirectory();

      //创建文档存储目录
      globalEpubPath = '${docsDir.path}/local_epubs';

      if (!await Directory(globalEpubPath).exists()) {
        await Directory(globalEpubPath).create(recursive: true);
        print('Directory created at: $globalEpubPath');
      }

      instance._store =
          await openStore(directory: p.join(docsDir.path, dbName));

      // instance._store = await openStore(directory: p.join('./build', dbName));
    }
  }

  void close() {
    _store.close();
  }

  Box<T> box<T>() {
    return _store.box<T>();
  }
}
