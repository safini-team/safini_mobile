import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/features/fini/data/fini_repository.dart';
import 'package:safini/features/fini/demo/fini_demo.dart';
import 'package:safini/features/fini/demo/fini_demo_repository.dart';
import 'package:safini/features/fini/domain/fini_goal_specs.dart';
import 'package:safini/features/fini/domain/fini_models.dart';
import 'package:safini/features/fini/presentation/cubit/fini_cubit.dart';
import 'package:safini/features/fini/presentation/cubit/fini_inbox_cubit.dart';

/// The demo fixtures, with switches to fail a read or a write.
class _Repo extends FiniDemoRepository {
  _Repo(super.state, {super.now});

  bool failReads = false;
  Object? writeError;
  final goalReads = <String>[];

  @override
  Future<List<FiniGoal>> goals(String childId) {
    goalReads.add(childId);
    if (failReads) throw Exception('offline');
    return super.goals(childId);
  }

  @override
  Future<FiniSettings> saveSettings(String childId, FiniSettings settings) {
    if (writeError != null) throw writeError!;
    return super.saveSettings(childId, settings);
  }

  @override
  Future<FiniProposal> decide(String proposalId, FiniDecision decision) {
    if (writeError != null) throw writeError!;
    return super.decide(proposalId, decision);
  }
}

DioException _conflict(String detail) => DioException(
  requestOptions: RequestOptions(path: '/x'),
  response: Response(
    requestOptions: RequestOptions(path: '/x'),
    statusCode: 409,
    data: {'detail': detail},
  ),
);

