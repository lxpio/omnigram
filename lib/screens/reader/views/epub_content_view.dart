import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/screens/reader/models/epub_document.dart';
import 'package:omnigram/screens/reader/providers/book_controller.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../models/epub/epub.dart';
import '../providers/books.dart';
import '../providers/select_book.dart';
import 'bottom_player_widget.dart';
import 'chapter_title_view.dart';
import 'epub_para_view.dart';

class EpubContentView extends HookConsumerWidget {
  const EpubContentView({
    required this.document,
    super.key,
  }) : super();

  final EpubDocument document;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kDebugMode) {
      print('build EpubContentView bookFile');
    }

    final controller = useBookController(ref, document);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            // color: Colors.white,
            onPressed: () async {
              await saveProcess(ref);
              if (!context.mounted) {
                return;
              }
              context.pop();
            }),
        // title: ChapterTitleView(),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.bug_report),
              // color: Colors.white,
              onPressed: () {
                final index = ref.read(selectBookProvider).index;

                final cfi = document.cfiGenerate(index);

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
      body: Column(
        children: [
          Expanded(
            child: ScrollablePositionedList.builder(
              shrinkWrap: false,
              // reverse: true,
              initialScrollIndex: document
                      .absParagraphIndex(ref.read(selectBookProvider).index) ??
                  0,
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
          ),
          BottomPlayerWidget(
            controller: controller,
          ),
        ],
      ),
    );
  }

  Future<void> saveProcess(WidgetRef ref) async {
    //   final index = document.cfiParse(chapterPos);
    final selected = ref.watch(selectBookProvider);

    if (selected.book == null) {
      return;
    }

    final cfi = document.cfiGenerate(selected.index);
    final progress = document.progress(selected.index);

    print('saveProcess todo handle error  ${selected.book!.id}');
    final api = ref.read(bookAPIProvider);
    await api.updateProcess(selected.book!.id, progress, cfi);
  }

  BookController useBookController(WidgetRef ref, EpubDocument document) {
    final controller = useState(BookController(document: document)).value;

    updater(ChapterIndex? current) {
      ref.read(selectBookProvider.notifier).updateIndex(current, true);
    }

    useEffect(() {
      controller.initialize(updater);

      // final timer = Timer.periodic(const Duration(seconds: 10), (t) {
      //   final pos = controller.cfiGenerate();
      //   final progress = controller.progress;

      //   if (pos != null && pos.isNotEmpty) {
      //     if (kDebugMode) {
      //       print(
      //           'update epub reader,current cfi: $pos, and progress: $progress');
      //     }

      //     ref.read(selectBookProvider.notifier).updateProcess(progress, pos);
      //   }
      // });

      return () {
        if (kDebugMode) {
          print('exit epub reader');
        }

        // timer.cancel();
        controller.dispose();
      };
    }, []);

    return controller;
  }
}

class ReadProgressIndicator extends ConsumerWidget {
  const ReadProgressIndicator({required this.controller, super.key});

  final BookController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectBookProvider);

    if (selected.playing) {
      final abs = controller.document.absParagraphIndex(selected.index) ?? 0;

      if (abs < controller.document.paragraphs.length - 6) {
        controller.itemScrollController?.scrollTo(
          index: abs,
          duration: const Duration(milliseconds: 200),
          alignment: 0.5,
          curve: Curves.decelerate,
        );
      }
    }

    return LinearProgressIndicator(
      value: controller.document.progress(
          selected.index), // Change this value to represent the progress
      valueColor:
          const AlwaysStoppedAnimation<Color>(Colors.yellow), // Set to gray
      backgroundColor: Colors.grey[300],
      // color:,
      // style: TextStyle(color: Colors.white, fontSize: 14),
    );
  }
}
