import 'package:omnigram/dao/reading_time.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reading_duration_trend_provider.g.dart';

class ReadingDurationSeries {
  const ReadingDurationSeries({
    required this.labels,
    required this.cumulativeSeconds,
    required this.totalSeconds,
    required this.dates,
  });

  final List<String> labels;
  final List<int> cumulativeSeconds;
  final int totalSeconds;
  final List<DateTime> dates;

  int get maxSeconds => cumulativeSeconds.isEmpty ? 0 : cumulativeSeconds.last;
}

class ReadingDurationTrendData {
  const ReadingDurationTrendData({
    required this.lastSevenDays,
    required this.lastThirtyDays,
  });

  final ReadingDurationSeries lastSevenDays;
  final ReadingDurationSeries lastThirtyDays;

  static ReadingDurationTrendData mock() {
    List<int> sample(int days, int step) {
      int value = 0;
      return List.generate(days, (index) {
        value += (index + 1) * step;
        return value;
      });
    }

    List<String> labels(int days) =>
        List.generate(days, (index) => '${index + 1}');
    final now = DateTime.now();
    List<DateTime> dates(int days) => List.generate(
          days,
          (index) => now.subtract(Duration(days: (days - 1) - index)),
        );

    return ReadingDurationTrendData(
      lastSevenDays: ReadingDurationSeries(
        labels: labels(7),
        cumulativeSeconds: sample(7, 600),
        totalSeconds: 7 * 600,
        dates: dates(7),
      ),
      lastThirtyDays: ReadingDurationSeries(
        labels: labels(30),
        cumulativeSeconds: sample(30, 300),
        totalSeconds: 30 * 300,
        dates: dates(30),
      ),
    );
  }
}

@riverpod
class ReadingDurationTrend extends _$ReadingDurationTrend {
  @override
  Future<ReadingDurationTrendData> build() async {
    return _fetchData();
  }

  Future<ReadingDurationTrendData> _fetchData() async {
    final now = DateTime.now();
    final sevenSeries = await _seriesForDays(now, 7);
    final thirtySeries = await _seriesForDays(now, 30);

    return ReadingDurationTrendData(
      lastSevenDays: sevenSeries,
      lastThirtyDays: thirtySeries,
    );
  }

  Future<ReadingDurationSeries> _seriesForDays(DateTime now, int days) async {
    final startDate = now.subtract(Duration(days: days - 1));
    final aggregation =
        await readingTimeDao.selectDailyReadingTimeSince(startDate);
    final labels = <String>[];
    final cumulative = <int>[];
    final dates = <DateTime>[];
    var runningTotal = 0;
    final formatter = DateFormat('MM/dd');

    for (var i = 0; i < days; i++) {
      final day = DateTime(startDate.year, startDate.month, startDate.day)
          .add(Duration(days: i));
      final total = aggregation[day] ?? 0;
      runningTotal += total;
      cumulative.add(runningTotal);
      dates.add(day);

      final shouldShowLabel = days == 7
          ? true
          : (i == 0 || i == days - 1 || i % 5 == 0 || day.day == 1);
      labels.add(shouldShowLabel ? formatter.format(day) : '');
    }

    return ReadingDurationSeries(
      labels: labels,
      cumulativeSeconds: cumulative,
      totalSeconds: runningTotal,
      dates: dates,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetchData());
  }
}
