import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/screens/reader/providers/tts_service.dart';
import 'package:omnigram/utils/constants.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../providers/select_book.dart';

class Stackbar extends HookConsumerWidget {
  const Stackbar({
    super.key,
    required this.child,
  });
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ttsState = ref.watch(ttsServiceProvider);

    return Column(
      children: [
        Expanded(child: child),
        if (ttsState.showbar) const StackbarWidget(),
      ],
    );
  }
}

class StackbarWidget extends ConsumerWidget {
  const StackbarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(selectBookProvider.select((value) => value.book))!;

    return ColoredBox(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: SizedBox(
        height: kToolbarHeight,
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          onTap: () {
            // ReadEpubScreen()
            context.pushNamed(kReaderDetailPage);
            // final overlay = Overlay.of(context);
            // OverlayEntry? entry;
            // entry = OverlayEntry(
            //   builder: (context) => Stack(
            //     children: [
            //       Positioned(
            //         child: ReadEpubScreen(
            //           onClose: () {
            //             entry?.remove();
            //           },
            //         ),
            //       ),
            //     ],
            //   ),
            // );
            // overlay.insert(entry);
          },
          child: Stack(
            children: [
              const _ProgressbarWidget(),
              Positioned(
                left: 4,
                bottom: 4,
                top: 4,
                right: 4,
                child: Row(
                  children: [
                    _AlbumArt(image: book.coverUrl),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        Text(
                          book.author ?? '',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                    const Spacer(),
                    const _ButtonBarwidget(),
                    IconButton(
                      // padding: EdgeInsets.zero,
                      onPressed: () {
                        ref.read(ttsServiceProvider.notifier).close();
                      },
                      // color: Theme.of(context).colorScheme.primary,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlbumArt extends ConsumerWidget {
  const _AlbumArt({
    required this.image,
  });

  final String? image;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        width: 70,
        height: 70,
        child: image != null
            ? FadeInImage(
                placeholder: MemoryImage(kTransparentImage),
                image: const AssetImage('todo image file'),
                // image: NetworkImage(
                //   appConfig.baseUrl + image!,
                //   headers: {"Authorization": "Bearer ${appConfig.token}"},
                // ),
                fit: BoxFit.fill,
                imageErrorBuilder: (context, error, stackTrace) {
                  if (kDebugMode) {
                    print('get image failed: $error');
                  }
                  return Container(
                    color: Colors.pink[100],
                  );
                },
              )
            : Container(
                color: Colors.pink[100],
              ),
      ),
    );
  }
}

class _ProgressbarWidget extends ConsumerWidget {
  const _ProgressbarWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kDebugMode) {
      print('stack playbar  LinearProgressIndicator build');
    }

    final progress = ref.watch(selectBookProvider.select((value) => value.progress));

    return Positioned(
      left: 0,
      right: 4,
      bottom: 0,
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        color: Theme.of(context).colorScheme.onTertiaryContainer,
      ),
    );
  }
}

class _ButtonBarwidget extends ConsumerWidget {
  const _ButtonBarwidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kDebugMode) {
      print('stack playbar build');
    }

    final tts = ref.watch(ttsServiceProvider);

    return IconButton(
      // padding: EdgeInsets.zero,
      onPressed: () async {
        if (tts.playing) {
          ref.read(ttsServiceProvider.notifier).pause();
          return;
        }
        final snapshot = ref.watch(epubDocumentProvider);

        snapshot.whenData((document) async {
          if (document != null) {
            ref.read(ttsServiceProvider.notifier).play(document);
          }
        });
      },
      // color: Theme.of(context).colorScheme.primary,
      icon: Icon(
        tts.playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
      ),
    );
  }
}
