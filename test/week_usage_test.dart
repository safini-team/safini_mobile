import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/features/models/data/services/device_usage_service.dart';
import 'package:safini/features/models/domain/models/device_usage.dart';

/// A phone paired today already has a week of usage: Android kept it, and the
/// child's phone sends it once after pairing. "Last 7 days" on the parent's
/// Today reads it back one day at a time.
DeviceUsage _day(String date, Map<String, int> minutes) => DeviceUsage(
  usageDate: date,
  usageAvailable: true,
  totalMinutes: minutes.values.fold(0, (a, b) => a + b),
  apps: [
    for (final entry in minutes.entries)
      DeviceUsageApp(
        packageName: 'com.${entry.key.toLowerCase()}',
        displayName: entry.key,
        usedMinutes: entry.value,
      ),
  ],
);

void main() {
  test('sums each app over the week, most used first', () {
    final week = WeekUsage.fromDays([
      _day('2026-09-19', {'YouTube': 30, 'Roblox': 50}),
      _day('2026-09-20', {}),
      _day('2026-09-21', {'YouTube': 40}),
    ]);

    expect(week.days.map((day) => day.minutes), [80, 0, 40]);
    expect(week.days.first.date, DateTime(2026, 9, 19));
    expect(week.apps.map((app) => (app.displayName, app.usedMinutes)), [
      ('YouTube', 70),
      ('Roblox', 50),
    ]);
    expect(week.totalMinutes, 120);
    // Over the two days with any use, not three.
    expect(week.averageMinutes, 60);
  });

  test('reads one app\'s own week, zero on the days it was not opened', () {
    DeviceUsage day(String date, Map<String, int> minutes) => DeviceUsage(
      usageDate: date,
      usageAvailable: true,
      totalMinutes: minutes.values.fold(0, (a, b) => a + b),
      apps: [
        for (final e in minutes.entries)
          DeviceUsageApp(
            appSlug: e.key,
            displayName: e.key,
            usedMinutes: e.value,
          ),
      ],
    );
    final week = WeekUsage.fromDays([
      day('2026-09-19', {'youtube': 30, 'roblox': 50}),
      day('2026-09-20', {'roblox': 10}),
      day('2026-09-21', {'youtube': 40}),
    ]);

    expect(week.daysFor('youtube').map((d) => d.minutes), [30, 0, 40]);
    expect(week.daysFor('youtube').first.date, DateTime(2026, 9, 19));
    expect(week.daysFor('missing').map((d) => d.minutes), [0, 0, 0]);
    // A week built without per-day apps has nothing to read back.
    expect(
      WeekUsage(days: week.days, apps: week.apps).daysFor('youtube'),
      isEmpty,
    );
  });

  test('an empty week averages zero', () {
    final week = WeekUsage.fromDays([_day('2026-09-19', {})]);
    expect(week.averageMinutes, 0);
    expect(week.apps, isEmpty);
  });

  test('asks for the seven days before today, oldest first', () async {
    final asked = <String?>[];
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final date = options.queryParameters['usage_date'] as String?;
            asked.add(date);
            handler.resolve(
              Response(
                requestOptions: options,
                data: {
                  'usage_date': date,
                  'usage_available': true,
                  'total_minutes': 10,
                  'apps': [
                    {
                      'package_name': 'com.game',
                      'display_name': 'Game',
                      'used_minutes': 10,
                    },
                  ],
                },
              ),
            );
          },
        ),
      );

    final result = await DeviceUsageService(dio).fetchWeek('kid', '2026-03-02');
    final week = result.getOrElse(() => throw StateError('failed'));

    // Across a month end, and never today itself.
    expect(asked, [
      '2026-02-23',
      '2026-02-24',
      '2026-02-25',
      '2026-02-26',
      '2026-02-27',
      '2026-02-28',
      '2026-03-01',
    ]);
    expect(week.days.last.date, DateTime(2026, 3, 1));
    expect(week.apps.single.usedMinutes, 70);
  });

  test('one failed day fails the week rather than showing a hole', () async {
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) =>
              options.queryParameters['usage_date'] == '2026-09-22'
              ? handler.reject(
                  DioException(requestOptions: options, message: 'offline'),
                )
              : handler.resolve(
                  Response(requestOptions: options, data: {'apps': []}),
                ),
        ),
      );

    final result = await DeviceUsageService(dio).fetchWeek('kid', '2026-09-26');
    expect(result.isLeft(), isTrue);
  });
}
