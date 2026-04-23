import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper over `audioplayers.AudioPlayer` for sentence-sync listening.
///
/// Responsibilities:
/// - Own exactly one `AudioPlayer` instance, load one chapter MP3 at a time
/// - Expose `positionStream` (ms-resolution) and `stateStream` for the
///   `AudiobookSyncController` to drive highlight updates
/// - Provide idempotent play/pause/seek/setSpeed
/// - Keep track of currently-loaded chapter so callers don't reload
///   unnecessarily when resuming
///
/// Does NOT own sync / highlight logic — that lives in SyncController. This
/// class stays dumb so it's easy to unit test and swap backends later.
class AudiobookPlayer {
  AudiobookPlayer() : _player = AudioPlayer();

  final AudioPlayer _player;
  String? _loadedPath;

  /// Stream of current playback position, ms-accurate enough for sentence
  /// binary search (audioplayers emits ~200ms granularity on iOS/Android).
  Stream<Duration> get positionStream => _player.onPositionChanged;

  /// Stream of player state transitions (playing / paused / stopped).
  Stream<PlayerState> get stateStream => _player.onPlayerStateChanged;

  /// Fires when the current source reaches its natural end.
  Stream<void> get completionStream => _player.onPlayerComplete;

  /// Load a chapter MP3 from a local file path. Returns true if the source
  /// changed (caller may want to reset its highlight state); returns false
  /// when the same path was already loaded.
  Future<bool> loadLocal(String path) async {
    if (_loadedPath == path) return false;
    if (!File(path).existsSync()) {
      throw StateError('audio file not found: $path');
    }
    await _player.setSource(DeviceFileSource(path));
    _loadedPath = path;
    return true;
  }

  Future<void> play() => _player.resume();
  Future<void> pause() => _player.pause();
  Future<void> stop() async {
    await _player.stop();
    _loadedPath = null;
  }

  /// Seek to an absolute position within the loaded chapter.
  Future<void> seek(Duration position) => _player.seek(position);

  /// Change playback rate. audioplayers supports 0.5–2.0 reliably across
  /// both iOS and Android; clamp here to avoid surprises.
  Future<void> setSpeed(double rate) async {
    final clamped = rate.clamp(0.5, 2.0);
    await _player.setPlaybackRate(clamped);
  }

  /// Current position (one-shot read). Useful for saving resume state.
  Future<Duration?> get currentPosition async {
    try {
      return await _player.getCurrentPosition();
    } catch (e) {
      debugPrint('[AudiobookPlayer] position read failed: $e');
      return null;
    }
  }

  /// Total duration of the currently loaded chapter, if known.
  Future<Duration?> get totalDuration async {
    try {
      return await _player.getDuration();
    } catch (e) {
      return null;
    }
  }

  Future<void> dispose() async {
    try {
      await _player.stop();
    } catch (_) {}
    await _player.dispose();
  }
}
