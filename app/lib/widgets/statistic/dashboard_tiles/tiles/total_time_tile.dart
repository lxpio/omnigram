import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/dashboard_tile_registry.dart';
import 'package:omnigram/providers/total_reading_time.dart';
import 'package:omnigram/widgets/common/async_skeleton_wrapper.dart';
import 'package:omnigram/widgets/highlight_digit.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/dashboard_tile_base.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/dashboard_tile_metadata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TotalTimeTile extends StatisticsDashboardTileBase {
  const TotalTimeTile();

  @override
  get metadata => StatisticsDashboardTileMetadata(
        type: StatisticsDashboardTileType.totalTime,
        title: l10nLocal.tileTotalTimeTitle,
        description: l10nLocal.tileTotalTimeDescription,
        columnSpan: 2,
        rowSpan: 1,
        icon: Icons.timer_outlined,
      );

  @override
  Widget buildCorner(BuildContext context, WidgetRef ref) {
    return cornerIcon(context, metadata.icon);
  }

  @override
  String get title => metadata.title;

  @override
  Widget buildContent(
    BuildContext context,
    WidgetRef ref,
  ) {
    final totalReadingTime = ref.watch(totalReadingTimeProvider);

    return AsyncSkeletonWrapper<int>(
      asyncValue: totalReadingTime,
      builder: (seconds, _) => _TotalTimeContent(
        seconds: seconds,
        metadata: metadata,
      ),
    );
  }
}

class _TotalTimeContent extends StatelessWidget {
  const _TotalTimeContent({
    required this.seconds,
    required this.metadata,
  });

  final int seconds;
  final StatisticsDashboardTileMetadata metadata;

  @override
  Widget build(BuildContext context) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          children: [
            highlightDigit(
              context,
              L10n.of(context).commonHours(hours),
              Theme.of(context).textTheme.bodyLarge!,
              Theme.of(context).textTheme.titleMedium!,
            ),
            highlightDigit(
              context,
              L10n.of(context).commonMinutes(minutes),
              Theme.of(context).textTheme.bodyLarge!,
              Theme.of(context).textTheme.titleMedium!,
            ),
          ],
        ),
        Text(
          '${Prefs().beginDate?.toString().substring(0, 10) ?? ''} '
          '${L10n.of(context).statisticToPresent}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
