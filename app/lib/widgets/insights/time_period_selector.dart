import 'package:flutter/material.dart';
import 'package:omnigram/l10n/generated/L10n.dart';

enum TimePeriod { thisMonth, lastMonth, thisYear, allTime }

class TimePeriodSelector extends StatelessWidget {
  final TimePeriod selected;
  final ValueChanged<TimePeriod> onChanged;

  const TimePeriodSelector({super.key, required this.selected, required this.onChanged});

  String _label(BuildContext context, TimePeriod p) {
    switch (p) {
      case TimePeriod.thisMonth:
        return L10n.of(context).timePeriodThisMonth;
      case TimePeriod.lastMonth:
        return L10n.of(context).timePeriodLastMonth;
      case TimePeriod.thisYear:
        return L10n.of(context).timePeriodThisYear;
      case TimePeriod.allTime:
        return L10n.of(context).timePeriodAll;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TimePeriod>(
      segments: TimePeriod.values.map((p) => ButtonSegment(value: p, label: Text(_label(context, p)))).toList(),
      selected: {selected},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}
