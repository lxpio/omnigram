import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:omnigram/models/server/server_tts.dart';
import 'package:omnigram/page/book_player/epub_player.dart';
import 'package:omnigram/service/audiobook/audiobook_player.dart';
import 'package:omnigram/service/audiobook/sync_matcher.dart';
import 'package:omnigram/service/tts/models/tts_sentence.dart';

/// Drives Audible-grade sentence highlight by bridging three independent
/// systems:
///
///   audio position  —(binary search)→  SentenceAlignment.index
///            index  —(text match)→  foliate-js CFI
///              CFI  —(highlight)→  rendered EPUB page
///
/// The controller keeps its own cache of foliate sentences (per chapter) so
/// we don't thrash the webview bridge on every position tick. Highlight
/// updates are throttled and skipped when the audio index hasn't crossed a
/// sentence boundary — the visible cost is one rare webview JS call per
/// sentence change, not per frame.
///
/// Design rules:
///  1. NEVER block audio playback on a missing CFI — fall through to
///     "no highlight this tick" and keep playing.
///  2. Always tolerate foliate ↔ server sentence count mismatch. Matching
///     is best-effort text-similarity, not strict index equality.
///  3. Cache-friendly: server's SentenceAlignment.index → foliate CFI is
///     an N-to-N map; resolve once per sentence, reuse forever.
class AudiobookSyncController {
  AudiobookSyncController({
    required this.player,
    required this.epubState,
  });

  final AudiobookPlayer player;
  final EpubPlayerState epubState;

  /// Currently loaded chapter alignment. Callers swap this when navigating
  /// chapters (it's cheap — just replaces the lookup table).
  ChapterAlignment? _alignment;

  /// CFI cache: sentenceIndex → resolved CFI. null indicates "tried and
  /// failed" — we don't retry resolution for the same index in the same
  /// loaded chapter.
  final Map<int, String?> _cfiCache = {};

  /// Cached foliate-js sentence list for the current chapter. Populated on
  /// first _resolveCfi call, reused thereafter. Reset when alignment swaps.
  List<TtsSentence>? _foliateSentences;

  /// Last sentence index that actually triggered a highlight call — debounces
  /// redundant `ttsHighlightByCfi` invocations.
  int _lastHighlightIndex = -1;

  StreamSubscription<Duration>? _positionSub;

  /// Called when a sentence transition happens, before the highlight call.
  /// Use for auto-page-flip, progress saving, etc.
  void Function(int sentenceIndex, SentenceAlignment sentence)? onSentenceChange;

  /// Attach to player position stream. Idempotent.
  void attach() {
    _positionSub?.cancel();
    _positionSub = player.positionStream.listen(
      _onPosition,
      onError: (Object e, StackTrace s) {
        debugPrint('[SyncController] position error: $e');
      },
    );
  }

  /// Set / swap the alignment for the currently playing chapter. Clears the
  /// CFI cache since indices no longer map to the old chapter's sentences.
  void setAlignment(ChapterAlignment alignment) {
    _alignment = alignment;
    _cfiCache.clear();
    _foliateSentences = null;
    _lastHighlightIndex = -1;
  }

  /// Immediately resolve and highlight the sentence covering [positionMs].
  /// Bypasses the debounce so callers can force a refresh after seek.
  Future<void> highlightAt(int positionMs) async {
    _lastHighlightIndex = -1;
    await _onPositionMs(positionMs);
  }

  /// Find the server-side sentence index for a given foliate CFI. Used for
  /// tap-to-seek (user taps a sentence → map CFI → sentence → start_ms).
  /// Returns -1 if no match.
  Future<int> findSentenceIndexByCfi(String cfi) async {
    final align = _alignment;
    if (align == null) return -1;
    final foliate = await _ensureFoliateSentences();
    if (foliate.isEmpty) return -1;

    // Find foliate sentence with matching cfi.
    final foliateIdx = foliate.indexWhere((s) => s.cfi == cfi);
    if (foliateIdx < 0) return -1;

    // Index-equal fallback: if counts match, foliateIdx == server index.
    if (foliate.length == align.sentences.length) return foliateIdx;

    // Otherwise match by text similarity.
    final foliateText = normaliseForMatch(foliate[foliateIdx].text);
    var bestIdx = -1;
    double bestScore = 0;
    for (var i = 0; i < align.sentences.length; i++) {
      final score =
          bigramSimilarity(foliateText, normaliseForMatch(align.sentences[i].text));
      if (score > bestScore) {
        bestScore = score;
        bestIdx = i;
      }
    }
    return bestScore >= 0.6 ? bestIdx : -1;
  }

  Future<void> dispose() async {
    await _positionSub?.cancel();
    _positionSub = null;
  }

  // ── Internals ─────────────────────────────────────────────────────

  Future<void> _onPosition(Duration pos) => _onPositionMs(pos.inMilliseconds);

  Future<void> _onPositionMs(int ms) async {
    final align = _alignment;
    if (align == null || align.sentences.isEmpty) return;

    final idx = findSentenceForTime(align.sentences, ms);
    if (idx < 0 || idx == _lastHighlightIndex) return;

    _lastHighlightIndex = idx;
    final sentence = align.sentences[idx];
    onSentenceChange?.call(idx, sentence);

    final cfi = await _resolveCfi(idx);
    if (cfi == null) return;

    try {
      await epubState.ttsHighlightByCfi(cfi);
    } catch (e) {
      // Never let highlight errors bubble up to break playback.
      debugPrint('[SyncController] highlight failed: $e');
    }
  }

  Future<String?> _resolveCfi(int serverIdx) async {
    if (_cfiCache.containsKey(serverIdx)) return _cfiCache[serverIdx];
    final align = _alignment;
    if (align == null) return null;

    final foliate = await _ensureFoliateSentences();
    if (foliate.isEmpty) {
      _cfiCache[serverIdx] = null;
      return null;
    }

    // Fast path: counts match → direct index mapping.
    if (foliate.length == align.sentences.length) {
      final cfi = serverIdx < foliate.length ? foliate[serverIdx].cfi : null;
      _cfiCache[serverIdx] = cfi;
      return cfi;
    }

    // Text-similarity fallback — acceptable cost because it's cached.
    final target = normaliseForMatch(align.sentences[serverIdx].text);
    String? best;
    double bestScore = 0;
    for (final f in foliate) {
      if (f.cfi == null || f.cfi!.isEmpty) continue;
      final score = bigramSimilarity(target, normaliseForMatch(f.text));
      if (score > bestScore) {
        bestScore = score;
        best = f.cfi;
      }
    }
    final result = bestScore >= 0.6 ? best : null;
    _cfiCache[serverIdx] = result;
    return result;
  }

  Future<List<TtsSentence>> _ensureFoliateSentences() async {
    final cached = _foliateSentences;
    if (cached != null) return cached;
    try {
      // Pull a large window; foliate returns everything it has for current
      // section (chapter). 9999 is well above any reasonable chapter count.
      final sentences = await epubState.ttsCollectDetails(
        count: 9999,
        includeCurrent: true,
        offset: 0,
      );
      _foliateSentences = sentences;
      return sentences;
    } catch (e) {
      debugPrint('[SyncController] ttsCollectDetails failed: $e');
      _foliateSentences = const [];
      return const [];
    }
  }

}
