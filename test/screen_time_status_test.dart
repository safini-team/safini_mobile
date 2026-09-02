import 'package:flutter_test/flutter_test.dart';
import 'package:safini/features/models/domain/models/screen_time_status.dart';

/// iOS parallel to `installed_apps_snapshot_test`. The parent never gets app
/// names on iOS — only these counts + flags — so the parse must be exact.
void main() {
  test('parses the wire shape from ios_parent_backend_sync.md', () {
    final s = ScreenTimeStatus.fromJson({
      'platform': 'ios',
      'authorization': 'approved',
      'selected_applications': 3,
      'selected_categories': 1,
      'shield_active': true,
      'updated_at': '2026-08-27T00:00:00Z',
    });

    expect(s.authorization, 'approved');
    expect(s.selectedApplications, 3);
    expect(s.selectedCategories, 1);
    expect(s.shieldActive, isTrue);
    expect(s.updatedAt, DateTime.utc(2026, 8, 27));
    expect(s.neverSynced, isFalse);
  });

  test('updated_at: null means never synced', () {
    final s = ScreenTimeStatus.fromJson({
      'authorization': 'notDetermined',
      'updated_at': null,
    });
    expect(s.neverSynced, isTrue);
    expect(s.shieldActive, isFalse);
    expect(s.selectedApplications, 0);
  });

  test('toJson never leaks tokens — counts and flags only', () {
    const s = ScreenTimeStatus(
      authorization: 'approved',
      selectedApplications: 2,
      selectedCategories: 0,
      shieldActive: false,
    );
    expect(s.toJson().keys, containsAll(<String>['platform', 'authorization']));
    expect(s.toJson().toString(), isNot(contains('token')));
  });
}
