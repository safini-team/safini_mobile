import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_theme.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/child/friends/child_friends_view.dart';
import 'package:safini/features/child/friends/friend.dart';

FriendSummary _friend({
  required String id,
  required String name,
  required int level,
  int done = 0,
  int total = 2,
  int prizes = 0,
}) {
  return FriendSummary(
    childId: id,
    publicId: '100001',
    nickname: name,
    level: level,
    faceEmoji: '😊',
    tasksDoneToday: done,
    tasksTotalToday: total,
    prizesClaimedCount: prizes,
  );
}

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
  home: Scaffold(body: child),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('a friend', () {
    test('has finished the day only when every assigned task is approved', () {
      expect(
        _friend(
          id: 'a',
          name: 'Mia',
          level: 2,
          done: 2,
          total: 2,
        ).allTasksDoneToday,
        isTrue,
      );
      expect(
        _friend(
          id: 'a',
          name: 'Mia',
          level: 2,
          done: 1,
          total: 2,
        ).allTasksDoneToday,
        isFalse,
      );
      expect(
        _friend(
          id: 'a',
          name: 'Mia',
          level: 2,
          done: 0,
          total: 0,
        ).allTasksDoneToday,
        isFalse,
      );
    });

    test(
      'keeps a wallet figure out of the model even if the payload sends one',
      () {
        final friend = FriendSummary.fromJson(const {
          'child_id': 'a',
          'public_id': '222222',
          'nickname': 'Mia',
          'level': 3,
          'tasks_done_today': 1,
          'tasks_total_today': 4,
          'prizes_claimed_count': 2,
          'coins_balance': 40,
        });

        expect(friend.nickname, 'Mia');
        expect(friend.prizesClaimedCount, 2);
        expect(friend.toString(), isNot(contains('40')));
      },
    );

    test('sorts by level without numbering anyone', () {
      final ordered = orderedFriends([
        _friend(id: 'low', name: 'Bea', level: 2),
        _friend(id: 'high', name: 'Ari', level: 6),
        _friend(id: 'mid', name: 'Cal', level: 6),
      ], byLevel: true);

      expect(ordered.map((friend) => friend.nickname), ['Ari', 'Cal', 'Bea']);
    });
  });

  testWidgets('a friend card shows progress and hides money and rank', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        ChildFriendsView(
          publicId: '482913',
          friends: [
            FriendCardData(
              childId: 'done',
              nickname: 'Mia',
              faceEmoji: '😎',
              color: AppColors.kidColor('done'),
              level: 4,
              tasksDoneToday: 3,
              tasksTotalToday: 3,
              prizesClaimedCount: 1,
            ),
            FriendCardData(
              childId: 'open',
              nickname: 'Leo',
              faceEmoji: '😊',
              color: AppColors.kidColor('open'),
              level: 2,
              tasksDoneToday: 1,
              tasksTotalToday: 3,
              prizesClaimedCount: 0,
            ),
          ],
          sortByLevel: false,
          onAdd: () {},
          onToggleSort: () {},
          onCopyId: () {},
          onRemove: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mia'), findsOneWidget);
    expect(find.text('Leo'), findsOneWidget);
    expect(find.text('Level 4'), findsOneWidget);
    expect(find.text('3 tasks today'), findsOneWidget);
    expect(find.text('1 prize'), findsOneWidget);
    expect(find.text('All done today'), findsOneWidget);
    expect(find.text('0 prizes'), findsOneWidget);
    expect(find.textContaining('coin'), findsNothing);
    expect(find.textContaining('Coin'), findsNothing);
    expect(find.textContaining('wallet'), findsNothing);
    expect(find.textContaining('#'), findsNothing);
    expect(find.text('482913'), findsOneWidget);
  });

  testWidgets('an empty list asks for a friend ID', (tester) async {
    await tester.pumpWidget(
      _host(
        ChildFriendsView(
          publicId: '111111',
          friends: const [],
          sortByLevel: false,
          onAdd: () {},
          onToggleSort: () {},
          onCopyId: () {},
          onRemove: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No friends yet'), findsOneWidget);
    expect(find.text('All done today'), findsNothing);
  });
}
