import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/theme/app_theme.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/child/presentation/cubit/reward_store_model.dart';
import 'package:safini/features/child/presentation/cubit/reward_store_state.dart';
import 'package:safini/features/child/presentation/screens/home/child_home_screen.dart';
import 'package:safini/features/child/presentation/screens/home/child_today_view.dart';
import 'package:safini/features/prizes/prize.dart';

/// SAF-205: Today previews what the Store sells, so a child sees what coins
/// are for without opening it, and a tap lands on that reward.
Prize _prize(String id, String title, int cost, {String? pending}) => Prize(
  id: id,
  childId: 'c1',
  title: title,
  coinCost: cost,
  emoji: '🎁',
  pendingRequestId: pending,
);

AvatarItem _avatar(
  String id,
  int? cost, {
  bool equipped = false,
  bool locked = false,
}) => AvatarItem(
  id: id,
  name: 'Item $id',
  emoji: '🚀',
  cost: cost,
  isEquipped: equipped,
  isLocked: locked,
);

RewardStoreState _store({
  List<Prize> prizes = const [],
  List<AvatarItem> avatar = const [],
  bool error = false,
  bool loading = false,
}) => RewardStoreState(
  appTimeItems: const [],
  avatarItems: avatar,
  prizes: prizes,
  hasLoadError: error,
  isLoading: loading,
);

ChildTodayData _data(List<TodayGift> gifts) => ChildTodayData(
  greeting: 'Good evening',
  name: 'Amir',
  coins: 50,
  questsDone: 0,
  questsTotal: 0,
  openCoins: 0,
  next: null,
  holdToComplete: true,
  gifts: gifts,
);

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.light,
  locale: const Locale('en'),
  localizationsDelegates: const [
    S.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: S.delegate.supportedLocales,
  home: child,
);

void main() {
  group('todayGifts', () {
    test('gifts first, then buyable avatar items, each cheapest first', () {
      final gifts = todayGifts(
        _store(
          prizes: [_prize('p1', 'Pool', 300), _prize('p2', 'Ice cream', 40)],
          avatar: [
            _avatar('a1', 120),
            _avatar('a2', 30),
            _avatar('owned', null),
            _avatar('starter', 0),
            _avatar('worn', 10, equipped: true),
            _avatar('locked', 10, locked: true),
          ],
        ),
        50,
      );

      expect(gifts.map((g) => g.id), ['p2', 'p1', 'a2', 'a1']);
      expect(gifts.first.affordable, isTrue);
      expect(gifts[1].affordable, isFalse);
      expect(gifts[2].isAvatarItem, isTrue);
    });

    test('caps the strip and keeps a waiting gift marked', () {
      final gifts = todayGifts(
        _store(
          prizes: [
            for (var i = 0; i < 8; i++) _prize('p$i', 'Gift $i', i * 10),
            _prize('held', 'Held', 5, pending: 'r1'),
          ],
        ),
        0,
      );

      expect(gifts, hasLength(todayGiftLimit));
      expect(gifts.firstWhere((g) => g.id == 'held').isWaiting, isTrue);
    });

    test('nothing on a failed or empty store', () {
      expect(
        todayGifts(_store(prizes: [_prize('p', 'P', 1)], error: true), 9),
        isEmpty,
      );
      expect(todayGifts(_store(), 9), isEmpty);
    });
  });

  group('Today rewards strip', () {
    testWidgets('hidden with no rewards', (tester) async {
      await tester.pumpWidget(
        _host(
          ChildTodayView(
            data: _data(const []),
            onOpenStore: () {},
            onOpenTasks: () {},
            onOpenQuest: (_) {},
            onSendQuest: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rewards for you'), findsNothing);
    });

    testWidgets('a tap opens that reward, See all opens the Store', (
      tester,
    ) async {
      TodayGift? opened;
      var seeAll = 0;
      await tester.pumpWidget(
        _host(
          ChildTodayView(
            data: _data(const [
              TodayGift(
                id: 'p1',
                name: 'Ice cream',
                emoji: '🍦',
                cost: 40,
                coins: 50,
              ),
              TodayGift(
                id: 'p2',
                name: 'Trip to the pool',
                emoji: '🏊',
                cost: 300,
                coins: 50,
              ),
            ]),
            onOpenStore: () {},
            onOpenGifts: () => seeAll++,
            onOpenGift: (gift) => opened = gift,
            onOpenTasks: () {},
            onOpenQuest: (_) {},
            onSendQuest: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rewards for you'), findsOneWidget);
      // Affordable shows its price; out of reach shows how close.
      expect(find.text('40'), findsOneWidget);
      expect(find.text('50 / 300'), findsOneWidget);

      await tester.tap(find.text('Trip to the pool'));
      expect(opened?.id, 'p2');

      await tester.tap(find.text('See all'));
      expect(seeAll, 1);
    });
  });
}
