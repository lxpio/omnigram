import 'dart:math';

import 'package:omnigram/dao/reading_time.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reading_streak_provider.g.dart';

class ReadingStreakData {
  const ReadingStreakData({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastReadingDay,
  });

  final int currentStreak;
  final int longestStreak;
  final DateTime? lastReadingDay;

  bool get hasData => lastReadingDay != null;
}

@riverpod
class ReadingStreak extends _$ReadingStreak {
  @override
  Future<ReadingStreakData> build() async {
    return _calculateStreak();
  }

  Future<ReadingStreakData> _calculateStreak() async {
    final grouped = await readingTimeDao.selectAllReadingTimeGroupByDay();
    if (grouped.isEmpty) {
      return const ReadingStreakData(
        currentStreak: 0,
        longestStreak: 0,
        lastReadingDay: null,
      );
    }

    final sortedDays = grouped.keys.toList()..sort();
    final longest = _computeLongest(sortedDays);
    final current = _computeCurrent(sortedDays);

    return ReadingStreakData(
      currentStreak: current,
      longestStreak: longest,
      lastReadingDay: sortedDays.last,
    );
  }

  int _computeLongest(List<DateTime> sortedDays) {
    var longest = 1;
    var streak = 1;
    for (var i = 1; i < sortedDays.length; i++) {
      final previous = sortedDays[i - 1];
      final current = sortedDays[i];
      if (_differenceInDays(previous, current) == 1) {
        streak++;
      } else if (previous != current) {
        streak = 1;
      }
      longest = max(longest, streak);
    }
    return longest;
  }

  int _computeCurrent(List<DateTime> sortedDays) {
    final now = DateTime.now();
    final lastDay = sortedDays.last;
    final daysFromLastRead = _differenceInDays(lastDay, now);
    if (daysFromLastRead > 1) {
      return 0;
    }

    var streak = 1;
    var expectedDay = lastDay.subtract(const Duration(days: 1));
    for (var i = sortedDays.length - 2; i >= 0; i--) {
      final day = sortedDays[i];
      if (_isSameDay(day, expectedDay)) {
        streak++;
        expectedDay = expectedDay.subtract(const Duration(days: 1));
      } else if (day.isBefore(expectedDay)) {
        break;
      }
    }
    return streak;
  }

  int _differenceInDays(DateTime from, DateTime to) {
    final fromUtc = DateTime.utc(from.year, from.month, from.day);
    final toUtc = DateTime.utc(to.year, to.month, to.day);
    return toUtc.difference(fromUtc).inDays;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _calculateStreak());
  }
}
