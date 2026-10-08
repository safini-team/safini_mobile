import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:safini/core/version_gate/version_gate_state.dart';
import 'package:safini/core/version_gate/version_gate_tier.dart';
import 'package:safini/core/version_gate/version_policy.dart';
import 'package:safini/core/version_gate/version_policy_client.dart';
import 'package:safini/core/version_gate/version_policy_store.dart';
import 'package:safini/core/version_gate/version_update_launcher.dart';

/// Shared parent+child version gate. Refresh on launch and foreground.
///
/// Hard blocks only after a successful fetch (or a QA force). A failed
/// refresh never bricks the app; a last-good cache may still show a soft
/// banner.
class VersionGateCubit extends Cubit<VersionGateState> {
  VersionGateCubit({
    required VersionPolicyClient client,
    required VersionPolicyStore store,
    required VersionUpdateLauncher launcher,
    Future<String> Function()? installedVersion,
    bool Function()? isIos,
    String forceFlag = _forceFromEnvironment,
  }) : _client = client,
       _store = store,
       _launcher = launcher,
       _installedVersion = installedVersion ?? _readInstalledVersion,
       _isIos = isIos ?? _platformIsIos,
       _force = parseVersionGateForce(forceFlag),
       super(const VersionGateState.silent(''));

  static const _forceFromEnvironment = String.fromEnvironment(
    'VERSION_GATE_FORCE',
  );

  final VersionPolicyClient _client;
  final VersionPolicyStore _store;
  final VersionUpdateLauncher _launcher;
  final Future<String> Function() _installedVersion;
  final bool Function() _isIos;
  final VersionGateForce? _force;

  Future<void> refresh() async {
    final installed = await _installedVersion();
    final forced = _force;
    if (forced != null) {
      _emitFromPolicy(
        VersionPolicy.forced(forced),
        installed: installed,
        allowHard: true,
        fromCache: false,
      );
      return;
    }

    final fresh = await _client.fetch();
    if (fresh != null) {
      await _store.savePolicy(fresh);
      _emitFromPolicy(
        fresh,
        installed: installed,
        allowHard: true,
        fromCache: false,
      );
      return;
    }

    final cached = _store.readPolicy();
    if (cached != null) {
      _emitFromPolicy(
        cached,
        installed: installed,
        allowHard: false,
        fromCache: true,
      );
      return;
    }

    _set(VersionGateState.silent(installed));
  }

  Future<void> dismissSoft() async {
    final policy = state.policy;
    if (policy == null || state.tier != VersionGateTier.soft) return;
    final recommended = policy.forIos(_isIos()).latestRecommended;
    await _store.dismissRecommended(recommended);
    _set(state.copyWith(softDismissed: true));
  }

  Future<void> openStore() async {
    final policy = state.policy;
    if (policy == null) return;
    if (state.openingStore) return;
    _set(state.copyWith(openingStore: true));
    final isIos = _isIos();
    final storeUrl = policy.forIos(isIos).effectiveStoreUrl(isIos: isIos);
    try {
      await _launcher.open(tier: state.tier, storeUrl: storeUrl);
    } finally {
      if (!isClosed) _set(state.copyWith(openingStore: false));
    }
  }

  void _emitFromPolicy(
    VersionPolicy policy, {
    required String installed,
    required bool allowHard,
    required bool fromCache,
  }) {
    final platform = policy.forIos(_isIos());
    var tier = selectVersionGateTier(
      installed: installed,
      minSupported: platform.minSupported,
      latestRecommended: platform.latestRecommended,
    );
    final belowMin = tier == VersionGateTier.hard;
    if (belowMin && !allowHard) {
      // Fetch failed: never hard-block. A last-good cache can still nudge.
      tier = VersionGateTier.soft;
    }
    final dismissed =
        tier == VersionGateTier.soft &&
        !belowMin &&
        _store.isDismissed(platform.latestRecommended);
    _set(
      VersionGateState(
        tier: tier,
        installedVersion: installed,
        policy: policy,
        fromCache: fromCache,
        softDismissed: dismissed,
      ),
    );
  }

  void _set(VersionGateState next) {
    if (state == next) return;
    emit(next);
  }

  static Future<String> _readInstalledVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (info.version.trim().isNotEmpty) return info.version.trim();
    } catch (error) {
      debugPrint('PackageInfo unavailable for version gate: $error');
    }
    // An unknown installed version must not be treated as an old one.
    return '';
  }

  static bool _platformIsIos() {
    try {
      return defaultTargetPlatform == TargetPlatform.iOS;
    } catch (_) {
      return false;
    }
  }
}
