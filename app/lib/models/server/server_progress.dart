import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_progress.freezed.dart';
part 'server_progress.g.dart';

@freezed
abstract class ServerReadProgress with _$ServerReadProgress {
  const factory ServerReadProgress({
    @Default(0) int id,
    @JsonKey(name: 'book_id') @Default('') String bookId,
    @JsonKey(name: 'user_id') @Default(0) int userId,
    @JsonKey(name: 'start_date') @Default(0) int startDate,
    @JsonKey(name: 'updated_at') @Default(0) int updatedAt,
    @JsonKey(name: 'expt_end_date') @Default(0) int exptEndDate,
    @JsonKey(name: 'end_date') @Default(0) int endDate,
    @JsonKey(name: 'progress_index') @Default(0) int progressIndex,
    @Default(0.0) double progress,
    @JsonKey(name: 'para_position') @Default(0) int paraPosition,
  }) = _ServerReadProgress;

  factory ServerReadProgress.fromJson(Map<String, dynamic> json) => _$ServerReadProgressFromJson(json);
}

@freezed
abstract class ServerReadingSession with _$ServerReadingSession {
  const factory ServerReadingSession({
    @Default(0) int id,
    @JsonKey(name: 'user_id') @Default(0) int userId,
    @JsonKey(name: 'book_id') @Default('') String bookId,
    @JsonKey(name: 'device_id') String? deviceId,
    @JsonKey(name: 'start_time') @Default(0) int startTime,
    @JsonKey(name: 'end_time') @Default(0) int endTime,
    @Default(0) int duration,
    @JsonKey(name: 'pages_read') @Default(0) int pagesRead,
  }) = _ServerReadingSession;

  factory ServerReadingSession.fromJson(Map<String, dynamic> json) => _$ServerReadingSessionFromJson(json);
}
