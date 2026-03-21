import 'dart:async';

import 'package:sqflite/sqflite.dart';

import 'database.dart';

typedef RowMapper<T> = T Function(Map<String, dynamic> row);

abstract class BaseDao {
  Future<Database> get _database async => DBHelper().database;

  Future<Database> get database async => _database;

  Future<List<T>> queryList<T>(
    String table, {
    required RowMapper<T> mapper,
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final database = await _database;
    final rows = await database.query(
      table,
      columns: columns,
      distinct: distinct ?? false,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );

    return rows.map(mapper).toList(growable: false);
  }

  Future<T?> querySingle<T>(
    String table, {
    required RowMapper<T> mapper,
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? offset,
  }) async {
    final results = await queryList(
      table,
      mapper: mapper,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: 1,
      offset: offset,
    );

    if (results.isEmpty) {
      return null;
    }
    return results.first;
  }

  Future<List<T>> rawQueryList<T>(
    String sql, {
    List<Object?>? arguments,
    required RowMapper<T> mapper,
  }) async {
    final database = await _database;
    final rows = await database.rawQuery(sql, arguments);
    return rows.map(mapper).toList(growable: false);
  }

  Future<T?> rawQuerySingle<T>(
    String sql, {
    List<Object?>? arguments,
    required RowMapper<T> mapper,
  }) async {
    final results = await rawQueryList(
      sql,
      arguments: arguments,
      mapper: mapper,
    );
    return results.isEmpty ? null : results.first;
  }

  Future<int> insert(String table, Map<String, Object?> values,
      {ConflictAlgorithm? conflictAlgorithm}) async {
    final database = await _database;
    return database.insert(
      table,
      values,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    final database = await _database;
    return database.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final database = await _database;
    return database.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<R> transaction<R>(
    Future<R> Function(Transaction txn) action,
  ) async {
    final database = await _database;
    return database.transaction(action);
  }
}
