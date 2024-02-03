import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/screens/reader/providers/select_book.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../providers/book_controller.dart';

class ChapterSheetView extends HookConsumerWidget {
  const ChapterSheetView({required this.controller, super.key});
  final BookController controller;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current =
        ref.watch(selectBookProvider.select((value) => value.index));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ScrollablePositionedList.builder(
        shrinkWrap: false,
        // reverse: true,
        initialScrollIndex: current?.chapterIndex ?? 0,
        itemCount: controller.document.chapters.length,
        // itemScrollController: controller.itemScrollController,
        // itemPositionsListener: controller.itemPositionListener,
        itemBuilder: (BuildContext context, int index) {
          final chapter = controller.document.chapters[index];
          return ListTile(
            title: Text(chapter.Title!.trim()),
            onTap: () {
              if (kDebugMode) {
                print('Chapter: ${chapter.Title}');
              }
              context.pop();
              controller.scrollToChapter(index);
            },
          );
        },
      ),
    );
  }
}
