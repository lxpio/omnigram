import 'package:omnigram/providers/statictics_summary_value.dart';
import 'package:omnigram/widgets/common/async_skeleton_wrapper.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/dashboard_tile_base.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/dashboard_tile_metadata.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/dashboard_tile_registry.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/widgets/mini_metric.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReadingDaysTile extends StatisticsDashboardTileBase {
  const ReadingDaysTile();

  @override
  StatisticsDashboardTileMetadata get metadata {
    final l10n = l10nLocal;
    return StatisticsDashboardTileMetadata(
      type: StatisticsDashboardTileType.readingDaysTotal,
      title: l10n.tileReadingDaysTitle,
      description: l10n.tileReadingDaysDescription,
      columnSpan: 1,
      rowSpan: 1,
      icon: Icons.calendar_today_outlined,
    );
  }

  @override
  Widget buildContent(BuildContext context, WidgetRef ref) {
    final asyncValue =
        ref.watch(StaticticsSummaryValueProvider(StatisticType.totalDates));

    return AsyncSkeletonWrapper<int>(
      asyncValue: asyncValue,
      mock: 28,
      builder: (count, _) => DashboardMiniMetric(
        value: count,
        label: l10nLocal.tileReadingDaysUnit,
        icon: metadata.icon,
      ),
    );
  }
}
