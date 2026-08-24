import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/utils/display_name.dart';
import 'package:safini/features/child/data/dto/child_dto.dart' as child_api;
import 'package:safini/features/child/presentation/cubit/reward_store_state.dart';
import 'package:safini/features/common/profile/domain/models/profile_model.dart';
import 'package:safini/features/models/domain/models/family_model.dart';

void main() {
  test('profile falls back to the email local part, never "NoName"', () {
    final profile = ProfileModel.fromJson({
      'user_id': 'user-1',
      'email': 'child@example.com',
      'display_name': null,
      'avatar_url': null,
      'bio': null,
      'timezone': null,
      'account_type': 'child',
      'family_id': null,
      'child_id': 'child-1',
      'created_at': '2026-08-23T08:25:13.751892Z',
      'updated_at': '2026-08-23T08:25:13.751892Z',
    });

    // The API returns display_name: null for every email sign-up, so this is
    // the common path, not an edge case.
    expect(profile.displayName, 'child');
    expect(profile.childId, 'child-1');
  });

  test('resolveDisplayName prefers the real name and never invents one', () {
    expect(resolveDisplayName('Ilkhom Sidikov', email: 'x@y.com'),
        'Ilkhom Sidikov');
    expect(resolveDisplayName('  Ilkhom  '), 'Ilkhom');
    expect(resolveDisplayName(null, email: 'safini.team@gmail.com'),
        'safini.team');
    // Nothing to work with: empty, so the widget can localize a placeholder.
    expect(resolveDisplayName(null), '');
    expect(resolveDisplayName('', email: 'not-an-email'), '');
    expect(resolveDisplayName(null, email: '@nolocalpart.com'), '');
  });

  test('child and family summaries leave a missing name empty', () {
    final child = child_api.ChildDto.fromJson({
      'id': 'child-1',
      'family_id': 'family-1',
      'nickname': null,
      'age': 8,
    });
    final parentSummary = ParentSummaryModel.fromJson({
      'user_id': 'parent-1',
      'display_name': null,
    });
    final childSummary = ChildSummaryModel.fromJson({
      'id': 'child-1',
      'nickname': null,
    });

    // A child always has a nickname in practice (the parent types it on
    // create), so these are defensive. Empty beats a fake name either way.
    expect(child.nickname, '');
    expect(parentSummary.displayName, '');
    expect(childSummary.nickname, '');
  });

  test('store state distinguishes loading, error, and empty', () {
    const loading = RewardStoreState.initial();
    final error = loading.copyWith(isLoading: false, hasLoadError: true);
    final empty = error.copyWith(hasLoadError: false);

    expect(loading.isLoading, isTrue);
    expect(error.hasLoadError, isTrue);
    expect(empty.hasLoadError, isFalse);
    expect(empty.appTimeItems, isEmpty);
    expect(empty.avatarItems, isEmpty);
  });
}
