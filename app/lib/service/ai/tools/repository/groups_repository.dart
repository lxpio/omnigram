import 'package:omnigram/dao/database.dart';
import 'package:omnigram/models/tb_group.dart';

class GroupsRepository {
  const GroupsRepository();

  Future<Map<int, TbGroup>> fetchByIds(Iterable<int> ids) async {
    final idList = ids.where((id) => id > 0).toSet().toList();
    if (idList.isEmpty) {
      return const <int, TbGroup>{};
    }

    final db = await DBHelper().database;
    final placeholders = List.filled(idList.length, '?').join(',');
    final rows = await db.rawQuery(
      'SELECT * FROM tb_groups WHERE id IN ($placeholders)',
      idList,
    );

    final map = <int, TbGroup>{};
    for (final row in rows) {
      final group = TbGroup(
        id: row['id'] as int,
        name: row['name'] as String,
        parentId: row['parent_id'] as int?,
        isDeleted: row['is_deleted'] as int? ?? 0,
        createTime: row['create_time'] as String?,
        updateTime: row['update_time'] as String?,
      );
      map[group.id] = group;
    }
    return map;
  }
}
