import 'dart:async';

/// Common surface for the three playback modes; the player provider talks to
/// one of these without caring which mode is active.
///
/// The session asks the source for one chapter's worth of audio. Sources are
/// constructed already knowing which chapter they will play (sentence list
/// for sentence-driven sources, chapter mp3 for pregen) and dropped at the
/// next chapter boundary — the session creates a fresh one each `start()`.
///
/// All three modes converge on the same observable surface:
///
/// - `sentenceIndexStream` — current sentence index (drives highlight). Pregen
///   derives it from playback position + alignment; sentence-queue sources
///   emit on each transition.
/// - `positionStream` / `duration` — pregen uses chapter cumulative time;
///   sentence-queue uses current sentence's elapsed/total. UI is sentence-
///   centric so the difference is acceptable.
/// - `completionStream` — fires once when the last unit of the chapter ends.
abstract class TtsAudioSource {
  /// Begin loading audio. Returns when the first audio chunk is buffered and
  /// `play()` will produce sound immediately.
  Future<void> prepare();

  Future<void> play();
  Future<void> pause();

  /// Seek within the current sentence (for fine-grained scrubbing in pregen).
  /// Sentence-queue sources may treat this as a no-op when the position is
  /// outside the current sentence.
  Future<void> seek(Duration position);

  /// Jump to a given sentence (re-prepare if needed).
  Future<void> seekToSentence(int sentenceIndex);

  /// Adjust playback rate. 1.0 = normal. Sources persist this across sentence
  /// transitions so the queue keeps the user-chosen speed after each file
  /// swap.
  Future<void> setSpeed(double speed);

  Future<void> dispose();

  /// Index of the currently playing sentence. -1 when nothing is playing yet.
  Stream<int> get sentenceIndexStream;

  /// Position within the current playback unit (sentence or chapter mp3).
  Stream<Duration> get positionStream;

  /// Total duration of the current playback unit. Drives the scrubber.
  /// Sentence-queue sources emit per-sentence; pregen emits chapter total.
  Stream<Duration> get durationStream;

  /// Fires once when the chapter ends.
  Stream<void> get completionStream;
}
