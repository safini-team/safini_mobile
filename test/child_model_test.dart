import 'package:flutter_test/flutter_test.dart';
import 'package:safini/features/models/domain/models/child_model.dart';

/// PATCH /v1/children/{id} answers with the child row. A child with no avatar
/// yet has `avatar_state: null`, and parsing that used to throw a cast error,
/// which left Save on Edit child spinning forever.
Map<String, dynamic> _row({Object? avatarState}) => {
  'id': 'c1',
  'family_id': 'f1',
  'nickname': 'Амир',
  'age': 9,
  'gender': 'girl',
  'avatar_state': avatarState,
  'level': 3,
  'xp': 40,
  'current_streak_days': 4,
  'longest_streak_days': 4,
  'tasks_completed_count': 0,
  'coins_balance': 95,
  'achievements_count': 1,
  'created_at': '2026-09-13T08:00:00Z',
  'updated_at': '2026-09-13T08:41:00Z',
};

void main() {
  test('a child without an avatar still parses', () {
    final child = ChildModel.fromJson(_row());
    expect(child.gender, 'girl');
    expect(child.avatarState.equipped, isEmpty);
  });

  test('an avatar without equipped items still parses', () {
    final child = ChildModel.fromJson(_row(avatarState: <String, dynamic>{}));
    expect(child.avatarState.equipped, isEmpty);
  });

  test('equipped items come through', () {
    final child = ChildModel.fromJson(
      _row(
        avatarState: <String, dynamic>{
          'equipped': {'hair': 'starter-hair-01'},
        },
      ),
    );
    expect(child.avatarState.equipped, {'hair': 'starter-hair-01'});
  });
}
