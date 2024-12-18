import 'dart:io';

import 'package:dio/dio.dart';

import 'package:flutter/widgets.dart';
import 'package:isar/isar.dart';
import 'package:logging/logging.dart';
import 'package:omnigram/entities/book.entity.dart';
import 'package:omnigram/entities/isar_store.entity.dart';
import 'package:omnigram/entities/user.entity.dart';

import 'package:omnigram/services/book.service.dart';
import 'package:omnigram/services/sync.service.dart';
import 'package:omnigram/utils/build_config.dart';
import 'package:openapi/openapi.dart';
import 'package:test/test.dart';

//@see 如果需要单元测试，则需要 下载 动态包 https://github.com/isar/isar/releases

void main() {
  test('sync delta book should be worked', () async {
    await Isar.initialize('/Users/liuyou/Workspace/libisar_macos.dylib');
    WidgetsFlutterBinding.ensureInitialized();

    //初始化数据库
    // final mytestPath = await getTemporaryDirectory();

    final db = await loadDb('/tmp/bookservice_test.db');

    var log = Logger("OmmigramErrorLogger");

    // final ref = ProviderContainer();

    final bookService = BookService(_createApi());

    final (books, ids) = await bookService.getChangedBooks(1729834830057);

    if (books != null) {
      debugPrint("get ${books.length} books");
      for (var book in books) {
        debugPrint(book.toJson());
      }
    }

    if (ids != null) {
      debugPrint("get ${ids.length} ids");
      for (var id in ids) {
        debugPrint(id);
      }
    }
  });

  test('full sync book should be worked', () async {
    await Isar.initialize('/Users/liuyou/Workspace/libisar_macos.dylib');
    WidgetsFlutterBinding.ensureInitialized();

    //初始化数据库
    // final mytestPath = await getTemporaryDirectory();

    final db = await loadDb('/tmp/bookservice_test.db');

    var log = Logger("OmmigramErrorLogger");

    // final ref = ProviderContainer();

    final bookService = BookService(_createApi());

    final books = await bookService.loadBooks(1, DateTime.now().millisecondsSinceEpoch);

    if (books != null) {
      File outputFile = File('/tmp/hello.out');

      if (books.length > 10) {
        for (var book in books.sublist(0, 10)) {
          outputFile.writeAsStringSync(book.toJson(), mode: FileMode.append);
        }
      }
      outputFile.writeAsStringSync("get ${books.length} books", mode: FileMode.append);
    }
  });

  test('sync book to db should be worked', () async {
    await Isar.initialize('/Users/liuyou/Workspace/libisar_macos.dylib');
    WidgetsFlutterBinding.ensureInitialized();

    //初始化数据库
    // final mytestPath = await getTemporaryDirectory();

    final db = await loadDb('/tmp/bookservice_test.db');

    var log = Logger("OmmigramErrorLogger");

    // final ref = ProviderContainer();

    final bookService = BookService(_createApi());

    final syncService = SyncService(db);

    final user = User(
      id: 1,
      name: "test",
      email: "test@example.com",
      updatedAt: DateTime.now(),
      roleId: 1,
      locked: false,
      mfaSwitch: 1,
    );

    await IsarStore.put(StoreKey.currentUser, user);

    await syncService.syncBooksToDB(bookService.getChangedBooks, bookService.loadBooks);

    File outputFile = File('/tmp/hello.out');

    final books = db.bookEntitys.where().findAll();

    if (books.length > 10) {
      for (var book in books.sublist(0, 10)) {
        outputFile.writeAsStringSync(book.toJson(), mode: FileMode.append);
      }
    }
    outputFile.writeAsStringSync("get ${books.length} books", mode: FileMode.append);
  });
}

DefaultApi _createApi() {
  final dio = Dio(BaseOptions(
    baseUrl: r'http://10.0.0.202:8099',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 10),
  ));

  final interceptors = [
    // setDeviceHeadersInterceptor(),
    BearerAuthInterceptor(),
    LogInterceptor(request: true, responseBody: true)
  ];

  final api = Openapi(dio: dio, interceptors: interceptors);

  api.setBearerAuth('bearer', '71eaeb4809c25803e66d5edf9a60060251b40740');
  return api.getDefaultApi();
}
