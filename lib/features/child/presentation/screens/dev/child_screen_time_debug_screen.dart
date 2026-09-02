import 'package:flutter/material.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/features/child/data/services/child_app_rules_service.dart';
import 'package:safini/features/child/data/services/screen_time_service.dart';
import 'package:safini/features/common/profile/domain/controllers/profile_controller.dart';
import 'package:safini/features/models/domain/models/screen_time_status.dart';

/// DEV-ONLY diagnostic screen for the iOS Screen Time / FamilyControls path.
///
/// Exercises [ScreenTimeService] end to end: authorization → app picker →
/// apply/clear the system shield. It is the iOS analogue of
/// `ChildAppsDebugScreen`, but note the platforms are fundamentally different —
/// there is **no app list** here, only opaque token *counts* (Apple never
/// exposes the underlying app identities). See `observation/child_get_apps.md`
/// §6 and `observation/screenzen_research.md`.
///
/// Until the `com.apple.developer.family-controls` entitlement is approved by
/// Apple, "Request authorization" fails with a clear error — that is the
/// expected state, not a bug.
///
/// Reachable from Kid · Me only in debug builds (see the `kDebugMode` guard in
/// `ChildMeSettings`).
class ChildScreenTimeDebugScreen extends StatefulWidget {
  const ChildScreenTimeDebugScreen({super.key});

  @override
  State<ChildScreenTimeDebugScreen> createState() =>
      _ChildScreenTimeDebugScreenState();
}

