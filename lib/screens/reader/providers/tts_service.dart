import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:omnigram/providers/service/provider.dart';
import 'package:omnigram/screens/reader/models/epub_document.dart';
import 'package:omnigram/utils/constants.dart';
import 'package:omnigram/utils/wav.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:just_audio/just_audio.dart';
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
      //要先关闭现有的
      await ref.read(selectBookProvider.notifier).saveProcess();
    }
    state = TTSState(showbar: state.showbar, playing: false);

    // ref.notifyListeners();
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

    // ref.notifyListeners();
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
    var pos = document.absParagraphIndex(index) ?? 0;

    Future<String> streamData = _fetchWavStream(document, pos);

    //send to tts server

    while (state.playing) {
      final wavSource = await streamData;

      pos++;
      final next = document.nextIndex(current, pos);

      if (next == null) {
        //读到底了,play stop tone

        state = state.copyWith(playing: false);
      } else {
        //read current book data and send
        current = next;

        streamData = _fetchWavStream(document, pos);
        final player = AudioPlayer();
        // await player.setAudioSource(wavSource);
        await player.setFilePath(wavSource);
        await player.play();

        ref
            .read(selectBookProvider.notifier)
            .updateProgress(current, document.progress(current));
      }

      ref.notifyListeners();
      //delay
    }
    print('exit runtask');
  }

  Future<String> _fetchWavStream(EpubDocument document, int pos) async {
    final bookApi = ref.read(apiServiceProvider);

    final content = document.getContent(pos);
    print(content);
    final fileName = '$globalCachePath/${document.id}_$pos.wav';

    final exists = await File(fileName).exists();

    if (exists) {
      return fileName;
    }

    try {
      final response = await bookApi.ttsStream<ResponseBody>(
        "/m4t/pcm/stream",
        body: {
          "text": content,
          "audio_id": "1",
          "lang": 'zh-cn',
        },
        header: {"responseType": "application/json"},
      );

      if (response.statusCode == HttpStatus.ok) {
        // Pipe the stream to the StreamController
        final raw = Int16Wav(numChannels: 1, sampleRate: 24000);
        await response.data!.stream.forEach((element) {
          raw.append(element);
        });
        // return MyCustomSource(raw.wavBytes);

        await raw.writeFile(fileName);
        return fileName;
        // return raw.wavBytes;
      } else {
        throw Exception("fetch stream bytes failed");
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}

// Feed your own stream of bytes into the player
class MyCustomSource extends StreamAudioSource {
  final List<int> bytes;
  MyCustomSource(this.bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}
