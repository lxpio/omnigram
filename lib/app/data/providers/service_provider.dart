import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:omnigram/app/providers/service_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

abstract class ServiceProviders {
  factory ServiceProviders(Database database) {
    var serviceProvidersDao = ServiceProvidersDao(database);
    return serviceProvidersDao;
  }

  Future<List<Map<String, Object?>>> getAll({required int groupId});

  Future<Map<String, dynamic>?> get({required String id});

  Future<void> create(ServiceProvider provider);
}

class ServiceProvidersDao implements ServiceProviders {
  static const table = 'service_providers';

  final Database db;
  ServiceProvidersDao(this.db);

  static Future<void> onCreate(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${ServiceProvidersDao.table} (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT,
        help TEXT,
        avatar TEXT,
        desc TEXT,
        group_id INTEGER,
        hello TEXT,
        block INTEGER DEFAULT 0
      );
    ''');

    // format data
    final string = await rootBundle.loadString(
      'assets/files/service_providers.json',
    );
    final List list = json.decode(utf8.decode(base64.decode(string)));
    for (final map in list) {
      // 插入数据
      try {
        await db.insert(
          table,
          map,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      } catch (e) {
        // 捕获异常，并在控制台输出异常信息
        if (kDebugMode) {
          print('Error inserting data: $e');
        }
      }
    }
  }

  static Future<void> onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    //do nothing
  }

  @override
  Future<List<Map<String, Object?>>> getAll({required int groupId}) async {
    return (await db.query(table, where: 'group_id = ?', whereArgs: [groupId]));
  }

  @override
  Future<Map<String, dynamic>?> get({required String id}) async {
    return (await db.query(table, where: 'id = ?', whereArgs: [id]))
        .firstOrNull;
  }

  @override
  Future<void> create(ServiceProvider provider) async {
    final json = provider.toJson();
    json.remove('tokens');
    await db.insert(
      table,
      json,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
