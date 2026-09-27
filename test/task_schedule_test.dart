import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/utils/task_schedule.dart';
import 'package:safini/features/parent/domain/models/parent_tasks_response_model.dart';
import 'package:safini/features/parent/domain/models/task_idea.dart';

ParentTaskInstanceModel _task({
  required String status,
  String recurrence = 'none',
  int? recurrenceDays,
}) {
  return ParentTaskInstanceModel(
    id: 't1',
    status: status,
    title: 'Do homework',
    recurrence: recurrence,
    recurrenceDays: recurrenceDays,
  );
}

void main() {
  final sunday = DateTime(2026, 9, 27);
  final monday = DateTime(2026, 9, 28);
  final saturday = DateTime(2026, 9, 26);

  test('Sunday is not a school day in the weekday mask', () {
    expect(sunday.weekday, DateTime.sunday);
    expect(TaskIdea.weekdays & weekdayBit(sunday), 0);
    expect(TaskIdea.weekdays & weekdayBit(monday), isNonZero);
  });

  test('a school-days rule created on Sunday is first due Monday', () {
    expect(
      firstDueOn(
        recurrence: 'weekly',
        recurrenceDays: TaskIdea.weekdays,
        now: sunday,
      ),
      '2026-09-28',
    );
  });

  test('a school-days rule created on Monday stays due that day', () {
    expect(
      firstDueOn(
        recurrence: 'weekly',
        recurrenceDays: TaskIdea.weekdays,
        now: monday,
      ),
      '2026-09-28',
    );
  });

  test('daily and once tasks do not send due_on', () {
    expect(
      firstDueOn(recurrence: 'daily', recurrenceDays: TaskIdea.weekdays),
      isNull,
    );
    expect(firstDueOn(recurrence: 'none', recurrenceDays: 0), isNull);
  });

  test('an open school-days task is hidden on Sunday', () {
    final homework = _task(
      status: 'available',
      recurrence: 'weekly',
      recurrenceDays: TaskIdea.weekdays,
    );
    expect(taskStaysOnDayList(homework, sunday), isFalse);
    expect(taskStaysOnDayList(homework, monday), isTrue);
  });

  test('review and done school-days tasks stay visible on Sunday', () {
    final submitted = _task(
      status: 'submitted',
      recurrence: 'weekly',
      recurrenceDays: TaskIdea.weekdays,
    );
    final done = _task(
      status: 'approved',
      recurrence: 'weekly',
      recurrenceDays: TaskIdea.weekdays,
    );
    expect(taskStaysOnDayList(submitted, sunday), isTrue);
    expect(taskStaysOnDayList(done, sunday), isTrue);
  });

  test('Saturday-only laundry stays off the Sunday list', () {
    final laundry = _task(
      status: 'available',
      recurrence: 'weekly',
      recurrenceDays: TaskIdea.saturday,
    );
    expect(taskStaysOnDayList(laundry, saturday), isTrue);
    expect(taskStaysOnDayList(laundry, sunday), isFalse);
  });
}
