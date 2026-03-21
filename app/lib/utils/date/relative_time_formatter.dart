import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/main.dart';

class RelativeTimeFormatter {
  const RelativeTimeFormatter._();

  static L10n get _l10n => L10n.of(navigatorKey.currentContext!);

  static String format(DateTime? timestamp) {
    final l10n = _l10n;
    if (timestamp == null) return '--';

    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inSeconds < 60) return l10n.relativeTimeJustNow;
    if (diff.inMinutes < 60) {
      return l10n.relativeTimeMinutesAgo(diff.inMinutes);
    }
    if (diff.inHours < 24) {
      return l10n.relativeTimeHoursAgo(diff.inHours);
    }
    if (diff.inDays == 1) return l10n.relativeTimeYesterday;
    if (diff.inDays < 30) {
      return l10n.relativeTimeDaysAgo(diff.inDays);
    }
    if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return months <= 1
          ? l10n.relativeTimeLastMonth
          : l10n.relativeTimeMonthsAgo(months);
    }
    final years = (diff.inDays / 365).floor();
    return years <= 1
        ? l10n.relativeTimeLastYear
        : l10n.relativeTimeYearsAgo(years);
  }
}
