import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'book_filters.g.dart';

enum ReadingStatusFilter { none, finished, reading, notStarted }

@riverpod
class ReadingStatusFilterNotifier extends _$ReadingStatusFilterNotifier {
  @override
  ReadingStatusFilter build() => ReadingStatusFilter.none;

  void toggle(ReadingStatusFilter status) {
    if (state == status) {
      state = ReadingStatusFilter.none;
    } else {
      state = status;
    }
  }

  void clear() {
    state = ReadingStatusFilter.none;
  }
}
