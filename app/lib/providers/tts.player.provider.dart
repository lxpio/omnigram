import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:omnigram/providers/select_book.dart';
import 'package:omnigram/providers/tts/tts.service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/epub/epub.dart';
import '../models/epub_document.dart';

part 'tts.player.provider.g.dart';

class TTSState {
  TTSState({
    required this.showbar,
    required this.playing,
    this.position,
  });

  final bool showbar;
  final bool playing;
  final Duration? position;

  TTSState copyWith({
    bool? showbar,
    bool? playing,
    Duration? position,
  }) {
    return TTSState(
      showbar: showbar ?? this.showbar,
      playing: playing ?? this.playing,
      position: position ?? this.position,
    );
  }

  @override
  String toString() => 'TTSState(showbar: $showbar, playing: $playing)';

  @override
  bool operator ==(covariant TTSState other) {
    if (identical(this, other)) return true;

    return other.showbar == showbar && other.playing == playing && other.position == position;
  }

  @override
  int get hashCode => showbar.hashCode ^ playing.hashCode ^ position.hashCode;
}

@Riverpod(keepAlive: true)
class TtsPlayer extends _$TtsPlayer {
  late AudioPlayer player;

  @override
  TTSState build() {
    player = AudioPlayer();
    return TTSState(showbar: false, playing: false);
  }

  void toggle() {
    state = TTSState(showbar: !state.showbar, playing: state.playing);
  }

  Future<void> pause() async {
    if (state.playing) {
      await player.pause();

      final position = player.position.inMilliseconds;
      //要先关闭现有的
      await ref.read(selectBookProvider.notifier).saveProcess(position);
    }
    state = TTSState(showbar: state.showbar, playing: false);

    // ref.notifyListeners();
  }

  Future<void> resume() async {
    state = TTSState(showbar: state.showbar, playing: true);
  }

  Future<void> stop() async {
    await player.stop();

    final position = player.position.inMilliseconds;
    //要先关闭现有的
    await ref.read(selectBookProvider.notifier).saveProcess(position);

    state = TTSState(showbar: state.showbar, playing: false);
  }

  Future<void> close() async {
    if (state.playing) {
      //要先关闭现有的
      await player.stop();

      final position = player.position.inMilliseconds;
      //要先关闭现有的
      await ref.read(selectBookProvider.notifier).saveProcess(position);
    }
    state = TTSState(showbar: false, playing: false);

    // ref.notifyListeners();
  }

  Future<void> play(EpubDocument document) async {
    if (state.playing) {
      return;
    }
    state = TTSState(showbar: true, playing: true);

    //获取当前index
    final index = ref.read(selectBookProvider.select((value) => value.index)) ??
        const ChapterIndex(chapterIndex: 0, paragraphIndex: 0);

    await runtask(document, index);
  }

  void updateIndex(ChapterIndex? current) {
    if (state.playing) {
      return;
    }
    // final diff = manual ? 5 : 0;
    ref.read(selectBookProvider.notifier).updateIndex(current);
  }

  Future<void> runtask(EpubDocument document, ChapterIndex index) async {
    debugPrint('runtask  ${document.book.Title}');

    var current = index;
    var pos = document.absParagraphIndex(index) ?? 0;

    Future<String?> streamData = _fetch(document, pos);

    while (state.playing) {
      final wavSource = await streamData;

      pos++;
      final next = document.nextIndex(current, pos);

      if (next != null) {
        //还有段落，缓存下一个
        streamData = _fetch(document, pos);
      }

      if (wavSource == null) {
        //没有数据了
        state = state.copyWith(playing: false);
        break;
      }

      await player.setFilePath(wavSource);
      await player.seek(current.duration);
      await player.play();

      if (next != null) {
        current = next;
        ref.read(selectBookProvider.notifier).updateProgress(current, document.progress(current));
      } else {
        state = state.copyWith(playing: false);

        break;
      }
    }
    debugPrint('exit runtask');
  }

  Future<String?> _fetch(EpubDocument document, int pos) async {
    try {
      final content = document.getContent(pos);
      final filePath = await ref.watch(ttsServiceProvider).saveToFile('${document.id}_$pos', 'mp3', content);
      return filePath;
    } catch (e) {
      debugPrint('error $e');
      return null;
    }
  }
}
