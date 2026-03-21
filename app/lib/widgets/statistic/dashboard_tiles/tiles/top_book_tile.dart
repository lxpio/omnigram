import 'package:omnigram/models/statistic_data_model.dart';
import 'package:omnigram/providers/book_daily_reading_provider.dart';
import 'package:omnigram/providers/statistic_data.dart';
import 'package:omnigram/utils/date/convert_seconds.dart';
import 'package:omnigram/widgets/bookshelf/book_cover.dart';
import 'package:omnigram/widgets/common/async_skeleton_wrapper.dart';
import 'package:omnigram/widgets/statistic/book_reading_chart.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/dashboard_tile_base.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/dashboard_tile_metadata.dart';
import 'package:omnigram/widgets/statistic/dashboard_tiles/dashboard_tile_registry.dart';
import 'package:omnigram/widgets/tips/statistic_tips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TopBookTile extends StatisticsDashboardTileBase {
  const TopBookTile();

  @override
  get metadata => StatisticsDashboardTileMetadata(
        type: StatisticsDashboardTileType.topBook,
        title: l10nLocal.tileTopBookTitle,
        description: l10nLocal.tileTopBookDescription,
        columnSpan: 4,
        rowSpan: 2,
        icon: Icons.bookmark_added_outlined,
      );

  @override
  Widget buildCorner(BuildContext context, WidgetRef ref) {
    return cornerIcon(context, Icons.favorite);
  }

  @override
  Widget buildContent(
    BuildContext context,
    WidgetRef ref,
  ) {
    return AsyncSkeletonWrapper(
      asyncValue: ref.watch(statisticDataProvider),
      mock: StatisticDataModel.mock(),
      builder: (statisticData, _) {
        if (statisticData.bookReadingTime.isEmpty) {
          return Center(child: FittedBox(child: StatisticsTips()));
        }
        final entry = statisticData.bookReadingTime.first;
        final book = entry.keys.first;
        final seconds = entry.values.first;

        final TextStyle bookTitleStyle = const TextStyle(
          fontSize: 20,
          fontFamily: 'SourceHanSerif',
          fontWeight: FontWeight.bold,
          overflow: TextOverflow.ellipsis,
        );
        final TextStyle bookAuthorStyle = const TextStyle(
          fontSize: 12,
          color: Colors.grey,
          overflow: TextOverflow.ellipsis,
        );
        final TextStyle bookReadingTimeStyle = const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        );

        return Row(
          children: [
            BookCover(
              book: book,
              width: 120,
              radius: 10,
            ),
            const SizedBox(width: 15),
            Flexible(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(book.title, style: bookTitleStyle),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(book.author, style: bookAuthorStyle),
                        ),
                        Text(
                            // getReadingTime(context),
                            convertSeconds(seconds),
                            textAlign: TextAlign.end,
                            style: bookReadingTimeStyle),
                      ],
                    ),
                    const SizedBox(height: 10),
                    AsyncSkeletonWrapper(
                        asyncValue: ref.watch(
                          bookDailyReadingProvider(bookId: book.id),
                        ),
                        mock: BookDailyReadingData.mock(),
                        builder: (bookReadingData, ready) {
                          return ready
                              ? Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: BookReadingChart(
                                      cumulativeValues:
                                          bookReadingData.readingTimes,
                                      dailySeconds:
                                          bookReadingData.readingTimes,
                                      dates: bookReadingData.dates,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink();
                        }),
                  ]),
            ),
          ],
        );
      },
    );
  }
}
