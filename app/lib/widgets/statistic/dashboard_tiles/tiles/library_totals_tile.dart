import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/providers/statictics_summary_value.dart';
import 'package:omnigram/widgets/common/async_skeleton_wrapper.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/dashboard_tile_base.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/dashboard_tile_metadata.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/dashboard_tile_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryTotalsTile extends StatisticsDashboardTileBase {
  const LibraryTotalsTile();

  @override
  StatisticsDashboardTileMetadata get metadata {
    final l10n = l10nLocal;
    return StatisticsDashboardTileMetadata(
      type: StatisticsDashboardTileType.libraryTotals,
      title: l10n.tileLibraryTotalsTitle,
      description: l10n.tileLibraryTotalsDescription,
      columnSpan: 4,
      rowSpan: 1,
      icon: Icons.menu_book_outlined,
    );
  }

  @override
  Widget buildContent(
    BuildContext context,
    WidgetRef ref,
  ) {
    final l10n = L10n.of(context);

    return AsyncSkeletonWrapper<List>(
        asyncValue: combineAsyncValues([
          ref.watch(StaticticsSummaryValueProvider(StatisticType.totalBooks)),
          ref.watch(StaticticsSummaryValueProvider(StatisticType.totalDates)),
          ref.watch(StaticticsSummaryValueProvider(StatisticType.totalNotes)),
        ]),
        mock: [0, 0, 0],
        builder: (data, _) {
          final booksRead = data[0] as int;
          final daysOfReading = data[1] as int;
          final notesCount = data[2] as int;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _NumberTile(
                  icon: Icons.auto_stories,
                  label: l10n.statisticBooksRead(booksRead),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NumberTile(
                  icon: Icons.calendar_today,
                  label: l10n.statisticDaysOfReading(daysOfReading),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NumberTile(
                  icon: Icons.note_alt_outlined,
                  label: l10n.statisticNotes(notesCount),
                ),
              ),
            ],
          );
        });
  }
}

class _NumberTile extends StatelessWidget {
  const _NumberTile({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
