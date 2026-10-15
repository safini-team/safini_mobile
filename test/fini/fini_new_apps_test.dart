import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/notifications/push_event.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/fini/domain/fini_models.dart';
import 'package:safini/features/fini/presentation/fini_copy.dart';
import 'package:safini/features/fini/presentation/widgets/new_app_actions.dart';
import 'package:safini/features/models/domain/models/installed_app.dart';

FiniProposal _sort({
  String id = 'p',
  FiniProposalStatus status = FiniProposalStatus.applied,
  String decidedBy = 'fini',
  Map<String, dynamic> payload = const {},
  DateTime? at,
}) => FiniProposal(
  id: id,
  childId: 'amir',
  kind: 'app_sort',
  status: status,
  decidedBy: decidedBy,
  reason: 'Fini added Dragon Dash to games (blocked).',
  createdAt: at ?? DateTime.now(),
  payload: {
    'package_name': 'com.example.dragon',
    'app_name': 'Dragon Dash',
    ...payload,
  },
);

void main() {
  late S s;
  setUp(() async => s = await S.load(const Locale('en')));

  test('Fini sorted a game into a blocked pool', () {
    final sorted = _sort(payload: {'category': 'games', 'limit_minutes': 0});
    expect(
      finiActivityTitle(s, sorted, childName: 'Amir'),
      'Added Dragon Dash to Games',
    );
    expect(finiReasonLine(s, sorted), s.finiAppSortedBlocked);
    expect(finiNotThisLabel(s, 'games'), 'Not a game');
    expect(finiNotThisLabel(s, 'social'), 'Not Social');
  });

  test('a card for an app Fini could not sort', () {
    final card = _sort(
      status: FiniProposalStatus.pending,
      decidedBy: '',
      payload: {'category': null, 'guess': 'other', 'cant_sort': true},
    );
    expect(card.cantSort, isTrue);
    expect(
      finiCardTitle(s, card, childName: 'Amir'),
      'New app: Dragon Dash. Where does it go?',
    );
    expect(finiReasonLine(s, card), contains('15 m a day'));
  });

  test("the parent's answers read as theirs, with no reason line", () {
    final allowed = _sort(
      decidedBy: 'parent',
      status: FiniProposalStatus.accepted,
      payload: {'category': 'games', 'minutes': 15, 'by': 'parent'},
    );
    expect(
      finiActivityTitle(s, allowed, childName: 'Amir'),
      'Dragon Dash: 15 m a day of its own',
    );
    expect(finiReasonLine(s, allowed), isEmpty);
    final moved = _sort(
      decidedBy: 'parent',
      status: FiniProposalStatus.accepted,
      payload: {'category': 'other', 'by': 'parent'},
    );
    expect(
      finiActivityTitle(s, moved, childName: 'Amir'),
      'Moved Dragon Dash to No limit',
    );
  });

  test('the buttons stay until the parent answers, for a day', () {
    final now = DateTime(2026, 10, 15, 12);
    final sorted = _sort(at: now.subtract(const Duration(hours: 2)));
    expect(openAppSorts([sorted], now), [sorted]);
    expect(openAppSorts([sorted], now.add(const Duration(hours: 23))), isEmpty);
    final answered = _sort(
      id: 'q',
      decidedBy: 'parent',
      status: FiniProposalStatus.accepted,
      payload: {'category': 'other', 'by': 'parent'},
    );
    expect(openAppSorts([answered, sorted], now), isEmpty);
  });

  test('the phone sends the category the app declares', () {
    const app = InstalledApp(
      packageName: 'com.example.dragon',
      appName: 'Dragon Dash',
      storeCategory: 'game',
    );
    expect(app.toJson()['store_category'], 'game');
    expect(
      const InstalledApp(packageName: 'a', appName: 'A').toJson(),
      isNot(contains('store_category')),
    );
  });

  test('new-app pushes open Fini', () {
    for (final wire in ['fini_app_sorted', 'fini_app_sort']) {
      expect(PushType.parse(wire), isNotNull);
    }
  });
}
