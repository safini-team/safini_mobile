import 'package:safini/core/version_gate/version_gate_tier.dart';
import 'package:safini/core/version_gate/version_policy.dart';

class VersionGateState {
  const VersionGateState({
    required this.tier,
    required this.installedVersion,
    this.policy,
    this.fromCache = false,
    this.softDismissed = false,
    this.openingStore = false,
  });

  const VersionGateState.silent(String installedVersion)
    : this(tier: VersionGateTier.silent, installedVersion: installedVersion);

  final VersionGateTier tier;
  final String installedVersion;
  final VersionPolicy? policy;
  final bool fromCache;
  final bool softDismissed;
  final bool openingStore;

  bool get blocksApp => tier == VersionGateTier.hard;

  bool get showSoftBanner =>
      tier == VersionGateTier.soft && !softDismissed && policy != null;

  VersionGateState copyWith({
    VersionGateTier? tier,
    String? installedVersion,
    VersionPolicy? policy,
    bool? fromCache,
    bool? softDismissed,
    bool? openingStore,
  }) {
    return VersionGateState(
      tier: tier ?? this.tier,
      installedVersion: installedVersion ?? this.installedVersion,
      policy: policy ?? this.policy,
      fromCache: fromCache ?? this.fromCache,
      softDismissed: softDismissed ?? this.softDismissed,
      openingStore: openingStore ?? this.openingStore,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is VersionGateState &&
      tier == other.tier &&
      installedVersion == other.installedVersion &&
      policy == other.policy &&
      fromCache == other.fromCache &&
      softDismissed == other.softDismissed &&
      openingStore == other.openingStore;

  @override
  int get hashCode => Object.hash(
    tier,
    installedVersion,
    policy,
    fromCache,
    softDismissed,
    openingStore,
  );
}