void main() {
  final now = DateTime(2026, 10, 14, 18);

  test('load fills settings, goals, cards and activity', () async {
    final cubit = FiniCubit(_Repo(FiniDemoState.pendingTimeRequest, now: now));
    final states = <FiniStatus>[];
    final sub = cubit.stream.listen((s) => states.add(s.status));
    await cubit.load('amir');
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(states, [FiniStatus.loading, FiniStatus.loaded]);
    expect(cubit.state.goals, hasLength(4));
    expect(cubit.state.pending.single.kind, 'time_grant');
    expect(cubit.state.activity.first.createdAt.hour, 16);
    expect(cubit.state.activityToday(now), 2);
    expect(cubit.state.settings.level, FiniLevel.auto);
  });

  test('a child with no plan loads empty, not as an error', () async {
    final cubit = FiniCubit(
      _Repo(FiniDemoState.androidChildWithUsage, now: now),
    );
    await cubit.load('amir');
    expect(cubit.state.status, FiniStatus.loaded);
    expect(cubit.state.hasGoals, isFalse);
    expect(cubit.state.pending, isEmpty);
    expect(cubit.state.activity, isEmpty);
  });

  test(
    'a failed first load is an error; a failed reload keeps the data',
    () async {
      final repo = _Repo(FiniDemoState.runningPlan, now: now)..failReads = true;
      final cubit = FiniCubit(repo);
      await cubit.load('amir');
      expect(cubit.state.status, FiniStatus.error);

      repo.failReads = false;
      await cubit.load('amir');
      expect(cubit.state.status, FiniStatus.loaded);

      repo.failReads = true;
      await cubit.load('amir');
      expect(cubit.state.status, FiniStatus.loaded);
      expect(cubit.state.goals, hasLength(4));
    },
  );

  test('switching child drops the old child at once', () async {
    final cubit = FiniCubit(_Repo(FiniDemoState.runningPlan, now: now));
    await cubit.load('amir');
    final future = cubit.load('laylo');
    expect(cubit.state.childId, 'laylo');
    expect(cubit.state.goals, isEmpty);
    await future;
    expect(cubit.state.goals.first.childId, 'laylo');
  });

  test('adding a goal marks its tile as added', () async {
    final cubit = FiniCubit(
      _Repo(FiniDemoState.androidChildWithUsage, now: now),
    );
    await cubit.load('amir');
    final games = goalIntentSpecs.firstWhere(
      (spec) => spec.intent == GoalIntent.games,
    );
    expect(await cubit.addGoal(games), isNull);
    expect(cubit.state.addedIntents, {GoalIntent.games});
    expect(cubit.state.goals.single.minutesPerDay, 60);
  });

  test('a failed settings save moves the switch back', () async {
    final repo = _Repo(FiniDemoState.runningPlan, now: now);
    final cubit = FiniCubit(repo);
    await cubit.load('amir');
    repo.writeError = Exception('offline');

    final error = await cubit.saveSettings(
      cubit.state.settings.copyWith(paused: true),
    );
    expect(error, '');
    expect(cubit.state.settings.paused, isFalse);
  });

  test('accept, dismiss and undo refresh the lists and the badge', () async {
    var inboxChanges = 0;
    final cubit = FiniCubit(
      _Repo(FiniDemoState.pendingTimeRequest, now: now),
      onInboxChanged: () => inboxChanges++,
    );
    await cubit.load('amir');
    final card = cubit.state.pending.single;

    expect(await cubit.decide(card, FiniDecision.accept), isNull);
    expect(cubit.state.pending, isEmpty);
    final accepted = cubit.state.activity.firstWhere((p) => p.id == card.id);
    expect(accepted.status, FiniProposalStatus.accepted);
    expect(inboxChanges, 1);

    expect(await cubit.decide(accepted, FiniDecision.undo), isNull);
    expect(
      cubit.state.activity.firstWhere((p) => p.id == card.id).status,
      FiniProposalStatus.undone,
    );
    expect(inboxChanges, 2);
  });

  test('dismiss takes the card away', () async {
    final cubit = FiniCubit(_Repo(FiniDemoState.pendingTimeRequest, now: now));
    await cubit.load('amir');
    await cubit.decide(cubit.state.pending.single, FiniDecision.dismiss);
    expect(cubit.state.pending, isEmpty);
    expect(
      cubit.state.activity.any((p) => p.status == FiniProposalStatus.dismissed),
      isTrue,
    );
  });

  test("a refused undo shows the server's reason", () async {
    final repo = _Repo(FiniDemoState.runningPlan, now: now);
    final cubit = FiniCubit(repo);
    await cubit.load('amir');
    repo.writeError = _conflict('The rule changed since. Nothing to undo.');
    final error = await cubit.decide(
      cubit.state.activity.first,
      FiniDecision.undo,
    );
    expect(error, 'The rule changed since. Nothing to undo.');
  });

  test('writes before a child is loaded do nothing', () async {
    final cubit = FiniCubit(_Repo(FiniDemoState.runningPlan, now: now));
    expect(await cubit.saveSettings(const FiniSettings()), '');
  });

  group('FiniInboxCubit', () {
    test('counts pending cards per child for the tab badge', () async {
      final repo = _Repo(FiniDemoState.pendingTimeRequest, now: now);
      await repo.goals('amir');
      await repo.goals('laylo');
      final inbox = FiniInboxCubit(repo);
      await inbox.refresh();
      expect(inbox.state.total, 2);
      expect(inbox.state.byChild, {'amir': 1, 'laylo': 1});
    });

    test('a running plan with nothing waiting has no badge', () async {
      final repo = _Repo(FiniDemoState.runningPlan, now: now);
      await repo.goals('amir');
      final inbox = FiniInboxCubit(repo);
      await inbox.refresh();
      expect(inbox.state.total, 0);
    });

    test('parses the API shape', () {
      final inbox = FiniInbox.fromJson({
        'total': 3,
        'children': [
          {'child_id': 'a', 'pending': 2},
          {'child_id': 'b', 'pending': 1},
        ],
      });
      expect(inbox.total, 3);
      expect(inbox.byChild['a'], 2);
    });
  });

  test('a child seen before shows at once and is not fetched again', () async {
    final repo = _Repo(FiniDemoState.runningPlan);
    final cubit = FiniCubit(repo);
    addTearDown(cubit.close);

    await cubit.load('a');
    await cubit.prefetch(['a', 'b']);
    expect(repo.goalReads, ['a', 'b']);

    final states = <FiniState>[];
    final sub = cubit.stream.listen(states.add);
    addTearDown(sub.cancel);
    await cubit.load('b');
    await cubit.load('a');
    expect(states.map((s) => (s.childId, s.status)), [
      ('b', FiniStatus.loaded),
      ('a', FiniStatus.loaded),
    ]);
    expect(repo.goalReads, ['a', 'b']);

    await cubit.load('a', force: true);
    expect(repo.goalReads, ['a', 'b', 'a']);
  });
}
