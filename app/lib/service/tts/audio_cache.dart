import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Persistent per-sentence cache for `LocalFallbackSource` lives under
/// `<app-docs>/audiobooks/<bookId>/`. Server pre-gen MP3s live in the same
/// tree, so deleting the book wipes every audio artefact at once.
Future<void> cleanBookAudioCache(String bookId) async {
  if (bookId.isEmpty) return;
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory('${docs.path}/audiobooks/$bookId');
  if (!await dir.exists()) return;
  try {
    await dir.delete(recursive: true);
  } catch (_) {
    // Best-effort; the OS may have a handle (rare on iOS, possible on
    // Windows). Stale data is acceptable — book row already gone, the
    // user just sees a few MB they can clear in Files later.
  }
}

/// Live-server per-sentence MP3s are scratch space; they live under
/// `<temp>/live-tts/`. On session stop we wipe the current book's bucket;
/// at app start we sweep the whole tree to recover from a crash mid-session.
Future<void> cleanLiveServerCache({String? bookId}) async {
  final tmp = await getTemporaryDirectory();
  final root = Directory('${tmp.path}/live-tts');
  if (!await root.exists()) return;
  try {
    if (bookId == null || bookId.isEmpty) {
      await root.delete(recursive: true);
    } else {
      final bookDir = Directory('${root.path}/$bookId');
      if (await bookDir.exists()) {
        await bookDir.delete(recursive: true);
      }
    }
  } catch (_) {
    // Best-effort — temp dir is OS-managed anyway.
  }
}
