import 'package:omnigram/widgets/statistic/dashboard_tiles/dashboard_tile_base.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/tiles/books_total_tile.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/tiles/completion_progress_tile.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/tiles/library_totals_tile.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/tiles/notes_total_tile.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/tiles/period_summary_tile.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/tiles/random_highlight_tile.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/tiles/reading_days_tile.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/tiles/reading_duration_trend_tile.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/tiles/reading_streak_tile.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/tiles/continue_reading_tile.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/tiles/top_book_tile.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/tiles/total_time_tile.dart';

/// Types of dashboard tiles that can appear in the statistics dashboard.
enum StatisticsDashboardTileType {
  totalTime,
  libraryTotals,
  periodSummary,
  booksTotal,
  readingDaysTotal,
  notesTotal,
  readingStreak,
  randomHighlight,
  readingDurationLast7,
  readingDurationLast30,
  completionProgress,
  topBook,
  continueReading,
}

/// Default order for dashboard tiles when the user has not customized the layout.
const List<StatisticsDashboardTileType> defaultStatisticsDashboardTiles = [
  StatisticsDashboardTileType.readingDaysTotal,
  StatisticsDashboardTileType.booksTotal,
  StatisticsDashboardTileType.periodSummary,
  StatisticsDashboardTileType.topBook,
  StatisticsDashboardTileType.readingStreak,
  StatisticsDashboardTileType.randomHighlight,
  StatisticsDashboardTileType.completionProgress,
  StatisticsDashboardTileType.readingDurationLast7,
  StatisticsDashboardTileType.readingDurationLast30,
];

final Map<StatisticsDashboardTileType, StatisticsDashboardTileBase>
    dashboardTileRegistry = {
  StatisticsDashboardTileType.totalTime: const TotalTimeTile(),
  StatisticsDashboardTileType.libraryTotals: const LibraryTotalsTile(),
  StatisticsDashboardTileType.periodSummary: const PeriodSummaryTile(),
  StatisticsDashboardTileType.booksTotal: const BooksTotalTile(),
  StatisticsDashboardTileType.readingDaysTotal: const ReadingDaysTile(),
  StatisticsDashboardTileType.notesTotal: const NotesTotalTile(),
  StatisticsDashboardTileType.readingStreak: const ReadingStreakTile(),
  StatisticsDashboardTileType.randomHighlight: const RandomHighlightTile(),
  StatisticsDashboardTileType.readingDurationLast7: ReadingDurationLast7Tile(),
  StatisticsDashboardTileType.readingDurationLast30:
      ReadingDurationLast30Tile(),
  StatisticsDashboardTileType.completionProgress:
      const CompletionProgressTile(),
  StatisticsDashboardTileType.topBook: const TopBookTile(),
  StatisticsDashboardTileType.continueReading: const ContinueReadingTile(),
};
