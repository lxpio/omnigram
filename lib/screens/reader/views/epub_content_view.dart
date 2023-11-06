import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/screens/reader/models/epub_document.dart';
import 'package:omnigram/screens/reader/providers/book_controller.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../providers/select_book.dart';
import 'chapter_title_view.dart';

class EpubContentView extends HookConsumerWidget {
  const EpubContentView({
    super.key,
    required this.document,
  }) : super();

  final EpubDocument document;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kDebugMode) {
      print('build EpubContentView bookFile');
    }

    final controller = useState(BookController(document: document)).value;
    useListenable(controller.index);
    useEffect(() {
      controller.initialize();

      // final controller = epub.value;
      final timer = Timer.periodic(const Duration(seconds: 10), (t) {
        final pos = controller.cfiGenerate();
        final progress = controller.progress;

        if (pos != null && pos.isNotEmpty) {
          if (kDebugMode) {
            print(
                'update epub reader,current cfi: $pos, and progress: $progress');
          }

          ref.read(selectBookProvider.notifier).updateProcess(progress, pos);
        }
      });

      return () {
        if (kDebugMode) {
          print('exit epub reader');
        }

        timer.cancel();
        controller.dispose();
      };
    }, []);

    // return future.

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            // color: Colors.white,
            onPressed: () async {
              final cfi = controller.cfiGenerate();
              await ref
                  .read(selectBookProvider.notifier)
                  .saveProcess(controller.progress, cfi);
              if (!context.mounted) {
                return;
              }
              context.pop();
            }),
        title: ChapterTitleView(
          title: controller.index.value?.chapter?.Title,
        ),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.bug_report),
              // color: Colors.white,
              onPressed: () {
                final cfi = controller.cfiGenerate();

                if (cfi != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(cfi),
                    ),
                  );
                }
              }),
        ],
      ),
      // drawer: Drawer(
      //   child: EpubViewTableOfContents(controller: controller),
      // ),
      body: ScrollablePositionedList.builder(
        shrinkWrap: false,
        initialScrollIndex: controller.currentParagraphIndex ?? 0,
        itemCount: controller.paraLength,
        itemScrollController: controller.itemScrollController,
        itemPositionsListener: controller.itemPositionListener,
        itemBuilder: (BuildContext context, int index) {
          return ChapterParaView(
            controller: controller,
            index: index,
          );
        },
      ),
    );
  }
}
