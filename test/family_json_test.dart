import 'package:flutter_test/flutter_test.dart';
import 'package:safini/features/models/domain/models/family_model.dart';

/// `GET /families/current` is the payload the whole parent side hangs off, and
/// its parser is forgiving by design: three spellings for the children list,
/// snake and camel for every field, and a synthesised parent row when the
/// backend sends only an owner id. Forgiving parsers are exactly the ones that
/// quietly return an empty family when a key moves, so the shape is pinned.
void main() {
  group('children list', () {
    for (final key in ['children', 'kids', 'members']) {
      test('is read from "$key"', () {
        final family = FamilyModel.fromJson({
          'id': 'f1',
          key: [
            {'id': 'c1', 'nickname': 'Amir', 'age': 9},
          ],
        });
        expect(family.children.single.nickname, 'Amir');
      });
    }

    test('"children" wins when more than one key is present', () {
      final family = FamilyModel.fromJson({
        'id': 'f1',
        'children': [
          {'id': 'c1', 'nickname': 'Amir'},
        ],
        'kids': [
          {'id': 'c2', 'nickname': 'Layla'},
        ],
      });
      expect(family.children.single.nickname, 'Amir');
    });

    test('is empty rather than a throw when absent or malformed', () {
      expect(FamilyModel.fromJson({'id': 'f1'}).children, isEmpty);
      expect(
        FamilyModel.fromJson({'id': 'f1', 'children': 'nope'}).children,
        isEmpty,
      );
    });

    test('non-map entries are skipped, not fatal', () {
      final family = FamilyModel.fromJson({
        'id': 'f1',
        'children': [
          {'id': 'c1', 'nickname': 'Amir'},
          'garbage',
          null,
        ],
      });
      expect(family.children, hasLength(1));
    });
  });

  group('parents', () {
    test('are parsed when the payload carries them', () {
      final family = FamilyModel.fromJson({
        'id': 'f1',
        'owner_user_id': 'u1',
        'parents': [
          {'user_id': 'u1', 'display_name': 'Aisha', 'role': 'admin'},
        ],
      });
      expect(family.parents.single.displayName, 'Aisha');
      expect(family.parents.single.role, 'admin');
    });

    test('fall back to a single synthesised owner row', () {
      // Some responses carry only `owner_user_id`. The family screen still has
      // to render a Parents section, so one row is synthesised for the owner.
      final family = FamilyModel.fromJson({'id': 'f1', 'owner_user_id': 'u1'});
      expect(family.parents, hasLength(1));
      expect(family.parents.single.userId, 'u1');
      expect(family.parents.single.role, 'admin');
    });

    test('are empty when there is no owner to synthesise from', () {
      expect(FamilyModel.fromJson({'id': 'f1'}).parents, isEmpty);
    });
  });

  group('ChildSummaryModel', () {
    test('reads camelCase and snake_case coin balances alike', () {
      expect(
        ChildSummaryModel.fromJson({'id': 'c', 'coins_balance': 240})
            .coinsBalance,
        240,
      );
      expect(
        ChildSummaryModel.fromJson({'id': 'c', 'coinsBalance': 240})
            .coinsBalance,
        240,
      );
    });

    test('coerces a numeric field sent as a string', () {
      final child = ChildSummaryModel.fromJson({
        'id': 'c',
        'age': '9',
        'coins_balance': '240',
        'level': '4',
      });
      expect(child.age, 9);
      expect(child.coinsBalance, 240);
      expect(child.level, 4);
    });

    test('falls back to zero on an unparseable number', () {
      final child = ChildSummaryModel.fromJson({'id': 'c', 'age': 'nine'});
      expect(child.age, 0);
    });

    test('reads the level from "rank" too', () {
      expect(ChildSummaryModel.fromJson({'id': 'c', 'rank': 7}).level, 7);
    });

    test('leaves a missing child name empty rather than inventing one', () {
      // This asserted 'NoName' until the audit: the literal string was
      // hard-coded in ten files and reached the UI, so a parent read
      // "NoName (you)" on their own Family screen. Empty lets the widget put
      // a localized placeholder in, which "NoName" never could.
      expect(ChildSummaryModel.fromJson({'id': 'c'}).nickname, '');
      expect(
        ChildSummaryModel.fromJson({'id': 'c', 'nickname': '   '}).nickname,
        '',
      );
      expect(
        ChildSummaryModel.fromJson({'id': 'c', 'name': ' Amir '}).nickname,
        'Amir',
      );
    });

    test('survives a payload with no id at all', () {
      expect(ChildSummaryModel.fromJson({}).id, '');
    });
  });

  group('ParentSummaryModel', () {
    test('falls back to the email local part, then to empty', () {
      // GET /v1/me returns display_name: null for every email sign-up, so
      // this is the common path. The email at least belongs to them; the
      // literal "NoName" belonged to nobody.
      expect(ParentSummaryModel.fromJson({'user_id': 'u1'}).displayName, '');
      expect(
        ParentSummaryModel.fromJson({
          'user_id': 'u1',
          'email': 'safini.team@gmail.com',
        }).displayName,
        'safini.team',
      );
      expect(
        ParentSummaryModel.fromJson({
          'user_id': 'u1',
          'displayName': ' Aisha ',
        }).displayName,
        'Aisha',
      );
    });

    test('defaults the role to parent', () {
      expect(ParentSummaryModel.fromJson({'user_id': 'u1'}).role, 'parent');
    });

    test('an unparseable joinedAt is null, not the epoch', () {
      // A null renders as "—" in the sheet; an epoch date would render as
      // "In the family since Jan 1970".
      expect(ParentSummaryModel.fromJson({'user_id': 'u1'}).joinedAt, isNull);
      expect(
        ParentSummaryModel.fromJson({
          'user_id': 'u1',
          'joined_at': 'not a date',
        }).joinedAt,
        isNull,
      );
      expect(
        ParentSummaryModel.fromJson({
          'user_id': 'u1',
          'joined_at': '2026-08-12T10:00:00Z',
        }).joinedAt,
        DateTime.utc(2026, 8, 12, 10),
      );
    });
  });

  test('a round trip through toJson keeps the children', () {
    final family = FamilyModel.fromJson({
      'id': 'f1',
      'name': 'Karimov',
      'owner_user_id': 'u1',
      'children': [
        {'id': 'c1', 'nickname': 'Amir', 'age': 9, 'coins_balance': 240},
      ],
    });

    final reparsed = FamilyModel.fromJson(family.toJson());
    expect(reparsed.id, 'f1');
    expect(reparsed.name, 'Karimov');
    expect(reparsed.children.single.nickname, 'Amir');
    expect(reparsed.children.single.coinsBalance, 240);
  });
}
