import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/notifications/push_event.dart';
import 'package:safini/features/fini/demo/fini_demo.dart';
import 'package:safini/features/fini/demo/fini_demo_repository.dart';
import 'package:safini/features/fini/domain/fini_models.dart';
import 'package:safini/features/fini/presentation/cubit/fini_cubit.dart';

void main() {
  test('a report reads from the API and shows through the week after', () {
    final report = FiniReport.fromJson({
      'id': 'r',
      'week_start': '2026-10-12',
      'week_end': '2026-10-18',
      'bullets': ['8 tasks done.', '', 'Monday: 74 min.'],
    });
    expect(report.bullets, ['8 tasks done.', 'Monday: 74 min.']);
    expect(report.isCurrent(DateTime(2026, 10, 19)), isTrue);
    expect(report.isCurrent(DateTime(2026, 10, 27)), isFalse);
  });

  test('the Fini tab loads the latest report with the rest', () async {
    final cubit = FiniCubit(FiniDemoRepository(FiniDemoState.runningPlan));
    await cubit.load('amir');
    expect(cubit.state.latestReport(DateTime.now())?.bullets, hasLength(3));
    await cubit.close();
  });

  test('the report push opens Fini', () {
    expect(PushType.parse('fini_report'), PushType.finiReport);
  });
}
