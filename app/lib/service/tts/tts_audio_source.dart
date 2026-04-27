import 'dart:async';

/// Common surface for the three playback modes; the player provider talks
/// to one of these without caring which mode is active.
abstract class TtsAudioSource {
  /// Begin streaming/loading audio for the given chapter index.
  /// Returns when first audio sample is buffered (i.e., playback can start).
  Future<void> prepare({required int chapterIndex});

  /// Start or resume playback.
  Future<void> play();

  /// Pause without releasing resources.
  Future<void> pause();

  /// Seek within the current chapter.
  Future<void> seek(Duration position);

  /// Stop and release any buffered audio.
  Future<void> dispose();

  /// Position stream — drives sentence highlight.
  Stream<Duration> get positionStream;

  /// Fires once when current chapter finishes naturally.
  Stream<void> get completionStream;
}
