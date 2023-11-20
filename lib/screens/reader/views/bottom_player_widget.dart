import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/screens/reader/providers/book_controller.dart';
import 'package:omnigram/screens/reader/providers/select_book.dart';
import 'package:omnigram/screens/reader/views/chapter_sheet_view.dart';
import 'package:omnigram/screens/reader/views/epub_content_view.dart';

import '../providers/book_play_task.dart';

class BottomPlayerWidget extends HookConsumerWidget {
  const BottomPlayerWidget({required this.controller, super.key});

  final BookController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ReadProgressIndicator(controller: controller),
        Container(
          decoration: BoxDecoration(
            // border: Border(
            //   top: BorderSide(
            //     color: Theme.of(context).dividerColor,
            //     width: 0.5,
            //   ),
            // ),
            color: Theme.of(context).colorScheme.surfaceVariant,
          ),
          padding: const EdgeInsets.only(
            left: 8,
            right: 8,
            bottom: 8,
            top: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                // padding: EdgeInsets.zero,
                onPressed: () => showChapterBottomSheet(context),
                // color: Theme.of(context).colorScheme.primary,
                icon: const Icon(
                  Icons.queue_music,
                  size: 24,
                ),
              ),
              IconButton(
                // padding: EdgeInsets.zero,
                onPressed: () => controller.scrollToPreviousChapter(),
                // color: Theme.of(context).colorScheme.primary,
                icon: const Icon(
                  Icons.skip_previous,
                  size: 24,
                ),
              ),
              PlayButtonWidget(onPressedCallback: () {
                playBackgroundTask(ref: ref, document: controller.document);
              }),
              const SizedBox(
                height: 4,
              ),
              IconButton(
                // padding: EdgeInsets.zero,
                onPressed: () => controller.scrollToNextChapter(),
                icon: const Icon(
                  Icons.skip_next,
                  size: 24,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              IconButton(
                // padding: EdgeInsets.zero,
                onPressed: () {},
                // color: Theme.of(context).colorScheme.primary,
                icon: const Icon(
                  Icons.more_horiz,
                  size: 24,
                ),
              ),
            ],
          ),

          // ),
        ),
      ],
    );
  }

  void showChapterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0)),
      ),
      constraints: BoxConstraints.tight(Size(MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height * .4)),
      builder: (BuildContext context) {
        return ChapterSheetView(controller: controller);
      },
    );
  }
}

class PlayButtonWidget extends HookConsumerWidget {
  const PlayButtonWidget({required this.onPressedCallback, super.key});

  final VoidCallback? onPressedCallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playing =
        ref.watch(selectBookProvider.select((value) => value.playing));
    if (kDebugMode) {
      print('on PlayButtonWidget build and status is $playing');
    }

    // Widgets.bin

    return IconButton(
      // padding: EdgeInsets.zero,
      onPressed: () {
        if (playing) {
          ref.read(selectBookProvider.notifier).pause();
          return;
        }
        ref.read(selectBookProvider.notifier).play();
        if (onPressedCallback != null) {
          onPressedCallback!();
        }
      },
      // color: Theme.of(context).colorScheme.primary,
      icon: playing
          ? const Icon(
              Icons.pause_circle_filled,
              size: 40,
            )
          : const Icon(
              Icons.play_circle_fill,
              size: 40,
            ),
    );
  }
}

class ReadProgressIndicator extends ConsumerWidget {
  const ReadProgressIndicator({required this.controller, super.key});

  final BookController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectBookProvider);

    final progress = controller.document.progress(selected.index);

    if (kDebugMode) {
      print('build ReadProgressIndicator $progress');
    }

    if (selected.playing) {
      final abs = controller.document.absParagraphIndex(selected.index) ?? 0;

      if (abs < controller.document.paragraphs.length - 6) {
        if (kDebugMode) {
          print('build itemScrollController scrollTo $abs');
        }

        controller.itemScrollController?.scrollTo(
          index: abs,
          duration: const Duration(milliseconds: 200),
          alignment: 0.5,
          curve: Curves.decelerate,
        );
      }
    }

    return LinearProgressIndicator(
      value: progress / 100, // Change this value to represent the progress
      valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).colorScheme.tertiaryContainer), // Set to gray
      backgroundColor: Colors.grey[300],
      // color:,
      // style: TextStyle(color: Colors.white, fontSize: 14),
    );
  }
}
