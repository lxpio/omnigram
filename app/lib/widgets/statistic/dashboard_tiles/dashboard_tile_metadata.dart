import 'package:omnigram/widgets/statistic/dashboard_tiles/dashboard_tile_registry.dart';
import 'package:flutter/material.dart';

class StatisticsDashboardTileMetadata {
  const StatisticsDashboardTileMetadata({
    required this.type,
    required this.title,
    required this.description,
    required this.columnSpan,
    required this.rowSpan,
    required this.icon,
  });

  final StatisticsDashboardTileType type;
  final String title;
  final String description;
  final int columnSpan;
  final int rowSpan;
  final IconData icon;
}
