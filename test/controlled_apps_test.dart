import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/utils/constants/controlled_apps.dart';

/// The installed-apps screen decides whether a row is tappable (add / limit /
/// block) purely from `ControlledApps.slugFor`. A wrong answer here either
/// hides a controllable app or offers to limit one the backend can't key.
void main() {
  test('slug ⇄ package round-trips for every catalog entry', () {
    ControlledApps.slugToPackage.forEach((slug, package) {
      expect(ControlledApps.packageFor(slug), package);
      expect(ControlledApps.slugFor(package), slug);
    });
  });

  test('a package that is not a controlled app resolves to null', () {
    expect(ControlledApps.slugFor('com.whatsapp'), isNull);
    expect(ControlledApps.slugFor(''), isNull);
    expect(ControlledApps.packageFor('tiktok'), isNull);
  });

  test('known mappings are stable', () {
    expect(ControlledApps.slugFor('com.roblox.client'), 'roblox');
    expect(
      ControlledApps.packageFor('youtube-kids'),
      'com.google.android.apps.youtube.kids',
    );
  });
}
