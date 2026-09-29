import 'package:safini/core/version_gate/app_version.dart';

enum VersionGateTier { silent, soft, hard }

/// Maps installed vs remote min/recommended to a UX tier.
///
/// Unparseable versions fail open ([VersionGateTier.silent]) so a bad seed
/// cannot brick the app.
VersionGateTier selectVersionGateTier({
  required String installed,
  required String minSupported,
  required String latestRecommended,
}) {
  final vsMin = compareAppVersions(installed, minSupported);
  if (vsMin == null) return VersionGateTier.silent;
  if (vsMin < 0) return VersionGateTier.hard;

  final vsRecommended = compareAppVersions(installed, latestRecommended);
  if (vsRecommended == null) return VersionGateTier.silent;
  if (vsRecommended < 0) return VersionGateTier.soft;
  return VersionGateTier.silent;
}
