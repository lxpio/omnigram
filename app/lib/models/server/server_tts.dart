import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_tts.freezed.dart';
part 'server_tts.g.dart';

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
