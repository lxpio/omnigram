import 'dart:io';

import 'package:omnigram/main.dart';
import 'package:omnigram/service/book.dart';
import 'package:omnigram/utils/log/common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_handler/share_handler.dart';

void receiveShareIntent(WidgetRef ref) {
  final handler = ShareHandlerPlatform.instance;

  // receive sharing intent
  Future<void> handleShare(SharedMedia? media) async {
    AnxLog.info('share: Receive share intent called, ${media?.content}');
    if (media == null ||
        media.attachments == null ||
        media.attachments!.isEmpty) {
      AnxLog.info('share: Receive share intent: no media or empty');
      return;
    }
    AnxLog.info(
        'share: Receive share intent: ${media.attachments!.map((e) => e?.path).join(', ')}');

    List<File> files = [];
    for (var item in media.attachments!) {
      if (item != null && item.path.isNotEmpty) {
        final sourceFile = File(item.path);
        files.add(sourceFile);
      }
    }
    importBookList(files, navigatorKey.currentContext!, ref);
    handler.resetInitialSharedMedia();
  }

  handler.sharedMediaStream.listen((SharedMedia media) {
    handleShare(media);
  }, onError: (err) {
    AnxLog.severe('share: Receive share intent');
  });

  handler.getInitialSharedMedia().then((media) {
    handleShare(media);
  }, onError: (err) {
    AnxLog.severe('share: Receive share intent');
  });
}
