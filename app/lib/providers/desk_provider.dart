import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/dao/book.dart';
import 'package:omnigram/dao/reading_time.dart';

part 'desk_provider.g.dart';

@riverpod
Future<DeskData> deskData(Ref ref) async {
  final bookDao = BookDao();
  final allBooks = await bookDao.selectNotDeleteBooks();
  final inProgress = allBooks.where((b) => b.readingPercentage > 0 && b.readingPercentage < 1.0).toList()
    ..sort((a, b) => b.updateTime.compareTo(a.updateTime));

  final readingTimeDao = ReadingTimeDao();
  final todayBooks = await readingTimeDao.selectBookReadingTimeOfDay(DateTime.now());
  final todayMinutes = todayBooks.fold<int>(0, (sum, entry) => sum + entry.values.first) ~/ 60;

  return DeskData(
    currentBook: inProgress.isNotEmpty ? inProgress.first : null,
    alsoReading: inProgress.length > 1 ? inProgress.sublist(1) : [],
    todayReadingMinutes: todayMinutes,
  );
}

class DeskData {
  final Book? currentBook;
  final List<Book> alsoReading;
  final int todayReadingMinutes;

  const DeskData({required this.currentBook, required this.alsoReading, required this.todayReadingMinutes});
}
