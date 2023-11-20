import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/models/objectbox.g.dart';
import 'package:omnigram/screens/reader/models/epub/_chapter_view_value.dart';
import 'package:omnigram/screens/reader/models/epub_document.dart';
import 'package:omnigram/screens/reader/providers/book_controller.dart';
import 'package:omnigram/screens/reader/providers/select_book.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

void playBackgroundTask(
    {required WidgetRef ref, required EpubDocument document}) async {
  while (true) {
    final selected = ref.watch(selectBookProvider);

    if (selected.book == null || !selected.playing) {
      //exit task
      return;
    }

    final index = selected.index ??
        ChapterIndex(
            chapter: document.chapters[0], chapterIndex: 0, paragraphIndex: 0);

    final content = document.getContent(index);
    print(content);
    await Future.delayed(const Duration(seconds: 1));

    final next = document.nextIndex(index);

    if (next == null) {
      //读到底了
      ref.read(selectBookProvider.notifier).pause();

      return;
    }
    //read current book data and send
    ref.read(selectBookProvider.notifier).updateIndex(next, false);
    //delay
  }
}
