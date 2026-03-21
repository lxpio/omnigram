import 'package:omnigram/dao/book.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/models/tb_group.dart';
import 'package:omnigram/providers/book_list.dart';
import 'package:omnigram/providers/tb_groups.dart';
import 'package:omnigram/service/ai/tools/models/bookshelf_organize_plan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookshelfOrganizeService {
  BookshelfOrganizeService(this._ref);

  final Ref _ref;

  Future<void> applyPlan(BookshelfOrganizePlan plan) async {
    final bookIds = plan.affectedBookIds.toSet().toList();
    if (bookIds.isEmpty && plan.cleanupGroupIds.isEmpty) {
      return;
    }

    final books = await bookDao.selectBooksByIds(bookIds);
    final bookMap = {for (final book in books) book.id: book};
    final groupNotifier = _ref.read(groupDaoProvider.notifier);

    Book requireBook(int id) {
      final book = bookMap[id];
      if (book == null) {
        throw StateError('Book $id not found while applying organize plan.');
      }
      return book;
    }

    for (final group in plan.groups) {
      if (group.createNew) {
        await groupNotifier.insertGroup(group.groupId);
      }

      final existingGroup = await groupNotifier.getGroup(group.groupId);
      final targetName = group.proposedName ?? group.currentName ?? 'New group';

      if (targetName.trim().isNotEmpty) {
        final payload = (existingGroup ??
                TbGroup(
                  id: group.groupId,
                  name: targetName,
                  parentId: 0,
                  isDeleted: 0,
                  createTime: null,
                  updateTime: null,
                ))
            .copyWith(name: targetName.trim());
        await groupNotifier.updateGroup(payload);
      }

      for (final bookInfo in group.books) {
        final current = requireBook(bookInfo.bookId);
        if (current.groupId == group.groupId) {
          continue;
        }
        final updated = current.copyWith(groupId: group.groupId);
        await bookDao.updateBook(updated);
        bookMap[current.id] = updated;
      }
    }

    for (final bookInfo in plan.ungroupedBooks) {
      final current = requireBook(bookInfo.bookId);
      if (current.groupId == 0) {
        continue;
      }
      final updated = current.copyWith(groupId: 0);
      await bookDao.updateBook(updated);
      bookMap[current.id] = updated;
    }

    for (final groupId in plan.cleanupGroupIds.where((id) => id > 0)) {
      await groupNotifier.hardDeleteGroup(groupId);
    }

    await _ref.read(bookListProvider.notifier).refresh();
    await groupNotifier.refresh();
  }
}

final bookshelfOrganizeServiceProvider =
    Provider<BookshelfOrganizeService>((ref) => BookshelfOrganizeService(ref));
