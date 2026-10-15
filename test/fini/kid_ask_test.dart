import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/child/data/services/child_app_rules_service.dart';
import 'package:safini/features/child/presentation/cubit/child_time_cubit.dart';
import 'package:safini/features/common/profile/domain/controllers/profile_controller.dart';
import 'package:safini/features/fini/domain/fini_models.dart';
import 'package:safini/features/fini/presentation/fini_copy.dart';
import 'package:safini/features/fini/kid/kid_ask_card.dart';
import 'package:safini/features/fini/kid/kid_fini.dart';
import 'package:safini/features/models/data/services/device_usage_service.dart';
import 'package:safini/features/models/domain/models/device_usage.dart';
import 'package:safini/features/parent/domain/models/child_app_usage_model.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart'
    show formatHm;

class _Usage extends Fake implements DeviceUsageService {
  @override
  Future<Either<Failure, DeviceUsage>> fetch(String childId) async =>
      const Left(ServerFailure('offline'));
}

class _Rules extends Fake implements ChildAppRulesService {
  @override
  Future<Either<Failure, ChildAppUsageSnapshot>> fetchUsageSnapshot(
    String childId,
  ) async => const Right(ChildAppUsageSnapshot.empty);
}

class _Profile extends Fake implements ProfileController {}

const _games = KidPool(
  goalId: 'g',
  intent: GoalIntent.games,
  limitMinutes: 90,
  planMinutes: 90,
  usedMinutes: 90,
  timeUp: true,
  apps: ['Roblox', 'Brawl Stars'],
);

class _Server implements KidFiniService {
  var asks = 0;
  bool refuse = false;
  KidFini view = const KidFini(pools: [_games], canAsk: true);

  @override
  Future<KidFini> load(String childId) async => view;

  @override
  Future<KidAsk> ask(String childId, String goalId) async {
    asks++;
    if (refuse) throw Exception('409');
    return KidAsk(id: 'a', goalId: goalId, state: KidAskState.pending);
  }
}

ChildTimeCubit _cubit(_Server server) => ChildTimeCubit(
  _Usage(),
  _Rules(),
  _Profile(),
  fini: server,
  childId: () async => 'amir',
);

Future<void> _pump(
  WidgetTester tester,
  KidFini fini, {
  void Function()? onAsk,
}) => tester.pumpWidget(
  MaterialApp(
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: S.delegate.supportedLocales,
    home: Scaffold(
      body: KidAskCard(fini: fini, onAsk: (_) => onAsk?.call()),
    ),
  ),
);

void main() {
  group('ChildTimeCubit.askForTime', () {
    test('one ask, then the button is gone for the day', () async {
      final server = _Server();
      final cubit = _cubit(server);
      addTearDown(cubit.close);
      await cubit.load();
      expect(cubit.state.fini.canAsk, isTrue);

      final first = cubit.askForTime('g');
      expect(cubit.state.asking, isTrue);
      expect(await first, isNull);
      expect(cubit.state.fini.canAsk, isFalse);
      expect(cubit.state.fini.ask?.state, KidAskState.pending);
      expect(cubit.state.asking, isFalse);
    });

    test('a refused ask reads what is true instead of guessing', () async {
      final server = _Server()..refuse = true;
      final cubit = _cubit(server);
      addTearDown(cubit.close);
      await cubit.load();
      // Another device already asked: the server now says so.
      server.view = const KidFini(
        pools: [_games],
        ask: KidAsk(id: 'a', goalId: 'g', state: KidAskState.declined),
      );
      expect(await cubit.askForTime('g'), isNull);
      expect(cubit.state.fini.ask?.state, KidAskState.declined);
      expect(cubit.state.fini.canAsk, isFalse);
    });
  });

  group('KidAskCard', () {
    testWidgets('a spent budget shows the plan and the ask', (tester) async {
      var asked = 0;
      await _pump(
        tester,
        const KidFini(pools: [_games], canAsk: true),
        onAsk: () => asked++,
      );
      final s = S.current;
      expect(find.text(s.kidAskTitleGames), findsOneWidget);
      expect(find.text(s.kidAskPlanGames(formatHm(s, 90))), findsOneWidget);
      expect(find.text(s.kidAskAppsUp('Roblox, Brawl Stars')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('kid-ask')));
      expect(asked, 1);
    });

    testWidgets('the answer replaces the button', (tester) async {
      final s = S.current;
      KidFini answered(KidAskState state, [String? parent]) => KidFini(
        pools: const [_games],
        ask: KidAsk(id: 'a', goalId: 'g', state: state, parentName: parent),
      );
      await _pump(tester, answered(KidAskState.pending));
      expect(find.byKey(const ValueKey('kid-ask')), findsNothing);
      expect(find.text(s.kidAskPending), findsOneWidget);

      await _pump(tester, answered(KidAskState.granted, 'Mom'));
      expect(
        find.text(s.kidAskGrantedBy('Mom', formatHm(s, 15))),
        findsOneWidget,
      );

      await _pump(tester, answered(KidAskState.granted));
      expect(find.text(s.kidAskGrantedFini(formatHm(s, 15))), findsOneWidget);

      await _pump(tester, answered(KidAskState.declined));
      expect(find.text(s.kidAskDeclined), findsOneWidget);
    });

    testWidgets('nothing spent and no ask: no card', (tester) async {
      await _pump(
        tester,
        const KidFini(
          pools: [
            KidPool(
              goalId: 'g',
              intent: GoalIntent.games,
              limitMinutes: 90,
              usedMinutes: 30,
            ),
          ],
          canAsk: true,
        ),
      );
      expect(find.byKey(const ValueKey('kid-ask-card')), findsNothing);
    });
  });

  test('KidFini reads the API', () {
    final fini = KidFini.fromJson({
      'pools': [
        {
          'goal_id': 'g',
          'intent': 'scrolling',
          'limit_minutes': 75,
          'plan_minutes': 60,
          'granted_minutes': 15,
          'used_minutes': 40,
          'time_up': false,
          'apps': [
            {'package_name': 'com.zhiliaoapp.musically', 'app_name': 'TikTok'},
          ],
        },
      ],
      'ask': {'id': 'a', 'goal_id': 'g', 'state': 'granted', 'minutes': 15},
      'can_ask': false,
      'ask_minutes': 15,
    });
    expect(fini.focus?.intent, GoalIntent.scrolling);
    expect(fini.focus?.apps, ['TikTok']);
    expect(fini.ask?.state, KidAskState.granted);
    expect(fini.canAsk, isFalse);
  });

  test(
    'the parent card says which budget ran out, in their language',
    () async {
      final s = await S.load(const Locale('ru'));
      final ask = FiniProposal(
        id: 'p',
        childId: 'amir',
        kind: 'time_grant',
        status: FiniProposalStatus.pending,
        reason: 'Amir asked for 15 more minutes.',
        createdAt: DateTime(2026, 10, 15),
        payload: const {'goal_id': 'g', 'minutes': 15},
        evidence: const {
          'ask': {'intent': 'games', 'minutes': 15},
        },
      );
      expect(finiReasonLine(s, ask), s.finiAskReason(s.goalGames));
      expect(
        finiCardTitle(s, ask, childName: 'Amir'),
        s.finiAskGrant('Amir', 15),
      );
    },
  );
}
