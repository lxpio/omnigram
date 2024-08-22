import 'dart:async';


import 'package:isar/isar.dart';
import 'package:omnigram/entities/isar_store.entity.dart';

const int targetVersion = 6;

Future<void> migrateDatabaseIfNeeded(Isar db) async {
  final int version = IsarStore.get(StoreKey.version, 1);
  if (version < targetVersion) {
    _migrateTo(db, targetVersion);
  }
}

Future<void> _migrateTo(Isar db, int version) async {
  // await clearLocalDB(db);
  await IsarStore.put(StoreKey.version, version);
}
