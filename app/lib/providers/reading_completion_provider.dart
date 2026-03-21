import 'package:omnigram/dao/book.dart';
import 'package:omnigram/models/book.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reading_completion_provider.g.dart';

@riverpod
class ReadingCompletion extends _$ReadingCompletion {
  @override
  Future<List<Book>> build() async {
    return _fetch();
  }

  Future<List<Book>> _fetch() async {
    final books = await bookDao.selectNotDeleteBooks();
    final filtered = books
        .where(
          (book) =>
              book.readingPercentage >= 0.6 && book.readingPercentage < 0.93,
        )
        .toList();
    filtered.sort(
      (a, b) => b.readingPercentage.compareTo(a.readingPercentage),
    );
    return filtered.take(5).toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetch());
  }
}
