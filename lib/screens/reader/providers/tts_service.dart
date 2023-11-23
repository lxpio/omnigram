import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:omnigram/screens/reader/models/epub_document.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/epub/epub.dart';
import 'select_book.dart';

part 'tts_service.g.dart';
part 'tts_service.freezed.dart';

@freezed
class TTSState with _$TTSState {
  const factory TTSState({
    @Default(false) bool showbar,
    @Default(false) bool playing,
  }) = _TTSState;

  factory TTSState.fromJson(Map<String, Object?> json) =>
      _$TTSStateFromJson(json);
}

@Riverpod(keepAlive: true)
class TtsService extends _$TtsService {
  @override
  TTSState build() {
    return const TTSState();
  }

  void toggle() {
    state = TTSState(showbar: !state.showbar, playing: state.playing);
  }

  Future<void> pause() async {
    if (state.playing) {
      await ref.read(selectBookProvider.notifier).saveProcess();
    }
    state = TTSState(showbar: state.showbar, playing: false);

    ref.notifyListeners();
  }

  void resume() {
    state = TTSState(showbar: state.showbar, playing: true);
  }

  void stop() {
    state = TTSState(showbar: state.showbar, playing: false);
  }

  Future<void> close() async {
    if (state.playing) {
      //要先关闭现有的
      await ref.read(selectBookProvider.notifier).saveProcess();
    }
    state = const TTSState();

    ref.notifyListeners();
  }

  Future<void> play(EpubDocument document) async {
    if (state.playing) {
      return;
    }
    state = const TTSState(showbar: true, playing: true);

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
    print('runtask  ${document.book.Title}');

    var current = index;

    while (state.playing) {
      final content = document.getContent(current);
      print(content);
      await Future.delayed(const Duration(seconds: 1));

      final next = document.nextIndex(current);

      if (next == null) {
        //读到底了,play stop tone

        state = state.copyWith(playing: false);
      } else {
        //read current book data and send
        current = next;
        ref
            .read(selectBookProvider.notifier)
            .updateProgress(current, document.progress(current));
      }

      ref.notifyListeners();
      //delay
    }
    print('exit runtask');
  }
}