class _ChildScreenTimeDebugScreenState
    extends State<ChildScreenTimeDebugScreen> {
  final ScreenTimeService _service = getIt<ScreenTimeService>();
  final ChildAppRulesService _rules = getIt<ChildAppRulesService>();
  final ProfileController _profile = getIt<ProfileController>();

  bool _busy = false;
  ScreenTimeAuthStatus _status = ScreenTimeAuthStatus.unavailable;
  ScreenTimeSelection _selection = const ScreenTimeSelection();
  bool _shieldActive = false;
  String? _lastMessage;
  bool _lastWasError = false;

  String? _childId;
  bool _syncBusy = false;
  String? _syncMessage;

  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  Future<String?> _resolveChildId() async {
    if (_childId != null) return _childId;
    final result = await _profile.fetchMe();
    _childId = result.fold((_) => null, (p) {
      final id = p.childId?.trim();
      return (id == null || id.isEmpty) ? null : id;
    });
    return _childId;
  }

  /// PUT the current Screen Time status (auth + counts + shield flag), then GET
  /// it back. Same diagnostic as the Android installed-apps round-trip. The
  /// endpoint is not deployed yet (SAF-154) — expect `GET failed … 404` until
  /// it ships; that is the useful signal, not a bug.
  Future<void> _syncRoundTrip() async {
    setState(() {
      _syncBusy = true;
      _syncMessage = null;
    });

    final childId = await _resolveChildId();
    if (!mounted) return;
    if (childId == null) {
      setState(() {
        _syncBusy = false;
        _syncMessage =
            'No child id — /me returned no child_id. Not signed in '
            'as a child?';
      });
      return;
    }

    final status = ScreenTimeStatus(
      authorization: _status.name,
      selectedApplications: _selection.applications,
      selectedCategories: _selection.categories,
      shieldActive: _shieldActive,
    );

    final put = await _rules.reportScreenTimeStatus(childId, status);
    if (!mounted) return;
    final putMsg = put.fold(
      (f) => 'PUT failed: ${f.message}',
      (_) =>
          'PUT ok (auth=${status.authorization}, '
          'apps=${status.selectedApplications}, '
          'cats=${status.selectedCategories}, shield=${status.shieldActive})',
    );

    final get = await _rules.fetchScreenTimeStatus(childId);
    if (!mounted) return;
    final getMsg = get.fold(
      (f) => 'GET failed: ${f.message}',
      (s) =>
          'GET ok: auth=${s.authorization}, apps=${s.selectedApplications}, '
          'cats=${s.selectedCategories}, shield=${s.shieldActive}, '
          'updated_at=${s.updatedAt?.toIso8601String() ?? "null"}',
    );

    setState(() {
      _syncBusy = false;
      _syncMessage = 'child_id=$childId\n$putMsg\n$getMsg';
    });
  }

  Future<void> _run(
    String label,
    Future<void> Function() action,
  ) async {
    setState(() {
      _busy = true;
      _lastMessage = null;
      _lastWasError = false;
    });
    try {
      await action();
      if (!mounted) return;
      setState(() => _lastMessage = '$label: OK');
    } on ScreenTimeException catch (e) {
      if (!mounted) return;
      setState(() {
        _lastWasError = true;
        _lastMessage = '$label failed [${e.code}]: ${e.message}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _lastWasError = true;
        _lastMessage = '$label failed: $e';
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _refreshStatus() async {
    final status = await _service.authorizationStatus();
    final selection = await _service.selectionCounts();
    if (!mounted) return;
    setState(() {
      _status = status;
      _selection = selection;
    });
  }

  void _setShield(bool active) {
    _shieldActive = active;
    if (mounted) setState(() {});
  }

  Future<void> _requestAuth() => _run('Request authorization', () async {
    _status = await _service.requestAuthorization();
  });

  Future<void> _pickApps() => _run('Pick apps', () async {
    _selection = await _service.presentPicker();
  });

  Future<void> _block() => _run('Apply shield', () async {
    final applied = await _service.applyShield();
    if (!applied) {
      throw const ScreenTimeException(
        'empty_selection',
        'Nothing selected — pick apps first.',
      );
    }
    _setShield(true);
  });

  Future<void> _unblock() => _run('Clear shield', () async {
    await _service.clearShield();
    _setShield(false);
  });

  @override
  Widget build(BuildContext context) {
    final supported = _service.isSupported;
    return Scaffold(
      backgroundColor: AppColors.bgChild,
      appBar: AppBar(
        backgroundColor: AppColors.bgChild,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'DEV · Screen Time',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh status',
            onPressed: _busy ? null : _refreshStatus,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          children: [
            _StatusCard(
              supported: supported,
              status: _status,
              selection: _selection,
              shieldActive: _shieldActive,
            ),
            const SizedBox(height: 16),
            if (!supported)
              const _MessageBlock(
                emoji: '🍏',
                title: 'iOS only',
                body:
                    'Screen Time / FamilyControls exists only on iOS. Run on an '
                    'iPhone/iPad to test this path.',
              )
            else ...[
              _ActionButton(
                label: 'Request authorization',
                icon: Icons.verified_user_outlined,
                enabled: !_busy,
                onTap: _requestAuth,
              ),
              const SizedBox(height: 10),
              _ActionButton(
                label: 'Pick apps (FamilyActivityPicker)',
                icon: Icons.apps_outlined,
                enabled: !_busy && _status == ScreenTimeAuthStatus.approved,
                onTap: _pickApps,
              ),
              const SizedBox(height: 10),
              _ActionButton(
                label: 'Block selected (apply shield)',
                icon: Icons.shield_outlined,
                enabled: !_busy && _status == ScreenTimeAuthStatus.approved,
                onTap: _block,
              ),
              const SizedBox(height: 10),
              _ActionButton(
                label: 'Unblock all (clear shield)',
                icon: Icons.lock_open_outlined,
                enabled: !_busy && _status == ScreenTimeAuthStatus.approved,
                onTap: _unblock,
              ),
              const SizedBox(height: 10),
              _ActionButton(
                label: _syncBusy
                    ? 'Syncing status…'
                    : 'Sync status to backend, then read back',
                icon: Icons.cloud_sync,
                enabled: !_busy && !_syncBusy,
                onTap: _syncRoundTrip,
              ),
              if (_syncMessage != null) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.group),
                  ),
                  child: SelectableText(
                    _syncMessage!,
                    style: AppText.metaSm.copyWith(fontFamily: 'monospace'),
                  ),
                ),
              ],
            ],
            if (_busy)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
            if (_lastMessage != null) ...[
              const SizedBox(height: 16),
              _MessageBlock(
                emoji: _lastWasError ? '⚠️' : '✅',
                title: _lastWasError ? 'Last call failed' : 'Last call',
                body: _lastMessage!,
              ),
            ],
            const SizedBox(height: 16),
            const _MessageBlock(
              emoji: 'ℹ️',
              title: 'Expected before entitlement',
              body:
                  'Without the approved com.apple.developer.family-controls '
                  'entitlement, "Request authorization" fails with a missing-'
                  'entitlement error. That is the correct state until Apple '
                  'grants it.',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.supported,
    required this.status,
    required this.selection,
    required this.shieldActive,
  });

  final bool supported;
  final ScreenTimeAuthStatus status;
  final ScreenTimeSelection selection;
  final bool shieldActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.group),
      ),
      child: Column(
        children: [
          _BoolRow(label: 'Platform supported (iOS)', value: supported),
          const Divider(height: 1),
          _InfoRow(label: 'Authorization', value: status.name),
          const Divider(height: 1),
          _InfoRow(label: 'Selected apps', value: '${selection.applications}'),
          const Divider(height: 1),
          _InfoRow(
            label: 'Selected categories',
            value: '${selection.categories}',
          ),
          const Divider(height: 1),
          _BoolRow(label: 'Shield active (this session)', value: shieldActive),
        ],
      ),
    );
  }
}

class _BoolRow extends StatelessWidget {
  const _BoolRow({required this.label, required this.value});

  final String label;
  final bool value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppText.rowTitle)),
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? AppColors.primary : AppColors.danger,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppText.rowTitle)),
          Text(
            value,
            style: AppText.rowTitle.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.group),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.group),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(child: Text(label, style: AppText.rowTitle)),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageBlock extends StatelessWidget {
  const _MessageBlock({
    required this.emoji,
    required this.title,
    required this.body,
  });

  final String emoji;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.group),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 12),
          Text(title, style: AppText.headline, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(body, style: AppText.meta, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
