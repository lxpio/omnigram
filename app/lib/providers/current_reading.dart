import 'package:omnigram/models/current_reading_state.dart';
import 'package:omnigram/utils/log/common.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_reading.g.dart';

@Riverpod(keepAlive: true)
class CurrentReading extends _$CurrentReading {
  @override
  CurrentReadingState build() {
    return const CurrentReadingState();
  }

  void start(CurrentReadingState newState) {
    state = newState.copyWith(isReading: true);
  }

  void update({
    String? cfi,
    double? percentage,
    String? chapterTitle,
    String? chapterHref,
    int? chapterCurrentPage,
    int? chapterTotalPages,
  }) {
    if (state.book == null) {
      return;
    }
    state = state.copyWith(
      cfi: cfi ?? state.cfi,
      percentage: percentage ?? state.percentage,
      chapterTitle: chapterTitle ?? state.chapterTitle,
      chapterHref: chapterHref ?? state.chapterHref,
      chapterCurrentPage: chapterCurrentPage ?? state.chapterCurrentPage,
      chapterTotalPages: chapterTotalPages ?? state.chapterTotalPages,
    );
  }

  void finish() {
    state = state.copyWith(isReading: false);
    AnxLog.info('CurrentReading: finish reading ${state.book?.title}');
  }

  bool get isReading => state.isReading;
}
