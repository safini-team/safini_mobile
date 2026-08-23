import 'package:flutter_test/flutter_test.dart';
import 'package:safini/features/child/data/dto/child_dto.dart' as child_api;
import 'package:safini/features/child/presentation/cubit/reward_store_state.dart';
import 'package:safini/features/common/profile/domain/models/profile_model.dart';
import 'package:safini/features/models/domain/models/family_model.dart';

void main() {
  test('profile uses NoName when display_name is null', () {
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

    expect(profile.displayName, 'NoName');
    expect(profile.childId, 'child-1');
  });

  test('child and family summaries use NoName for nullable names', () {
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

    expect(child.nickname, 'NoName');
    expect(parentSummary.displayName, 'NoName');
    expect(childSummary.nickname, 'NoName');
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
