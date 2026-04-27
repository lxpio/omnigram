import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:omnigram/models/server/server_tts.dart';
import 'package:omnigram/service/tts/tts_router.dart';

part 'playback_state.freezed.dart';
part 'playback_state.g.dart';

@freezed
abstract class PlaybackState with _$PlaybackState {
  const PlaybackState._();
  const factory PlaybackState({
    String? bookId,
    String? coverUrl,
    String? bookTitle,
    @Default(0) int chapterIndex,
    @Default('') String chapterTitle,
    @Default(0) int totalChapters,
    @Default(PlaybackMode.liveServer) PlaybackMode mode,
    @Default(false) bool isPlaying,
    @Default(false) bool isPreparing,
    @Default(Duration.zero) Duration position,
    @Default(Duration.zero) Duration duration,
    @Default(-1) int sentenceIndex,
    ChapterAlignment? alignment,
    @Default(0) int serverProgressPercent,
    @Default(false) bool serverReadyForCurrentChapter,
    @Default(1.0) double speed,
    String? errorMessage,
  }) = _PlaybackState;

  factory PlaybackState.fromJson(Map<String, dynamic> json) => _$PlaybackStateFromJson(json);

  bool get hasSession => bookId != null;
  bool get hasAlignment => alignment != null && alignment!.sentences.isNotEmpty;
}
