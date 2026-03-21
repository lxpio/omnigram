import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/providers/reading_duration_trend_provider.dart';
import 'package:omnigram/utils/date/convert_seconds.dart';
import 'package:omnigram/widgets/common/async_skeleton_wrapper.dart';
import 'package:omnigram/widgets/statistic/book_reading_chart.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/dashboard_tile_base.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/dashboard_tile_metadata.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/dashboard_tile_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class _BaseReadingDurationTile extends StatisticsDashboardTileBase {
  const _BaseReadingDurationTile({
    required this.type,
    required this.titleBuilder,
    required this.descriptionBuilder,
    required this.days,
  });

  @override
  final StatisticsDashboardTileType type;
  final String Function(L10n l10n) titleBuilder;
  final String Function(L10n l10n) descriptionBuilder;
  final int days;

  ReadingDurationSeries _selectSeries(ReadingDurationTrendData data) {
    return days == 7 ? data.lastSevenDays : data.lastThirtyDays;
  }

  @override
  Widget buildCorner(BuildContext context, WidgetRef ref) {
    return cornerText(context, '$days ');
  }

  @override
  StatisticsDashboardTileMetadata get metadata {
    final l10n = l10nLocal;
    return StatisticsDashboardTileMetadata(
      type: type,
      title: titleBuilder(l10n),
      description: descriptionBuilder(l10n),
      columnSpan: 2,
      rowSpan: 1,
      icon: Icons.timeline,
    );
  }

  @override
  Widget buildContent(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(readingDurationTrendProvider);
    return AsyncSkeletonWrapper<ReadingDurationTrendData>(
      asyncValue: asyncValue,
      mock: ReadingDurationTrendData.mock(),
      builder: (data, _) => _ReadingDurationTileBody(
        series: _selectSeries(data),
      ),
    );
  }
}

class ReadingDurationLast7Tile extends _BaseReadingDurationTile {
  ReadingDurationLast7Tile()
      : super(
          type: StatisticsDashboardTileType.readingDurationLast7,
          titleBuilder: (l10n) => l10n.tileReadingDuration7Title,
          descriptionBuilder: (l10n) => l10n.tileReadingDuration7Description,
          days: 7,
        );
}

class ReadingDurationLast30Tile extends _BaseReadingDurationTile {
  ReadingDurationLast30Tile()
      : super(
          type: StatisticsDashboardTileType.readingDurationLast30,
          titleBuilder: (l10n) => l10n.tileReadingDuration30Title,
          descriptionBuilder: (l10n) => l10n.tileReadingDuration30Description,
          days: 30,
        );
}

class _ReadingDurationTileBody extends StatelessWidget {
  const _ReadingDurationTileBody({required this.series});

  final ReadingDurationSeries series;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalLabel = convertSeconds(series.totalSeconds);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          totalLabel,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: BookReadingChart(
            cumulativeValues: series.cumulativeSeconds,
            dailySeconds: _dailyAmounts(series.cumulativeSeconds),
            dates: series.dates,
          ),
        ),
      ],
    );
  }

  List<int> _dailyAmounts(List<int> cumulative) {
    if (cumulative.isEmpty) return const [];
    final daily = <int>[];
    for (var i = 0; i < cumulative.length; i++) {
      if (i == 0) {
        daily.add(cumulative[i]);
      } else {
        final delta = cumulative[i] - cumulative[i - 1];
        daily.add(delta < 0 ? 0 : delta);
      }
    }
    return daily;
  }
}
