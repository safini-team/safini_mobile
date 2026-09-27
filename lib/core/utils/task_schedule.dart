import 'package:safini/features/parent/domain/models/parent_tasks_response_model.dart';

/// Weekday bitmask used by `weekly` recurrence: Mon=1, Tue=2, … Sun=64.
int weekdayBit(DateTime day) => 1 << (day.weekday - 1);

/// `YYYY-MM-DD` for the API `due_on` field.
String dateOnlyIso(DateTime day) {
  final month = day.month.toString().padLeft(2, '0');
  final date = day.day.toString().padLeft(2, '0');
  return '${day.year}-$month-$date';
}

/// First calendar day a `weekly` rule should run, including [now] when it
/// matches. `daily` / `none` omit `due_on` so the server uses family-local today.
///
/// Create otherwise defaults to today, which is why a Mon–Fri homework added
/// on Sunday still landed in Sunday's list.
String? firstDueOn({
  required String recurrence,
  required int recurrenceDays,
  DateTime? now,
}) {
  if (recurrence != 'weekly' || recurrenceDays == 0) return null;
  final start = now ?? DateTime.now();
  final today = DateTime(start.year, start.month, start.day);
  for (var offset = 0; offset < 7; offset++) {
    final day = today.add(Duration(days: offset));
    if (recurrenceDays & weekdayBit(day) != 0) return dateOnlyIso(day);
  }
  return null;
}

/// Whether a weekly mask includes [day]. Non-weekly rules always match.
bool weeklyOccursOn({
  required String recurrence,
  int? recurrenceDays,
  required DateTime day,
}) {
  if (recurrence != 'weekly') return true;
  final mask = recurrenceDays ?? 0;
  if (mask == 0) return true;
  return mask & weekdayBit(day) != 0;
}

/// Review and Done keep history; only an open weekly occurrence is hidden
/// when today is not one of its days.
bool taskStaysOnDayList(ParentTaskInstanceModel task, DateTime day) {
  if (task.isPendingApproval || task.isCompleted) return true;
  return weeklyOccursOn(
    recurrence: task.recurrence,
    recurrenceDays: task.recurrenceDays,
    day: day,
  );
}
