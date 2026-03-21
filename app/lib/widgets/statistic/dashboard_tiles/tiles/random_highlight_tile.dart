import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/models/book_note.dart';
import 'package:omnigram/providers/random_highlight_provider.dart';
import 'package:omnigram/utils/date/relative_time_formatter.dart';
import 'package:omnigram/widgets/common/async_skeleton_wrapper.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/dashboard_tile_base.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/dashboard_tile_metadata.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/dashboard_tile_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RandomHighlightTile extends StatisticsDashboardTileBase {
  const RandomHighlightTile();

  @override
  StatisticsDashboardTileMetadata get metadata {
    final l10n = l10nLocal;
    return StatisticsDashboardTileMetadata(
      type: StatisticsDashboardTileType.randomHighlight,
      title: l10n.tileRandomHighlightTitle,
      description: l10n.tileRandomHighlightDescription,
      columnSpan: 2,
      rowSpan: 2,
      icon: Icons.format_quote,
    );
  }

  @override
  Widget buildCorner(BuildContext context, WidgetRef ref) {
    return cornerIcon(context, Icons.format_quote);
  }

  @override
  Widget buildContent(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(randomHighlightProvider);
    return AsyncSkeletonWrapper<RandomHighlightData?>(
      asyncValue: asyncValue,
      builder: (data, _) {
        if (data == null) {
          return _EmptyHighlight(
            onRefresh: () =>
                ref.read(randomHighlightProvider.notifier).refresh(),
          );
        }
        return _HighlightCard(
          data: data,
          onRefresh: () => ref.read(randomHighlightProvider.notifier).refresh(),
        );
      },
      mock: RandomHighlightData(
        note: BookNote(
          bookId: -1,
          content: 'Stay hungry, stay foolish.',
          cfi: '',
          chapter: 'Mock chapter',
          type: 'highlight',
          color: '000000',
          updateTime: DateTime.now(),
        ),
        book: null,
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.data,
    required this.onRefresh,
  });

  final RandomHighlightData data;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quote = data.note.content.trim();
    final timestamp = RelativeTimeFormatter.format(data.note.updateTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Text(
              quote,
              style: theme.textTheme.titleMedium,
            ),
          ),
        ),
        const Divider(height: 2),
        Text(
          data.book?.title ?? L10n.of(context).randomHighlightUnknownBook,
          style: theme.textTheme.labelLarge,
          overflow: TextOverflow.ellipsis,
        ),
        if (data.note.chapter.isNotEmpty)
          Text(
            data.note.chapter,
            style: theme.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        Row(
          children: [
            Expanded(
              child: Text(
                timestamp,
                style: theme.textTheme.bodySmall,
              ),
            ),
            IconButton(
              tooltip: L10n.of(context).commonRefresh,
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ],
    );
  }
}

class _EmptyHighlight extends StatelessWidget {
  const _EmptyHighlight({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.sticky_note_2_outlined, size: 32),
        const SizedBox(height: 8),
        Text(
          L10n.of(context).randomHighlightEmptyState,
          style: theme.textTheme.bodyMedium,
        ),
        TextButton.icon(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh),
          label: Text(L10n.of(context).commonRefresh),
        ),
      ],
    );
  }
}
