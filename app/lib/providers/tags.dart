import 'package:omnigram/dao/tag.dart';
import 'package:omnigram/models/tag.dart';
import 'package:omnigram/utils/color/rgb.dart';
import 'package:flutter/material.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tags.g.dart';

/// Special ID for filtering books without any tags.
const int kNoTagFilterId = -1;

int _compareTagName(Tag a, Tag b) {
  String toPinyin(String value) {
    try {
      return PinyinHelper.getPinyin(value, format: PinyinFormat.WITHOUT_TONE);
    } catch (_) {
      return value;
    }
  }

  final pa = toPinyin(a.name);
  final pb = toPinyin(b.name);
  return pa.compareTo(pb);
}

List<Tag> _sortedTags(List<Tag> tags) {
  final list = [...tags];
  list.sort(_compareTagName);
  return list;
}

@riverpod
class TagList extends _$TagList {
  @override
  Future<List<Tag>> build() async {
    final tags = await tagDao.fetchAllTags();
    return _sortedTags(tags);
  }

  Future<int> createTag(String name, {Color? color}) async {
    final rgb = color == null ? null : rgbFromColor(color);
    final id = await tagDao.insertTag(name, color: rgb);
    await _refresh();
    return id;
  }

  Future<void> updateTag(int id, {String? newName, Color? color}) async {
    final rgb = color == null ? null : rgbFromColor(color);
    await tagDao.updateTag(id, newName: newName, color: rgb);
    await _refresh();
  }

  Future<void> deleteTag(int id) async {
    await tagDao.deleteTag(id);
    await _refresh();
  }

  Future<void> _refresh() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await build());
  }
}

class BookTagState {
  final List<Tag> tags;
  final Set<int> attachedIds;

  const BookTagState({
    required this.tags,
    required this.attachedIds,
  });

  bool isAttached(int tagId) => attachedIds.contains(tagId);

  Tag resolveWithColor(Tag tag, Color Function(String) fallback) {
    if (tag.color != null) return tag;
    return tag.copyWith(color: fallback(tag.name));
  }
}

@riverpod
class BookTagEditor extends _$BookTagEditor {
  @override
  Future<BookTagState> build(int bookId) async {
    final tags = _sortedTags(await tagDao.fetchAllTags());
    final attachedIds = (await bookTagDao.fetchTagIdsForBook(bookId)).toSet();
    return BookTagState(tags: tags, attachedIds: attachedIds);
  }

  Future<void> attachExisting(Tag tag) async {
    await bookTagDao.addRelation(bookId: bookId, tagId: tag.id);
    ref.invalidate(tagListProvider);
    await _refresh();
  }

  Future<void> detach(Tag tag) async {
    await bookTagDao.removeRelation(bookId: bookId, tagId: tag.id);
    await _refresh();
  }

  Future<void> createAndAttach(String name, {required Color color}) async {
    final tagId = await tagDao.insertTag(name, color: rgbFromColor(color));
    await bookTagDao.addRelation(bookId: bookId, tagId: tagId);
    ref.invalidate(tagListProvider);
    await _refresh();
  }

  Future<void> _refresh() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await build(bookId));
  }
}

@riverpod
class TagSelection extends _$TagSelection {
  @override
  Set<int> build() => <int>{};

  void toggle(int tagId) {
    final next = {...state};
    if (next.contains(tagId)) {
      next.remove(tagId);
    } else {
      // Mutual exclusion: no-tag filter and regular tag filters are exclusive
      if (tagId == kNoTagFilterId) {
        // Selecting "no tag" clears all other tags
        next.clear();
      } else {
        // Selecting a regular tag clears "no tag"
        next.remove(kNoTagFilterId);
      }
      next.add(tagId);
    }
    state = next;
  }

  void setSelection(Set<int> tagIds) {
    state = {...tagIds};
  }

  void clear() {
    state = <int>{};
  }
}
