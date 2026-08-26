import 'package:flutter/material.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/features/child/data/services/app_block_service.dart';
import 'package:safini/features/models/domain/models/installed_app.dart';
import 'package:safini/features/parent/data/app_data.dart';

/// DEV-ONLY diagnostic screen.
///
/// Verifies that the child device can actually enumerate the apps installed on
/// it, exercising [AppBlockService.installedApps] (the native `installedApps`
/// MethodChannel backed by `PackageManager` + `QUERY_ALL_PACKAGES`). It also
/// surfaces the two special-permission states for quick reference.
///
/// This screen is reachable from Kid · Me only in debug builds (see the
/// `kDebugMode` guard in `ChildMeSettings`), so it never appears in release.
class ChildAppsDebugScreen extends StatefulWidget {
  const ChildAppsDebugScreen({super.key});

  @override
  State<ChildAppsDebugScreen> createState() => _ChildAppsDebugScreenState();
}

class _ChildAppsDebugScreenState extends State<ChildAppsDebugScreen> {
  final AppBlockService _service = getIt<AppBlockService>();

  bool _loading = true;
  String? _error;
  List<InstalledApp> _apps = const [];
  bool _usageAccess = false;
  bool _overlay = false;
  int _elapsedMs = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final sw = Stopwatch()..start();
    try {
      final apps = await _service.installedApps();
      final usageAccess = await _service.hasUsageAccess();
      final overlay = await _service.hasOverlayPermission();
      sw.stop();
      if (!mounted) return;

      final sorted = [...apps]..sort(
        (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()),
      );
      setState(() {
        _apps = sorted;
        _usageAccess = usageAccess;
        _overlay = overlay;
        _elapsedMs = sw.elapsedMilliseconds;
        _loading = false;
      });
    } catch (e) {
      sw.stop();
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgChild,
      appBar: AppBar(
        backgroundColor: AppColors.bgChild,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'DEV · Installed apps',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Reload',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _load,
          color: AppColors.primary,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            children: [
              _StatusCard(
                supported: _service.isSupported,
                usageAccess: _usageAccess,
                overlay: _overlay,
                appCount: _apps.length,
                elapsedMs: _elapsedMs,
                loading: _loading,
              ),
              const SizedBox(height: 16),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (_error != null)
                _MessageBlock(
                  emoji: '⚠️',
                  title: 'Enumeration failed',
                  body: _error!,
                )
              else if (!_service.isSupported)
                const _MessageBlock(
                  emoji: '🤖',
                  title: 'Android only',
                  body:
                      'installedApps() returns an empty list on this platform. '
                      'Run on an Android device to test enumeration.',
                )
              else if (_apps.isEmpty)
                const _MessageBlock(
                  emoji: '📭',
                  title: 'No apps returned',
                  body:
                      'The native handler returned nothing. Check that '
                      'MainActivity handles "installedApps" and that '
                      'QUERY_ALL_PACKAGES is declared.',
                )
              else
                ..._apps.map((app) => _AppRow(app: app)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.supported,
    required this.usageAccess,
    required this.overlay,
    required this.appCount,
    required this.elapsedMs,
    required this.loading,
  });

  final bool supported;
  final bool usageAccess;
  final bool overlay;
  final int appCount;
  final int elapsedMs;
  final bool loading;

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
          _StatusRow(label: 'Platform supported (Android)', value: supported),
          const Divider(height: 1),
          _StatusRow(label: 'Usage access granted', value: usageAccess),
          const Divider(height: 1),
          _StatusRow(label: 'Overlay permission granted', value: overlay),
          const Divider(height: 1),
          _InfoRow(
            label: 'Apps returned',
            value: loading ? '…' : '$appCount',
          ),
          const Divider(height: 1),
          _InfoRow(
            label: 'Load time',
            value: loading ? '…' : '$elapsedMs ms',
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value});

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

class _AppRow extends StatelessWidget {
  const _AppRow({required this.app});

  final InstalledApp app;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.fill,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              AppData.getEmojiForApp(app.appName),
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.appName.isEmpty ? app.packageName : app.appName,
                  style: AppText.rowTitle,
                ),
                const SizedBox(height: 2),
                Text(
                  app.packageName,
                  style: AppText.metaSm.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
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
