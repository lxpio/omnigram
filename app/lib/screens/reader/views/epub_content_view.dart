import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/screens/reader/models/epub_document.dart';
import 'package:omnigram/screens/reader/providers/book_controller.dart';
import 'package:omnigram/screens/reader/providers/tts_service.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../models/epub/epub.dart';
import '../providers/select_book.dart';
import 'bottom_player_widget.dart';
import 'epub_para_view.dart';

class EpubContentView extends HookConsumerWidget {
  const EpubContentView({
    required this.document,
    this.onClose,
    this.runplayTask = false,
    super.key,
  }) : super();

  final EpubDocument document;
  final VoidCallback? onClose;
  final bool runplayTask;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kDebugMode) {
      print('build EpubContentView bookFile');
    }

    final controller = useBookController(ref, document);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (runplayTask) {
        if (kDebugMode) {
          print('in EpubContentView call play');
        }
        await ref.read(ttsServiceProvider.notifier).play(controller.document);
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            // color: Colors.white,
            onPressed: () async {
              if (onClose != null) {
                onClose!();
              } else {
                await ref.read(selectBookProvider.notifier).saveProcess(null);

                if (!context.mounted) {
                  return;
                }
                context.pop();
              }
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
              initialScrollIndex: document.absParagraphIndex(ref.read(selectBookProvider).index) ?? 0,
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

  BookController useBookController(WidgetRef ref, EpubDocument document) {
    final controller = useState(BookController(document: document)).value;

    updater(ChapterIndex? current) {
      ref.read(ttsServiceProvider.notifier).updateIndex(current);
    }

    useEffect(() {
      if (kDebugMode) {
        print('useBookController useEffect');
      }

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
