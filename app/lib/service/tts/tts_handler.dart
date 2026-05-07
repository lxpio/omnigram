import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/page/reading_page.dart';
import 'package:omnigram/service/tts/base_tts.dart';
import 'package:omnigram/service/tts/tts_factory.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';

/// Delegate from `TtsPlayerSessionController` to `TtsHandler` so the system
/// lock-screen / control-center / Bluetooth headset transport keys forward
/// into the active Now-Playing session. The handler holds a reference while
/// the session is alive and falls back to legacy in-reader TTS behaviour
/// when there is no binding.
class NowPlayingBinding {
  const NowPlayingBinding({
    required this.onPlay,
    required this.onPause,
    required this.onStop,
    required this.onSkipNext,
    required this.onSkipPrev,
    required this.onSeek,
  });
  final Future<void> Function() onPlay;
  final Future<void> Function() onPause;
  final Future<void> Function() onStop;
  final Future<void> Function() onSkipNext;
  final Future<void> Function() onSkipPrev;
  final Future<void> Function(Duration position) onSeek;
}

class TtsHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final TtsFactory _ttsFactory = TtsFactory();

  static final TtsHandler _instance = TtsHandler._internal();

  factory TtsHandler() {
    return _instance;
  }

  TtsHandler._internal() {
    _initAudioSession();
  }

  BaseTts get tts => _ttsFactory.current;

  NowPlayingBinding? _nowPlayingBinding;

  /// Switch the handler into Now-Playing delegating mode. While bound, all
  /// transport callbacks (play/pause/stop/skipNext/skipPrev/seek) forward to
  /// the supplied callbacks instead of the legacy in-reader TTS path.
  void bindNowPlaying(NowPlayingBinding binding) {
    _nowPlayingBinding = binding;
  }

  void unbindNowPlaying() {
    _nowPlayingBinding = null;
    queue.add(const []);
    playbackState.add(playbackState.value.copyWith(
      controls: const [],
      queueIndex: null,
      processingState: AudioProcessingState.idle,
      playing: false,
    ));
  }

  /// Push current Now-Playing metadata into system control-center.
  void updateNowPlayingMediaItem({
    required String id,
    required String title,
    required String album,
    String? artist,
    String? coverPath,
  }) {
    final item = MediaItem(
      id: id,
      title: title,
      album: album,
      artist: artist,
      duration: const Duration(milliseconds: -1),
      artUri: (coverPath != null && coverPath.isNotEmpty)
          ? Uri.tryParse('file://$coverPath')
          : null,
    );
    queue.add([item]);
    mediaItem.add(item);
  }

  void updateNowPlayingPlaybackState({
    required bool playing,
    Duration position = Duration.zero,
  }) {
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        playing ? MediaControl.pause : MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      processingState: AudioProcessingState.ready,
      playing: playing,
      queueIndex: queue.value.isNotEmpty ? 0 : null,
      updatePosition: position,
    ));
  }

  Function? _getCurrentText;
  Function? _getNextText;
  Function? _getPrevText;

  Future<void> init(Function getCurrentText, Function getNextText,
      Function getPrevText) async {
    _getCurrentText = getCurrentText;
    _getNextText = getNextText;
    _getPrevText = getPrevText;
    await tts.init(getCurrentText, getNextText, getPrevText);
  }

  Future<void> switchTtsType(String serviceId) async {
    await _ttsFactory.switchTtsType(serviceId);
    if (_getCurrentText != null &&
        _getNextText != null &&
        _getPrevText != null) {
      await tts.init(_getCurrentText!, _getNextText!, _getPrevText!);
    }
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;

    final allowMix = Prefs().allowMixWithOtherAudio;

    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: allowMix
          ? AVAudioSessionCategoryOptions.mixWithOthers
          : AVAudioSessionCategoryOptions.none,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
    ));
    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        // if (tts.isPlaying) {
        //   pause();
        // }
      } else {
        switch (event.type) {
          case AudioInterruptionType.pause:
          case AudioInterruptionType.duck:
            if (!tts.isPlaying) {
              play();
            }
            break;
          case AudioInterruptionType.unknown:
            break;
        }
      }
    });
    session.becomingNoisyEventStream.listen((_) {
      if (tts.isPlaying) pause();
    });
  }

  @override
  Future<void> play() async {
    final binding = _nowPlayingBinding;
    if (binding != null) {
      await AudioSession.instance.then((s) => s.setActive(true));
      await binding.onPlay();
      return;
    }
    await _playLegacy();
  }

  @override
  Future<void> pause() async {
    final binding = _nowPlayingBinding;
    if (binding != null) {
      await binding.onPause();
      return;
    }
    await _pauseLegacy();
  }

  @override
  Future<void> stop() async {
    final binding = _nowPlayingBinding;
    if (binding != null) {
      await binding.onStop();
      return;
    }
    await _stopLegacy();
  }

  @override
  Future<void> skipToNext() async {
    final binding = _nowPlayingBinding;
    if (binding != null) {
      await binding.onSkipNext();
      return;
    }
    await playNext();
  }

  @override
  Future<void> skipToPrevious() async {
    final binding = _nowPlayingBinding;
    if (binding != null) {
      await binding.onSkipPrev();
      return;
    }
    await playPrevious();
  }

  @override
  Future<void> seek(Duration position) async {
    final binding = _nowPlayingBinding;
    if (binding != null) {
      await binding.onSeek(position);
      return;
    }
    return super.seek(position);
  }

  Future<void> _playLegacy() async {
    final epubState = epubPlayerKey.currentState;
    if (epubState == null) {
      // No reader open and no Now-Playing binding — nothing to drive.
      return;
    }
    final session = await AudioSession.instance;
    if (await session.setActive(true)) {
      playbackState.add(playbackState.value.copyWith(
        controls: [MediaControl.pause, MediaControl.stop],
        processingState: AudioProcessingState.ready,
        playing: true,
      ));
    }

    final item = MediaItem(
      id: epubState.chapterTitle,
      title: epubState.chapterTitle,
      album: epubState.book.title,
      artist: epubState.book.author,
      duration: const Duration(milliseconds: -1),
      artUri: Uri.tryParse('file://${epubState.book.coverFullPath}'),
    );

    queue.add([item]);
    mediaItem.add(item);
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        MediaControl.pause,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      processingState: AudioProcessingState.ready,
      playing: true,
      queueIndex: 0,
      updatePosition: Duration.zero,
      bufferedPosition: Duration.zero,
    ));
    if (tts.ttsStateNotifier.value == TtsStateEnum.paused) {
      tts.updateTtsState(TtsStateEnum.playing);
      await tts.resume();
    } else {
      tts.updateTtsState(TtsStateEnum.playing);
      await tts.speak();
    }
  }

  Future<void> _pauseLegacy() async {
    playbackState.add(playbackState.value.copyWith(
      controls: [MediaControl.play, MediaControl.stop],
      queueIndex: queue.value.isNotEmpty ? 0 : null,
      processingState: AudioProcessingState.ready,
      playing: false,
    ));

    await tts.pause();
    tts.updateTtsState(TtsStateEnum.paused);
  }

  Future<void> _stopLegacy() async {
    playbackState.add(playbackState.value.copyWith(
      controls: [],
      queueIndex: null,
      processingState: AudioProcessingState.idle,
      playing: false,
    ));

    tts.updateTtsState(TtsStateEnum.stopped);
    await tts.stop();
    epubPlayerKey.currentState?.ttsStop();
  }

  Future<void> playPrevious() async {
    await tts.prev();
  }

  Future<void> playNext() async {
    await tts.next();
  }

  ValueNotifier<TtsStateEnum> get ttsStateNotifier => tts.ttsStateNotifier;

  bool get isPlaying => tts.isPlaying;

  set volume(double volume) {
    tts.volume = volume;
  }

  double get volume => tts.volume;

  set pitch(double pitch) {
    tts.pitch = pitch;
  }

  double get pitch => tts.pitch;

  set rate(double rate) {
    tts.rate = rate;
  }

  double get rate => tts.rate;
}
