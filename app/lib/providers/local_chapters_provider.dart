import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/service/local_book/local_epub_chapters.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_chapters_provider.g.dart';

/// Cached, parsed chapter list for a local EPUB. Keyed by absolute file path
/// so that the same book opened from different angles (reader, audiobook,
/// book-detail) shares one parse.
///
/// Background: Now-Playing must be able to drive sentence-by-sentence playback
/// without the foliate-js webview being open. The reader uses foliate-js + CFI
/// for in-page highlighting; Now-Playing only needs ordered chapters with
/// plain text, so we do a small Dart-side parse instead of bouncing through
/// the webview.
@Riverpod(keepAlive: true)
Future<List<EpubChapter>> localChapters(Ref ref, String filePath) async {
  return readEpubChapters(filePath);
}
