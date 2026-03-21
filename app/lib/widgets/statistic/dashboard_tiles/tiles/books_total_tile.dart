import 'package:omnigram/providers/statictics_summary_value.dart';
import 'package:omnigram/widgets/common/async_skeleton_wrapper.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/dashboard_tile_base.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/dashboard_tile_metadata.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/dashboard_tile_registry.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/widgets/mini_metric.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BooksTotalTile extends StatisticsDashboardTileBase {
  const BooksTotalTile();

  @override
  StatisticsDashboardTileMetadata get metadata {
    final l10n = l10nLocal;
    return StatisticsDashboardTileMetadata(
      type: StatisticsDashboardTileType.booksTotal,
      title: l10n.tileBooksReadTitle,
      description: l10n.tileBooksReadDescription,
      columnSpan: 1,
      rowSpan: 1,
      icon: Icons.auto_stories_outlined,
    );
  }

  @override
  Widget buildContent(BuildContext context, WidgetRef ref) {
    final asyncValue =
        ref.watch(StaticticsSummaryValueProvider(StatisticType.totalBooks));

    return AsyncSkeletonWrapper<int>(
        asyncValue: asyncValue,
        mock: 12,
        builder: (count, _) {
          return DashboardMiniMetric(
            value: count,
            label: l10nLocal.tileBooksReadUnit,
            icon: metadata.icon,
          );
        });
  }
}
