import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/notifications/push_deep_links.dart';
import 'package:safini/core/theme/app_theme.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/core/utils/task_schedule.dart';
import 'package:safini/features/models/domain/controllers/family_controller.dart';
import 'package:safini/features/models/domain/controllers/task_controller.dart';
import 'package:safini/features/parent/domain/models/parent_tasks_response_model.dart';
import 'package:safini/features/parent/domain/repositories/i_parent_task_repository.dart';
import 'package:safini/features/parent/presentation/cubit/home/home_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_cubit.dart';
import 'package:safini/features/parent/presentation/screens/tasks/parent_tasks_screen.dart';
import 'package:safini/features/parent/presentation/widgets/tasks/done_task_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Done used to be one flat list of every approved task, dated only in each
/// row's grey meta line, and tapping a row did nothing. Now it is split by day
/// like a chat, by child inside each day, and a row opens what was sent.
final _today = DateTime.now();
String _daysAgo(int days) =>
    dateOnlyIso(DateTime(_today.year, _today.month, _today.day - days));

Map<String, dynamic> _task(
  String id,
  String childId,
  int daysAgo, {
  String status = 'approved',
  String? note,
}) => {
  'id': id,
  'child_id': childId,
  'status': status,
  'title': id,
  'category': 'home',
  'coin_reward': 5,
  'proof_mode': 'text_image',
  'due_on': _daysAgo(daysAgo),
  'submission_note': ?note,
};

class _Repo extends Fake implements IParentTaskRepository {
  _Repo(this.byChild);

  final Map<String, List<Map<String, dynamic>>> byChild;
  final fetched = <String>[];

  @override
  Future<Either<Failure, ParentTasksResponseModel>> fetchTasks(
    String childId,
  ) async => Right(
    ParentTasksResponseModel(
      tasks: [
        for (final json in byChild[childId] ?? const [])
          ParentTaskInstanceModel.fromJson(json),
      ],
    ),
  );

  @override
  Future<Either<Failure, ParentTaskInstanceModel>> fetchTask(
    String taskId,
  ) async {
    fetched.add(taskId);
    final json = byChild.values
        .expand((tasks) => tasks)
        .firstWhere((task) => task['id'] == taskId);
    return Right(
      ParentTaskInstanceModel.fromJson({
        ...json,
        'review_note': 'Great job',
        'submitted_at': '2026-09-27T13:40:00Z',
        'reviewed_at': '2026-09-27T14:05:00Z',
        'reviewed_by_parent': {
          'user_id': 'parent-1',
          'display_name': 'Alex Smith',
        },
      }),
    );
  }
}

class _NoFamilyApi extends Fake implements FamilyController {}

class _NoTasks extends Fake implements TaskController {}

Future<(ParentHomeCubit, _Repo)> _pump(
  WidgetTester tester,
  Map<String, List<Map<String, dynamic>>> tasks,
) async {
  SharedPreferences.setMockInitialValues({
    'parent_family_cache': jsonEncode({
      'id': 'family',
      'children': [
        {'id': 'amir', 'nickname': 'Amir', 'coins_balance': 0},
        {'id': 'zilola', 'nickname': 'Zilola', 'coins_balance': 0},
      ],
    }),
  });
  final prefs = await SharedPreferences.getInstance();
  final family = ParentFamilyCubit(_NoFamilyApi(), prefs);
  final repo = _Repo(tasks);
  final cubit = ParentTasksCubit(repo, family, _NoTasks());
  final home = ParentHomeCubit(initialIndex: 1);
  addTearDown(() async {
    await cubit.close();
    await family.close();
    await home.close();
  });

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('en'),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: family),
          BlocProvider.value(value: cubit),
          BlocProvider.value(value: home),
        ],
        child: const Scaffold(body: ParentTasksScreen()),
      ),
    ),
  );
  await tester.runAsync(cubit.loadAllTasks);
  await tester.pumpAndSettle();
  await tester.tap(find.textContaining('Done'));
  await tester.pumpAndSettle();
  return (home, repo);
}

/// Top edge of each text, so order on screen can be compared.
double _y(WidgetTester tester, String text) =>
    tester.getTopLeft(find.text(text).first).dy;

void main() {
  setUp(() {
    if (getIt.isRegistered<PushDeepLinks>()) getIt.unregister<PushDeepLinks>();
    getIt.registerSingleton<PushDeepLinks>(PushDeepLinks());
  });

  tearDown(() => GetIt.I.reset());

  testWidgets('everyone: split by day, newest first, then by child', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pump(tester, {
      'amir': [
        _task('Bed today', 'amir', 0),
        _task('Dishes yesterday', 'amir', 1),
        _task('Still open', 'amir', 0, status: 'available'),
      ],
      'zilola': [
        _task('Reading today', 'zilola', 0),
        _task('Plants long ago', 'zilola', 30),
      ],
    });

    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('YESTERDAY'), findsOneWidget);
    // An open task never lands in the history.
    expect(find.text('Still open'), findsNothing);

    final today = _y(tester, 'TODAY');
    final yesterday = _y(tester, 'YESTERDAY');
    expect(today, lessThan(_y(tester, 'Bed today')));
    expect(_y(tester, 'Bed today'), lessThan(_y(tester, 'Reading today')));
    expect(_y(tester, 'Reading today'), lessThan(yesterday));
    expect(yesterday, lessThan(_y(tester, 'Dishes yesterday')));
    expect(
      _y(tester, 'Dishes yesterday'),
      lessThan(_y(tester, 'Plants long ago')),
    );

    // Today has both children, each under their own header.
    expect(find.text('Amir'), findsWidgets);
    expect(find.text('Zilola'), findsWidgets);
    expect(find.text('2 tasks · 10 coins'), findsOneWidget);
  });

  testWidgets('one child: days only, no child header inside', (tester) async {
    tester.view.physicalSize = const Size(402, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final (home, _) = await _pump(tester, {
      'amir': [
        _task('Bed today', 'amir', 0),
        _task('Dishes yesterday', 'amir', 1),
      ],
      'zilola': [_task('Reading today', 'zilola', 0)],
    });
    home.selectChild('amir');
    await tester.pumpAndSettle();

    expect(find.text('Reading today'), findsNothing);
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('YESTERDAY'), findsOneWidget);
    // The chip is the only "Amir" left: no group header repeats it.
    expect(find.text('Amir'), findsOneWidget);
  });

  testWidgets('tapping a done task shows the note and the parent reply', (
    tester,
  ) async {
    final (_, repo) = await _pump(tester, {
      'amir': [_task('Bed today', 'amir', 0, note: 'Made it with corners')],
    });

    await tester.tap(find.text('Bed today'));
    await tester.pumpAndSettle();

    expect(find.byType(DoneTaskSheet), findsOneWidget);
    expect(repo.fetched, ['Bed today']);
    expect(find.text('Made it with corners'), findsOneWidget);
    expect(find.text('Great job'), findsOneWidget);
    expect(find.text('Amir · paid 5 coins'), findsOneWidget);
    expect(find.text('Sent for approval'), findsOneWidget);
    expect(find.text('Approved by Alex Smith'), findsOneWidget);
    final sent = tester.getTopLeft(find.text('Sent for approval')).dy;
    final approved = tester.getTopLeft(find.text('Approved by Alex Smith')).dy;
    expect(sent, lessThan(approved));
  });
}
