import 'package:flutter/material.dart';

enum TimePeriod { thisMonth, lastMonth, thisYear, allTime }

class TimePeriodSelector extends StatelessWidget {
  final TimePeriod selected;
  final ValueChanged<TimePeriod> onChanged;

  const TimePeriodSelector({super.key, required this.selected, required this.onChanged});

  String _label(TimePeriod p) {
    switch (p) {
      case TimePeriod.thisMonth:
        return '本月';
      case TimePeriod.lastMonth:
        return '上月';
      case TimePeriod.thisYear:
        return '今年';
      case TimePeriod.allTime:
        return '全部';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TimePeriod>(
      segments: TimePeriod.values.map((p) => ButtonSegment(value: p, label: Text(_label(p)))).toList(),
      selected: {selected},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}
