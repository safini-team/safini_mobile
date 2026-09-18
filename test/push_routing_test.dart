import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/notifications/notification_preferences.dart';
import 'package:safini/core/notifications/on_push.dart';
import 'package:safini/core/notifications/push_deep_links.dart';
import 'package:safini/core/notifications/push_event.dart';
import 'package:safini/core/notifications/push_shell.dart';
import 'package:safini/features/child/presentation/screens/main/child_main_screen.dart';
import 'package:safini/features/parent/presentation/screens/main/parent_main_screen.dart';

/// Answers the preferences endpoint and records what was sent.
class _PreferencesAdapter implements HttpClientAdapter {
  _PreferencesAdapter(this.stored);

  Map<String, dynamic> stored;
  final List<RequestOptions> requests = [];
  bool failWrites = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (options.method == 'PATCH') {
      if (failWrites) throw DioException(requestOptions: options);
      stored = {...stored, ...(options.data as Map<String, dynamic>)};
    }
    return ResponseBody.fromString(
      jsonEncode(stored),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late PushDeepLinks links;

  setUp(() {
    links = PushDeepLinks();
    getIt.registerSingleton<PushDeepLinks>(links);
  });

  tearDown(() => GetIt.I.reset());

  group('shells', () {
    PushShell parent(List<int> selected) => PushShell(
      tabFor: ParentMainScreen.tabFor,
      selectTab: selected.add,
      consumedHere: const {PushDestination.parentFamily},
    );

    test('a cold start opens the tab and leaves details for its screen', () {
      links.open(const PushTarget(PushDestination.parentTasks, taskId: 't-1'));
      expect(parent([]).initialTab(0), 1);
      expect(
        links.take(PushDestination.parentTasks)?.taskId,
        't-1',
        reason: 'the Tasks screen opens the review sheet itself',
      );

      links.open(const PushTarget(PushDestination.parentFamily));
      expect(parent([]).initialTab(0), 3);
      expect(links.hasPending, isFalse, reason: 'nothing else takes Family');
    });

    test('a push for the other kind of account is dropped', () {
      links.open(const PushTarget(PushDestination.childTasks, taskId: 't'));
      expect(parent([]).initialTab(0), 0);
      expect(links.hasPending, isFalse);

      links.open(const PushTarget(PushDestination.parentLimits));
      final child = PushShell(
        tabFor: ChildMainScreen.tabFor,
        selectTab: (_) {},
      );
      expect(child.initialTab(-1), -1);
      expect(links.hasPending, isFalse);
    });

    test('a tap with the shell open switches tabs', () async {
      final selected = <int>[];
      final shell = parent(selected)..attach();
      links.open(const PushTarget(PushDestination.parentLimits));
      links.open(const PushTarget(PushDestination.childToday));
      links.open(const PushTarget(PushDestination.parentToday));
      await Future<void>.delayed(Duration.zero);
      expect(selected, [2, 0]);
      shell.dispose();
    });

    test('every destination has exactly one home', () {
      for (final destination in PushDestination.values) {
        final parentTab = ParentMainScreen.tabFor(destination);
        final childTab = ChildMainScreen.tabFor(destination);
        expect(
          (parentTab == null) != (childTab == null),
          isTrue,
          reason: destination.name,
        );
        expect(parentTab != null, destination.isParent);
      }
    });
  });

  testWidgets('a screen refreshes only for the pushes it cares about', (
    tester,
  ) async {
    final events = StreamController<PushEvent>.broadcast();
    final seen = <PushType>[];
    await tester.pumpWidget(
      OnPush(
        events: events.stream,
        types: const {PushType.taskSubmitted},
        onPush: (event) => seen.add(event.type),
        child: const SizedBox(),
      ),
    );
    events
      ..add(const PushEvent(PushType.streakReminder))
      ..add(const PushEvent(PushType.taskSubmitted));
    await tester.pump();
    expect(seen, [PushType.taskSubmitted]);
    await tester.pumpWidget(const SizedBox());
    events.add(const PushEvent(PushType.taskSubmitted));
    await tester.pump();
    expect(seen, hasLength(1), reason: 'a disposed screen stops listening');
    await events.close();
  });

  group('alert switches', () {
    late _PreferencesAdapter adapter;
    late AlertsCubit cubit;

    setUp(() {
      adapter = _PreferencesAdapter({
        'task_submissions': true,
        'limit_reached': true,
        'weekly_digest': false,
      });
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
        ..httpClientAdapter = adapter;
      cubit = AlertsCubit(
        NotificationPreferencesService(dio),
        systemCheck: () async => false,
      );
    });

    tearDown(() => cubit.close());

    test('load reads the account and the phone setting', () async {
      await cubit.load();
      expect(cubit.state.loaded, isTrue);
      expect(cubit.state.systemEnabled, isFalse);
      expect(cubit.state.preferences[AlertSwitch.weeklyDigest], isFalse);
      expect(adapter.requests.single.path, '/v1/me/notification-preferences');
    });

    test('a switch saves only itself', () async {
      await cubit.load();
      await cubit.toggle(AlertSwitch.weeklyDigest, true);
      expect(cubit.state.preferences[AlertSwitch.weeklyDigest], isTrue);
      expect(adapter.requests.last.method, 'PATCH');
      expect(adapter.requests.last.data, {'weekly_digest': true});
    });

    test('a switch the server refused goes back and says so', () async {
      await cubit.load();
      adapter.failWrites = true;
      final states = <AlertsState>[];
      final subscription = cubit.stream.listen(states.add);
      await cubit.toggle(AlertSwitch.taskSubmissions, false);
      await Future<void>.delayed(Duration.zero);
      expect(states.first.preferences[AlertSwitch.taskSubmissions], isFalse);
      expect(states.last.preferences[AlertSwitch.taskSubmissions], isTrue);
      expect(states.last.saveFailed, isTrue);
      await subscription.cancel();
    });

    test('unknown or missing values fall back to the API defaults', () {
      final preferences = NotificationPreferences.fromJson({
        'weekly_digest': 'yes',
      });
      expect(preferences[AlertSwitch.taskSubmissions], isTrue);
      expect(preferences[AlertSwitch.limitReached], isTrue);
      expect(preferences[AlertSwitch.weeklyDigest], isFalse);
    });
  });
}
