import 'package:omnigram/enums/chart_mode.dart';
import 'package:omnigram/models/book.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'statistic_data_model.freezed.dart';

@freezed
abstract class StatisticDataModel with _$StatisticDataModel {
  const factory StatisticDataModel(
      {required ChartMode mode,
      required bool isSelectingDay,
      required DateTime date,
      required List<int> readingTime,
      required List<String> xLabels,
      required List<Map<Book, int>> bookReadingTime}) = _StatisticDataModel;

  factory StatisticDataModel.mock() => StatisticDataModel(
        mode: ChartMode.month,
        isSelectingDay: false,
        date: DateTime.now(),
        readingTime: [],
        xLabels: [],
        bookReadingTime: [],
      );
}
