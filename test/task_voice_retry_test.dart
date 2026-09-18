import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/theme/app_theme.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/models/data/dto/task_dto.dart';
import 'package:safini/features/models/domain/controllers/task_controller.dart';
import 'package:safini/features/models/domain/models/family_model.dart';
import 'package:safini/features/models/domain/models/task_model.dart';
import 'package:safini/features/models/domain/models/task_voice.dart';
import 'package:safini/features/parent/domain/models/parent_tasks_response_model.dart';
import 'package:safini/features/parent/domain/repositories/i_parent_task_repository.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_state.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_state.dart';
import 'package:safini/features/parent/presentation/widgets/tasks/task_voice_recorder.dart';

// SAF-172 retries: a task created for several children whose voice note
// fails for one of them must retry that child's attach only, against that
// child; and a re-record must never leave Save pointing at a deleted take.

ChildSummaryModel _child(String id) =>
    ChildSummaryModel(id: id, nickname: id, age: 8, coinsBalance: 0, level: 1);

class _Repository extends Fake implements IParentTaskRepository {
  @override
  Future<Either<Failure, ParentTasksResponseModel>> fetchTasks(
    String childId,
  ) async => const Right(ParentTasksResponseModel(tasks: []));
}

class _Family extends Fake implements ParentFamilyCubit {
  @override
  ParentFamilyState get state => ParentFamilyState(
    stage: ParentFamilyStage.dashboard,
    isLoading: false,
    family: FamilyModel(
      id: 'family',
      ownerUserId: 'parent',
      name: 'Family',
      timezone: 'UTC',
      parents: const [],
      children: [_child('kid-a'), _child('kid-b'), _child('kid-c')],
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    ),
  );
}

class _Tasks extends Fake implements TaskController {
  final Set<String> failVoiceFor = {};
  final created = <String>[];
  final attaches = <TaskVoiceTarget>[];

  @override
  Future<Either<Failure, TaskModel>> createTask(
    String childId,
    TaskCreateRequestDto request,
  ) async {
    created.add(childId);
    return Right(
      TaskModel(
        id: 'task-$childId',
        title: request.title,
        coinReward: request.coinReward,
        xpReward: request.xpReward,
      ),
    );
  }

  @override
  Future<Either<Failure, TaskModel>> attachVoiceFromFile({
    required String childId,
    required String taskId,
    required TaskVoiceDraft draft,
  }) async {
    attaches.add((childId: childId, taskId: taskId));
    if (failVoiceFor.contains(childId)) {
      return const Left(ServerFailure('Could not upload the voice note.'));
    }
    return Right(TaskModel(id: taskId, title: '', coinReward: 0, xpReward: 0));
  }
}

const _request = TaskCreateRequestDto(
  title: 'Feed the cat',
  category: 'home',
  taskType: 'custom',
  proofMode: 'none',
  verificationMode: 'parent_approval',
  coinReward: 15,
  xpReward: 15,
);

final _voice = TaskVoiceSave.file(
  const TaskVoiceDraft(filePath: '/tmp/take.m4a', durationMs: 4200),
);

class _Capture implements TaskVoiceCapture {
  bool failStart = false;
  String? _path;

  @override
  Future<bool> hasMicPermission() async => true;

  @override
  Future<void> startRecording(String path) async {
    if (failStart) throw Exception('microphone busy');
    _path = path;
  }

  @override
  Future<String?> stopRecording() async => _path;

  @override
  Future<void> dispose() async {}
}

class _Playback implements TaskVoicePlayback {
  final _playing = StreamController<bool>.broadcast();

  @override
  Stream<bool> get playing => _playing.stream;

  @override
  Future<void> playFile(String path) async {}

  @override
  Future<void> playUrl(String url) async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async => _playing.close();
}

/// Lets the cubit's broadcast stream deliver what it already emitted.
Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  late _Tasks tasks;
  late ParentTasksCubit cubit;
  late List<ParentTasksState> states;

  setUp(() async {
    tasks = _Tasks();
    cubit = ParentTasksCubit(_Repository(), _Family(), tasks);
    await cubit.loadAllTasks();
    await _flush();
    states = [];
    cubit.stream.listen(states.add);
  });

  tearDown(() => cubit.close());

  test('a failed attach for one child reports that child and task', () async {
    tasks.failVoiceFor.add('kid-b');

    await cubit.createTaskForChildren(
      const ['kid-a', 'kid-b', 'kid-c'],
      _request,
      voice: _voice,
    );
    await _flush();

    expect(tasks.created, ['kid-a', 'kid-b', 'kid-c']);
    final error = states.whereType<ParentTaskActionError>().single;
    expect(error.pendingVoice, [(childId: 'kid-b', taskId: 'task-kid-b')]);
  });

  test('retry re-attaches only the pending task and creates nothing', () async {
    tasks.failVoiceFor.add('kid-b');
    await cubit.createTaskForChildren(
      const ['kid-a', 'kid-b', 'kid-c'],
      _request,
      voice: _voice,
    );
    await _flush();
    final pending = states.whereType<ParentTaskActionError>().single;

    tasks.failVoiceFor.clear();
    tasks.attaches.clear();
    await cubit.retryVoice(pending.pendingVoice, voice: _voice);
    await _flush();

    expect(tasks.created, ['kid-a', 'kid-b', 'kid-c']);
    expect(tasks.attaches, [(childId: 'kid-b', taskId: 'task-kid-b')]);
    expect(states.last, isA<ParentTasksLoaded>());
    expect(states.whereType<ParentTaskSaved>(), hasLength(1));
  });

  test('a retry that fails again keeps only what is still pending', () async {
    tasks.failVoiceFor.addAll({'kid-a', 'kid-c'});
    await cubit.createTaskForChildren(
      const ['kid-a', 'kid-b', 'kid-c'],
      _request,
      voice: _voice,
    );
    await _flush();
    final first = states.whereType<ParentTaskActionError>().single;
    expect(first.pendingVoice.map((t) => t.childId), ['kid-a', 'kid-c']);

    tasks.failVoiceFor.remove('kid-a');
    states.clear();
    await cubit.retryVoice(first.pendingVoice, voice: _voice);
    await _flush();

    final second = states.whereType<ParentTaskActionError>().single;
    expect(second.pendingVoice, [(childId: 'kid-c', taskId: 'task-kid-c')]);
    expect(tasks.created, hasLength(3));
  });

  testWidgets('a re-record that cannot start drops the deleted take', (
    tester,
  ) async {
    final capture = _Capture();
    final saves = <TaskVoiceSave>[];
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
        home: Scaffold(
          body: TaskVoiceRecorderPanel(
            capture: capture,
            playback: _Playback(),
            onChanged: saves.add,
          ),
        ),
      ),
    );
    final s = S.of(tester.element(find.byType(TaskVoiceRecorderPanel)));

    await tester.tap(find.text(s.recordVoiceInstruction));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.text(s.stopRecording));
    await tester.pump();
    expect(saves.last.attach, isNotNull);

    capture.failStart = true;
    await tester.tap(find.text(s.rerecordVoice));
    await tester.pump();

    expect(saves.last.hasWork, isFalse);
    expect(find.text(s.micPermissionDenied), findsOneWidget);
  });
}
