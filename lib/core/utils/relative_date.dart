import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:safini/core/translation/generated/l10n.dart';

/// A date a person would say out loud, not an ISO string.
///
/// Task rows used to render `2026-08-23` in every language, including for
/// today's tasks, which is the great majority of them.
String relativeDateLabel(
  BuildContext context,
  S s,
  DateTime? date, {
  DateTime? now,
}) {
  if (date == null) return '';

  final today = _dateOnly(now ?? DateTime.now());
  final target = _dateOnly(date);
  final difference = target.difference(today).inDays;

  if (difference == 0) return s.dateToday;
  if (difference == 1) return s.dateTomorrow;
  if (difference == -1) return s.dateYesterday;

  final locale = Localizations.localeOf(context).toLanguageTag();
  // Inside a week either way, the weekday is more useful than the number.
  if (difference > 1 && difference < 7) {
    return DateFormat.EEEE(locale).format(target);
  }
  // Same year, so the year itself carries no information.
  if (target.year == today.year) {
    return DateFormat.MMMd(locale).format(target);
  }
  return DateFormat.yMMMd(locale).format(target);
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
