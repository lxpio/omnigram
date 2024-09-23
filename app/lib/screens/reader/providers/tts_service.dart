// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:just_audio/just_audio.dart';
import 'package:openapi/openapi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:omnigram/providers/api.provider.dart';
import 'package:omnigram/screens/reader/models/epub_document.dart';
import 'package:omnigram/utils/constants.dart';
import 'package:omnigram/utils/wav.dart';

import '../models/epub/epub.dart';
import 'select_book.dart';

part 'tts_service.g.dart';

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
  
    return 
      other.showbar == showbar &&
      other.playing == playing &&
      other.position == position;

      
  }

  @override
  int get hashCode => showbar.hashCode ^ playing.hashCode ^ position.hashCode;
}


@Riverpod(keepAlive: true)
class TtsService extends _$TtsService {
  late AudioPlayer player;

  @override
  TTSState build() {
    player = AudioPlayer();
    return  TTSState(showbar: false, playing: false);
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
    state =  TTSState(showbar: false, playing: false);

    // ref.notifyListeners();
  }

  Future<void> play(EpubDocument document) async {
    if (state.playing) {
      return;
    }
    state =  TTSState(showbar: true, playing: true);

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

    while (state.playing) {
      final wavSource = await streamData;

      pos++;
      final next = document.nextIndex(current, pos);

      if (next != null) {
        //还有段落，缓存下一个
        streamData = _fetchWavStream(document, pos);
      }

      await player.setFilePath(wavSource);
      await player.seek(current.duration);
      await player.play();

      if (next != null) {
        current = next;
        ref
            .read(selectBookProvider.notifier)
            .updateProgress(current, document.progress(current));
      } else {
        
        state = state.copyWith(playing: false); 
 
        break;
      }
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


      final response = await bookApi.m4tTtsStreamPost(
        m4tTtsStreamPostRequest: M4tTtsStreamPostRequest((b) => b
          ..text = content
          ..audioId = '1'
          ..lang = 'zh-cn'
          ),
          // headers: responseType: ResponseType.stream);
      );


      // final response = await bookApi.ttsStream<ResponseBody>(
      //   "/m4t/pcm/stream",
      //   body: {
      //     "text": content,
      //     "audio_id": "1",
      //     "lang": 'zh-cn',
      //   },
      //   header: {"responseType": "application/json"},
      // );

      if (response.statusCode == HttpStatus.ok) {
        // Pipe the stream to the StreamController
        final raw = Int16Wav(numChannels: 1, sampleRate: 24000);

        // final raw = Int16Wav(numChannels: 1, sampleRate: 24000);

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
