import 'dart:math' as math;

import 'package:omnigram/dao/reading_time.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'book_daily_reading_provider.g.dart';

class BookDailyReadingData {
  final List<DateTime> dates;
  final List<int> readingTimes;
  final List<String> formattedLabels;
  final int maxReadingTime;

  const BookDailyReadingData({
    required this.dates,
    required this.readingTimes,
    required this.formattedLabels,
    required this.maxReadingTime,
  });

  factory BookDailyReadingData.mock() {
    return BookDailyReadingData(
      dates: [],
      readingTimes: [],
      formattedLabels: [],
      maxReadingTime: 0,
    );
  }
}

@riverpod
class BookDailyReading extends _$BookDailyReading {
  Future<BookDailyReadingData> _fetchBookDailyReading({
    required int bookId,
    required int days,
  }) async {
    final rawData = await readingTimeDao.selectBookDailyReadingTime(
      bookId: bookId,
      days: days,
    );

    if (rawData.isEmpty) {
      return BookDailyReadingData.mock();
    }

    final readingTimeMap = <String, int>{};
    for (final row in rawData) {
      readingTimeMap[row['day'] as String] = row['total_time'] as int;
    }

    final dates = <DateTime>[];
    final readingTimes = <int>[];
    final formattedLabels = <String>[];
    int maxReadingTime = 0;

    final now = DateTime.now();
    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = date.toIso8601String().substring(0, 10);
      final readingTime = readingTimeMap[dateKey] ?? 0;

      dates.add(date);
      readingTimes.add(readingTime);
      maxReadingTime = math.max(maxReadingTime, readingTime);

      if (i == days - 1 || date.day == 1 || (days - i) % 5 == 0) {
        formattedLabels.add('${date.month}/${date.day}');
      } else {
        formattedLabels.add('');
      }
    }

    return BookDailyReadingData(
      dates: dates,
      readingTimes: readingTimes,
      formattedLabels: formattedLabels,
      maxReadingTime: maxReadingTime,
    );
  }

  @override
  Future<BookDailyReadingData> build({
    required int bookId,
    int days = 30,
  }) async {
    return _fetchBookDailyReading(bookId: bookId, days: days);
  }
}
