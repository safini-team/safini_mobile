import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/theme/app_theme.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/task_category.dart';
import 'package:safini/design_preview_data.dart';
import 'package:safini/features/models/data/dto/task_dto.dart';
import 'package:safini/features/models/domain/models/family_model.dart';
import 'package:safini/features/models/domain/models/task_model.dart';
import 'package:safini/features/models/domain/models/task_voice.dart';
import 'package:safini/features/parent/domain/models/parent_tasks_response_model.dart';
import 'package:safini/features/parent/domain/models/task_idea.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_state.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_state.dart';
import 'package:safini/features/parent/presentation/screens/tasks/parent_tasks_view.dart';
import 'package:safini/features/parent/presentation/widgets/tasks/task_sheet.dart';

/// A new child used to arrive with four English tasks the API made for them.
/// Now the parent's empty list offers ideas, and nothing exists until the
/// parent adds one from the New Task sheet.

Map<String, dynamic> _fromIdea(TaskIdea idea) => {
  'emoji': idea.emoji,
  TaskIdea.metadataKey: idea.key,
};

class _Family extends Fake implements ParentFamilyCubit {
  @override
  ParentFamilyState get state => ParentFamilyState.initial(
    family: FamilyModel.fromJson({
      'id': 'family',
      'children': [
        {'id': 'amir', 'nickname': 'Amir'},
      ],
    }),
  );

  @override
  Stream<ParentFamilyState> get stream => const Stream.empty();
}

class _Tasks extends Fake implements ParentTasksCubit {
  final created = <TaskCreateRequestDto>[];
  final updated = <TaskUpdateRequestDto>[];
  final voices = <TaskVoiceSave>[];
  final _states = StreamController<ParentTasksState>.broadcast();

  @override
  ParentTasksState get state =>
      const ParentTasksLoaded(childId: 'amir', childName: 'Amir', tasks: []);

  @override
  Stream<ParentTasksState> get stream => _states.stream;

  @override
  Future<void> createTaskForChildren(
    List<String> childIds,
    TaskCreateRequestDto request, {
    TaskVoiceSave voice = TaskVoiceSave.unchanged,
  }) async {
    created.add(request);
    voices.add(voice);
  }

  @override
  Future<void> updateTask(
    String taskId,
    TaskUpdateRequestDto request, {
    String? childId,
    TaskVoiceSave voice = TaskVoiceSave.unchanged,
  }) async {
    updated.add(request);
    voices.add(voice);
  }
}

