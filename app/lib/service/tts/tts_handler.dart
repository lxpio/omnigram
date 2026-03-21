import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/page/reading_page.dart';
import 'package:omnigram/service/tts/base_tts.dart';
import 'package:omnigram/service/tts/tts_factory.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';

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
    final session = await AudioSession.instance;
    if (await session.setActive(true)) {
      playbackState.add(playbackState.value.copyWith(
        controls: [MediaControl.pause, MediaControl.stop],
        processingState: AudioProcessingState.ready,
        playing: true,
      ));
    }

    final item = MediaItem(
      id: epubPlayerKey.currentState!.chapterTitle,
      title: epubPlayerKey.currentState!.chapterTitle,
      album: epubPlayerKey.currentState!.book.title,
      artist: epubPlayerKey.currentState!.book.author,
      // Use -1 to tell system not to render a progress bar.
      duration: const Duration(milliseconds: -1),
      artUri: Uri.tryParse(
          'file://${epubPlayerKey.currentState!.book.coverFullPath}'),
    );

    // Ensure system receives queue + active index for control center metadata.
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

  @override
  Future<void> pause() async {
    playbackState.add(playbackState.value.copyWith(
      controls: [MediaControl.play, MediaControl.stop],
      queueIndex: queue.value.isNotEmpty ? 0 : null,
      processingState: AudioProcessingState.ready,
      playing: false,
    ));

    await tts.pause();
    tts.updateTtsState(TtsStateEnum.paused);
  }

  @override
  Future<void> stop() async {
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

  @override
  Future<void> skipToNext() async {
    await playNext();
  }

  @override
  Future<void> skipToPrevious() async {
    await playPrevious();
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
