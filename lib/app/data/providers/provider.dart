import 'dart:async';

import 'package:get/get.dart';
import 'package:omnigram/app/core/app_manager.dart';
import 'package:omnigram/app/data/providers/conversation_provider.dart';
import 'package:omnigram/app/data/providers/message_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:omnigram/app/data/providers/service_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
// class Provider extends GetConnect {
//   @override
//   void onInit() {
//     // httpClient.defaultDecoder = (map) {
//     //   if (map is Map<String, dynamic>) return Provider.fromJson(map);
//     //   if (map is List)
//     //     return map.map((item) => Provider.fromJson(item)).toList();
//     // };
//     httpClient.baseUrl = 'YOUR-API-URL';
//   }

//   Future<Provider?> getProvider(int id) async {
//     final response = await get('provider/$id');
//     return response.body;
//   }

//   Future<Response<Provider>> postProvider(Provider provider) async =>
//       await post('provider', provider);
//   Future<Response> deleteProvider(int id) async => await delete('provider/$id');
// }

class AppProvider {
  static const defaultLimit = 16;

  static final AppProvider instance = AppProvider._internal();
  AppProvider._internal();

  // 如果是本地模式则适用sqlite 进行数据存储
  late final Database database;

  late final MessageProvider messages = MessageProvider();

  late final ConversationProvider conversations = ConversationProvider();

  late final ServiceProviders serviceProviders = ServiceProviders(database);
  // late final ServiceVendorsDao serviceVendorsDao = ServiceVendorsDao(database);
  // late final ServiceTokensDao serviceTokensDao = ServiceTokensDao(database);
  // late final PromptDao promptDao = PromptDao(database);
  // late final RequestParametersDao requestParametersDao =
  //     RequestParametersDao(database);

  static Future<void> initialize() async {
    // 这里判断如果是本地模式则出生后sqlite数据库，否则出生后apiclient
    if (AppManager.to.appMode == null) {
      var databasesPath = await getDatabasesPath();
      var path = join(databasesPath, 'dbName');

      instance.database = await openDatabase(
        path,
        onCreate: instance._onCreate,
        onUpgrade: instance._onUpgrade,
        version: 4,
      );
    }
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    // await MessagesDao.onCreate(db);
    // await PromptDao.onCreate(db);
    // await ServiceTokensDao.onCreate(db);
    // await ServiceVendorsDao.onCreate(db);
    await ServiceProvidersDao.onCreate(db);
    // await ConversationsDao.onCreate(db);
    // await RequestParametersDao.onCreate(db);
  }

  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // await MessagesDao.onUpgrade(db, oldVersion, newVersion);

    // if (oldVersion < 3) {
    //   await ServiceVendorsDao.onCreate(db);
    //   await PromptDao.onCreate(db);
    // }
    // if (oldVersion < 4) {
    //   await RequestParametersDao.onCreate(db);
    // } else {
    //   await RequestParametersDao.onUpgrade(db, oldVersion, newVersion);
    // }
    // await ServiceTokensDao.onUpgrade(db, oldVersion, newVersion);
    // await ServiceVendorsDao.onUpgrade(db, oldVersion, newVersion);
    // await PromptDao.onUpgrade(db, oldVersion, newVersion);
    await ServiceProvidersDao.onUpgrade(db, oldVersion, newVersion);

    // await ConversationsDao.onUpgrade(db, oldVersion, newVersion);
  }
}