Widget _host(Widget child, {String locale = 'en'}) => MaterialApp(
  theme: AppTheme.light,
  locale: Locale(locale),
  localizationsDelegates: const [
    S.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: S.delegate.supportedLocales,
  home: Builder(builder: (context) => child),
);

Future<_Tasks> _pumpSheet(
  WidgetTester tester, {
  TaskIdea? idea,
  TaskModel? task,
  String locale = 'en',
  TaskVoiceCapture? voiceCapture,
  TaskVoicePlayback? voicePlayback,
}) async {
  tester.view
    ..physicalSize = const Size(402, 1400) * 3
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final tasks = _Tasks();
  await tester.pumpWidget(
    _host(
      MultiBlocProvider(
        providers: [
          BlocProvider<ParentFamilyCubit>.value(value: _Family()),
          BlocProvider<ParentTasksCubit>.value(value: tasks),
        ],
        child: Scaffold(
          body: SingleChildScrollView(
            child: TaskSheet(
              childId: 'amir',
              idea: idea,
              task: task,
              voiceCapture: voiceCapture,
              voicePlayback: voicePlayback,
            ),
          ),
        ),
      ),
      locale: locale,
    ),
  );
  await tester.pump();
  return tasks;
}

String _field(WidgetTester tester, int index) =>
    tester.widget<TextField>(find.byType(TextField).at(index)).controller!.text;

Widget _view(ParentTasksData data, {ValueChanged<TaskIdea>? onOpenIdea}) =>
    ParentTasksView(
      data: data,
      onSelectScope: (_) {},
      onSelectLane: (_) {},
      onOpenTask: (_) {},
      onNewTask: () {},
      onOpenIdea: onOpenIdea ?? (_) {},
    );

void main() {
  group('which ideas are on offer', () {
    test('all four, in order, on an empty list', () {
      expect(TaskIdea.offeredAlongside(const []), [
        TaskIdea.duolingo,
        TaskIdea.steps,
        TaskIdea.nap,
        TaskIdea.brushTeeth,
      ]);
    });

    test('the rest, while every task came from an idea', () {
      // A daily idea comes back each day as an instance with the same metadata.
      final offered = TaskIdea.offeredAlongside([
        _fromIdea(TaskIdea.brushTeeth),
        _fromIdea(TaskIdea.brushTeeth),
        _fromIdea(TaskIdea.steps),
      ]);
      expect(offered, [TaskIdea.duolingo, TaskIdea.nap]);
    });

    test('none once the parent has made a task of their own', () {
      expect(
        TaskIdea.offeredAlongside([
          _fromIdea(TaskIdea.brushTeeth),
          {'emoji': '🧹'},
        ]),
        isEmpty,
      );
    });

    test('none next to the tasks the API used to create', () {
      // The old starter tasks carry `{"source": "seed"}` and no emoji.
      expect(
        TaskIdea.offeredAlongside([
          {'source': 'seed'},
          null,
        ]),
        isEmpty,
      );
    });

    test('none once all four are on the list', () {
      expect(
        TaskIdea.offeredAlongside(TaskIdea.values.map(_fromIdea)),
        isEmpty,
      );
    });

    test('reads the idea back off a task the API returns', () {
      final task = ParentTaskInstanceModel.fromJson({
        'id': 't1',
        'status': 'available',
        'metadata': {'emoji': '🦉', 'idea': 'duolingo'},
      });
      expect(TaskIdea.fromMetadata(task.metadata), TaskIdea.duolingo);
    });
  });

  test('every idea repeats daily and only brushing teeth needs a photo', () {
    expect(TaskIdea.recurrence, 'daily');
    expect(TaskIdea.values.where((idea) => idea.photoProof), [
      TaskIdea.brushTeeth,
    ]);
    expect(TaskIdea.brushTeeth.coins, 10);
    expect(TaskIdea.brushTeeth.category, TaskCategory.health);
  });

  group('the Tasks list', () {
    testWidgets('an empty list shows the ideas instead of the empty card', (
      tester,
    ) async {
      TaskIdea? opened;
      await tester.pumpWidget(
        _host(
          Builder(
            builder: (context) => _view(
              SampleData.parentTasksFirstRun(S.of(context)),
              onOpenIdea: (idea) => opened = idea,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('No tasks yet'), findsOneWidget);
      expect(find.text('No active tasks'), findsNothing);
      expect(find.text('Complete a Duolingo lesson'), findsOneWidget);
      expect(find.text('Walk 5,000 steps'), findsOneWidget);
      expect(find.text('Nap for 2 hours'), findsOneWidget);
      expect(find.text('Brush teeth in the morning'), findsOneWidget);
      expect(find.text('Daily · Needs photo proof'), findsOneWidget);

      await tester.tap(find.text('Brush teeth in the morning'));
      expect(opened, TaskIdea.brushTeeth);
    });

    testWidgets('the rest stay under the active tasks as "More ideas"', (
      tester,
    ) async {
      ParentTasksData withTeeth(S s, TaskLane lane) => ParentTasksData(
        scopeLine: '',
        chips: const [],
        selectedScope: 'all',
        laneCounts: const {
          TaskLane.review: 0,
          TaskLane.active: 1,
          TaskLane.done: 0,
        },
        lane: lane,
        emptyTitle: s.emptyNothingPaidYet,
        emptyBody: s.emptyDoneBody,
        groups: lane == TaskLane.active
            ? [
                TaskGroupData(
                  name: 'Amir',
                  color: Colors.green,
                  summary: '',
                  rows: [
                    TaskRowData(
                      id: 't1',
                      title: TaskIdea.brushTeeth.title(s),
                      meta: '',
                      emoji: TaskIdea.brushTeeth.emoji,
                      lane: TaskLane.active,
                      coins: 10,
                      childName: 'Amir',
                    ),
                  ],
                ),
              ]
            : const [],
        ideas: [
          for (final idea in TaskIdea.offeredAlongside([
            _fromIdea(TaskIdea.brushTeeth),
          ]))
            TaskIdeaRowData.of(idea, s),
        ],
      );

      await tester.pumpWidget(
        _host(
          Builder(
            builder: (context) =>
                _view(withTeeth(S.of(context), TaskLane.active)),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('More ideas'), findsOneWidget);
      expect(find.text('No tasks yet'), findsNothing);
      expect(find.text('Complete a Duolingo lesson'), findsOneWidget);
      // Once on the list, and not offered again.
      expect(find.text('Brush teeth in the morning'), findsOneWidget);

      await tester.pumpWidget(
        _host(
          Builder(
            builder: (context) =>
                _view(withTeeth(S.of(context), TaskLane.done)),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('More ideas'), findsNothing);
      expect(find.text('Nothing paid yet'), findsOneWidget);
    });
  });

  group('the New Task sheet', () {
    testWidgets('an idea fills it in, in the parent\'s language', (
      tester,
    ) async {
      await _pumpSheet(tester, idea: TaskIdea.brushTeeth, locale: 'ru');

      expect(_field(tester, 0), 'Почистить зубы утром');
      expect(
        _field(tester, 1),
        'Почисти зубы две минуты после сна и пришли фото.',
      );
      expect(find.text('10 монет'), findsOneWidget);
      expect(find.text('Новое задание'), findsOneWidget);
    });

    testWidgets('adding it saves a daily task that remembers the idea', (
      tester,
    ) async {
      final tasks = await _pumpSheet(tester, idea: TaskIdea.brushTeeth);
      expect(tasks.created, isEmpty);

      await tester.tap(find.text("Add to Amir's list"));
      await tester.pump();

      expect(tasks.created, hasLength(1));
      final json = tasks.created.single.toJson();
      expect(json['title'], 'Brush teeth in the morning');
      expect(
        json['description'],
        'Brush for two minutes after you wake up, then send a photo.',
      );
      expect(json['category'], 'health');
      expect(json['recurrence'], 'daily');
      expect(json['proof_mode'], 'text_image');
      expect(json['coin_reward'], 10);
      expect(json['metadata'], {'emoji': '🦷', 'idea': 'brush-teeth'});
    });

    testWidgets('an idea without a photo sends no proof', (tester) async {
      final tasks = await _pumpSheet(tester, idea: TaskIdea.steps);
      await tester.tap(find.text("Add to Amir's list"));
      await tester.pump();

      final json = tasks.created.single.toJson();
      expect(json['proof_mode'], 'none');
      expect(json['coin_reward'], 20);
      expect(json['metadata'], {'emoji': '👟', 'idea': 'steps'});
    });

    testWidgets('a blank New Task stays blank and names no idea', (
      tester,
    ) async {
      final tasks = await _pumpSheet(tester);
      expect(_field(tester, 0), isEmpty);

      await tester.enterText(find.byType(TextField).first, 'Water the plants');
      await tester.pump();
      await tester.tap(find.text("Add to Amir's list"));
      await tester.pump();

      final json = tasks.created.single.toJson();
      expect(json['recurrence'], 'none');
      expect((json['metadata'] as Map).containsKey('idea'), isFalse);
    });

    testWidgets('changing the icon later keeps the idea it came from', (
      tester,
    ) async {
      // The server replaces metadata whole, so an emoji-only patch would drop
      // the idea and put it back on offer.
      final tasks = await _pumpSheet(
        tester,
        task: TaskModel(
          id: 't1',
          title: 'Brush teeth in the morning',
          category: 'health',
          coinReward: 10,
          xpReward: 10,
          recurrence: 'daily',
          metadata: _fromIdea(TaskIdea.brushTeeth),
        ),
      );

      await tester.tap(find.text('🧹'));
      await tester.pump();
      await tester.tap(find.text('Save Changes'));
      await tester.pump();

      expect(tasks.updated.single.toJson()['metadata'], {
        'emoji': '🧹',
        'idea': 'brush-teeth',
      });
    });

    testWidgets('the sheet offers a voice instruction control', (tester) async {
      await _pumpSheet(tester);
      expect(find.text('Record a voice instruction'), findsOneWidget);
    });

    testWidgets('a voice-only task omits the text description', (tester) async {
      final capture = _GrantedCapture();
      final playback = _SilentPlayback();
      final tasks = await _pumpSheet(
        tester,
        voiceCapture: capture,
        voicePlayback: playback,
      );

      await tester.enterText(find.byType(TextField).first, 'Clean your room');
      await tester.pump();
      await tester.tap(find.text('Record a voice instruction'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Stop'));
      await tester.pump();

      await tester.tap(find.text("Add to Amir's list"));
      await tester.pump();

      expect(tasks.created, hasLength(1));
      expect(tasks.created.single.toJson().containsKey('description'), isFalse);
      expect(tasks.voices.single.attach, isNotNull);
      expect(tasks.voices.single.attach!.durationMs, greaterThanOrEqualTo(400));
    });

    testWidgets('a denied microphone is explained, not silent', (tester) async {
      await _pumpSheet(tester, voiceCapture: _DeniedCapture());
      await tester.tap(find.text('Record a voice instruction'));
      await tester.pump();
      expect(
        find.text(
          'Microphone is off. Turn it on in Settings to record a voice instruction.',
        ),
        findsOneWidget,
      );
    });
  });
}

class _GrantedCapture implements TaskVoiceCapture {
  String? path;

  @override
  Future<bool> hasMicPermission() async => true;

  @override
  Future<void> startRecording(String path) async {
    this.path = path;
    await File(path).writeAsBytes(const [1, 2, 3, 4]);
  }

  @override
  Future<String?> stopRecording() async => path;

  @override
  Future<void> dispose() async {}
}

class _DeniedCapture implements TaskVoiceCapture {
  @override
  Future<bool> hasMicPermission() async => false;

  @override
  Future<void> startRecording(String path) async {}

  @override
  Future<String?> stopRecording() async => null;

  @override
  Future<void> dispose() async {}
}

class _SilentPlayback implements TaskVoicePlayback {
  @override
  Stream<bool> get playing => const Stream.empty();

  @override
  Future<void> playFile(String path) async {}

  @override
  Future<void> playUrl(String url) async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}
