import 'package:omnigram/utils/date/convert_seconds.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Shared line chart used for reading trend visualisations.
///
/// [cumulativeValues] drive the actual line path, while [dailySeconds] and
/// [dates] provide tooltip context.
class BookReadingChart extends StatefulWidget {
  const BookReadingChart({
    super.key,
    required this.cumulativeValues,
    required this.dailySeconds,
    required this.dates,
    this.maxY,
  });

  final List<int> cumulativeValues;
  final List<int> dailySeconds;
  final List<DateTime> dates;
  final double? maxY;

  @override
  State<BookReadingChart> createState() => _BookReadingChartState();
}

class _BookReadingChartState extends State<BookReadingChart> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final formatter = DateFormat('M/d');

    final dataLength = widget.cumulativeValues.length;
    final effectiveMaxY = widget.maxY ??
        (dataLength == 0
            ? 1
            : widget.cumulativeValues.reduce((a, b) => a > b ? a : b) * 1.2);

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.transparent,
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index >= 0 && index < dataLength) {
                  final label = formatter.format(widget.dates[index]);
                  final daily = widget.dailySeconds[index];
                  return LineTooltipItem(
                    '$label · ${convertSeconds(daily)}',
                    TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: dataLength > 0 ? (dataLength - 1).toDouble() : 0,
        minY: 0,
        maxY: effectiveMaxY <= 0 ? 1 : effectiveMaxY,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              dataLength,
              (index) => FlSpot(
                index.toDouble(),
                widget.cumulativeValues[index].toDouble(),
              ),
            ),
            isCurved: true,
            color: primaryColor,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  primaryColor.withAlpha(75),
                  primaryColor.withAlpha(0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
