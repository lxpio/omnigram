import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_tts.freezed.dart';
part 'server_tts.g.dart';

@freezed
abstract class ProbeResult with _$ProbeResult {
  const factory ProbeResult({
    @JsonKey(name: 'first_byte_ms') @Default(0) int firstByteMs,
    @JsonKey(name: 'total_ms') @Default(0) int totalMs,
    @JsonKey(name: 'audio_duration_ms') @Default(0) int audioDurationMs,
    @Default(0.0) double rtf,
    @Default('') String voice,
    @Default('') String provider,
    @JsonKey(name: 'server_build') @Default('') String serverBuild,
  }) = _ProbeResult;

  factory ProbeResult.fromJson(Map<String, dynamic> json) => _$ProbeResultFromJson(json);
}

@freezed
abstract class ServerVoice with _$ServerVoice {
  const factory ServerVoice({
    @Default('') String id,
    @Default('') String name,
    String? language,
    String? gender,
    String? provider,
  }) = _ServerVoice;

  factory ServerVoice.fromJson(Map<String, dynamic> json) => _$ServerVoiceFromJson(json);
}

@freezed
abstract class ServerAudiobookTask with _$ServerAudiobookTask {
  const factory ServerAudiobookTask({
    @Default('') String id,
    @JsonKey(name: 'book_id') @Default('') String bookId,
    @JsonKey(name: 'user_id') @Default('') String userId,
    @Default('pending') String status,
    @Default('') String voice,
    @Default(1.0) double speed,
    @Default('') String provider,
    @Default('mp3') String format,
    @JsonKey(name: 'total_chapters') @Default(0) int totalChapters,
    @JsonKey(name: 'done_chapters') @Default(0) int doneChapters,
    @JsonKey(name: 'failed_chapters') @Default(0) int failedChapters,
    @JsonKey(name: 'total_size') @Default(0) int totalSize,
    @JsonKey(name: 'error_message') String? errorMessage,
    @Default(0) @JsonKey(name: 'ctime') int cTime,
    @Default(0) @JsonKey(name: 'utime') int uTime,
  }) = _ServerAudiobookTask;

  factory ServerAudiobookTask.fromJson(Map<String, dynamic> json) => _$ServerAudiobookTaskFromJson(json);
}

@freezed
abstract class ServerTtsHealth with _$ServerTtsHealth {
  const factory ServerTtsHealth({@Default('') String status}) = _ServerTtsHealth;

  factory ServerTtsHealth.fromJson(Map<String, dynamic> json) => _$ServerTtsHealthFromJson(json);
}

@freezed
abstract class ServerAudiobookChapter with _$ServerAudiobookChapter {
  const factory ServerAudiobookChapter({
    @Default('') String id,
    @JsonKey(name: 'task_id') @Default('') String taskId,
    @JsonKey(name: 'book_id') @Default('') String bookId,
    @JsonKey(name: 'chapter_index') @Default(0) int chapterIndex,
    @JsonKey(name: 'chapter_title') @Default('') String chapterTitle,
    @JsonKey(name: 'chapter_href') @Default('') String chapterHref,
    @Default(0) int status,
    @JsonKey(name: 'audio_size') @Default(0) int audioSize,
    @JsonKey(name: 'audio_duration') @Default(0.0) double audioDuration,
    @JsonKey(name: 'error_message') String? errorMessage,
  }) = _ServerAudiobookChapter;

  factory ServerAudiobookChapter.fromJson(Map<String, dynamic> json) => _$ServerAudiobookChapterFromJson(json);
}

/// Wraps the server's `{task, chapters}` payload under `/tts/audiobook/:id`.
@freezed
abstract class ServerAudiobookInfo with _$ServerAudiobookInfo {
  const factory ServerAudiobookInfo({
    required ServerAudiobookTask task,
    @Default(<ServerAudiobookChapter>[]) List<ServerAudiobookChapter> chapters,
  }) = _ServerAudiobookInfo;

  factory ServerAudiobookInfo.fromJson(Map<String, dynamic> json) => _$ServerAudiobookInfoFromJson(json);
}

/// One sentence's mapping to its audio span.
///
/// Matches server's tts.SentenceAlignment — `start_ms`/`end_ms` are cumulative
/// positions in the chapter MP3; `char_offset` is rune offset in the chapter's
/// plain text (used for text-matching fallback against foliate-js output).
@freezed
abstract class SentenceAlignment with _$SentenceAlignment {
  const factory SentenceAlignment({
    @Default(0) int index,
    @Default('') String text,
    @JsonKey(name: 'start_ms') @Default(0) int startMs,
    @JsonKey(name: 'end_ms') @Default(0) int endMs,
    @JsonKey(name: 'char_offset') @Default(0) int charOffset,
    @JsonKey(name: 'synth_failed') @Default(false) bool synthFailed,
  }) = _SentenceAlignment;

  factory SentenceAlignment.fromJson(Map<String, dynamic> json) => _$SentenceAlignmentFromJson(json);
}

/// Full chapter alignment file — loaded from
/// `GET /tts/audiobook/:id/:chapter/alignment`.
@freezed
abstract class ChapterAlignment with _$ChapterAlignment {
  const factory ChapterAlignment({
    @JsonKey(name: 'schema_version') @Default(1) int schemaVersion,
    @JsonKey(name: 'chapter_index') @Default(0) int chapterIndex,
    @JsonKey(name: 'chapter_title') @Default('') String chapterTitle,
    @JsonKey(name: 'audio_file') @Default('') String audioFile,
    @JsonKey(name: 'audio_duration_ms') @Default(0) int audioDurationMs,
    @Default('') String voice,
    @Default('') String provider,
    @JsonKey(name: 'generated_at') @Default(0) int generatedAt,
    @Default(<SentenceAlignment>[]) List<SentenceAlignment> sentences,
  }) = _ChapterAlignment;

  factory ChapterAlignment.fromJson(Map<String, dynamic> json) => _$ChapterAlignmentFromJson(json);
}

/// Book-level audiobook manifest — from `GET /tts/audiobook/:id/index`.
@freezed
abstract class AudiobookIndex with _$AudiobookIndex {
  const factory AudiobookIndex({
    @JsonKey(name: 'schema_version') @Default(1) int schemaVersion,
    @JsonKey(name: 'book_id') @Default('') String bookId,
    @Default('') String voice,
    @Default('') String provider,
    @JsonKey(name: 'total_chapters') @Default(0) int totalChapters,
    @JsonKey(name: 'done_chapters') @Default(0) int doneChapters,
    @JsonKey(name: 'total_duration_ms') @Default(0) int totalDurationMs,
    @Default(<AudiobookIndexChapter>[]) List<AudiobookIndexChapter> chapters,
  }) = _AudiobookIndex;

  factory AudiobookIndex.fromJson(Map<String, dynamic> json) => _$AudiobookIndexFromJson(json);
}

@freezed
abstract class AudiobookIndexChapter with _$AudiobookIndexChapter {
  const factory AudiobookIndexChapter({
    @Default(0) int index,
    @Default('') String title,
    @JsonKey(name: 'audio_file') @Default('') String audioFile,
    @JsonKey(name: 'align_file') @Default('') String alignFile,
    @JsonKey(name: 'duration_ms') @Default(0) int durationMs,
    @JsonKey(name: 'sentence_count') @Default(0) int sentenceCount,
    @Default(0) int status,
  }) = _AudiobookIndexChapter;

  factory AudiobookIndexChapter.fromJson(Map<String, dynamic> json) => _$AudiobookIndexChapterFromJson(json);
}
