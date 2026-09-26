import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/translation/generated/l10n.dart';

/// A stale heartbeat means unknown connectivity, not confirmed tampering.
class EnforcementStatusCard extends StatefulWidget {
  final String childId;
  const EnforcementStatusCard({super.key, required this.childId});
  @override
  State<EnforcementStatusCard> createState() => _EnforcementStatusCardState();
}

class _EnforcementStatusCardState extends State<EnforcementStatusCard>
    with WidgetsBindingObserver {
  String? _status;
  Map<String, dynamic>? _ios;
  Timer? _timer;
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _load());
  }

  @override
  void didUpdateWidget(covariant EnforcementStatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.childId != widget.childId) {
      _status = null;
      _ios = null;
      _load();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _load();
    }
  }

  Future<void> _load() async {
    if (_loading) return;
    _loading = true;
    final id = widget.childId;
    try {
      try {
        final ios = await getIt<Dio>().get<Map<String, dynamic>>(
          '/v1/children/$id/screen-time-status',
        );
        if (!mounted || widget.childId != id) return;
        final iosData = ios.data?["platform"] == "ios" ? ios.data : null;
        final installedAppsUpdatedAt = iosData == null
            ? null
            : await _installedAppsUpdatedAt(id);
        if (!mounted || widget.childId != id) return;
        setState(() {
          _ios = _isCurrentIosDevice(iosData, installedAppsUpdatedAt)
              ? iosData
              : null;
          if (_ios != null) _status = null;
        });
        if (_ios != null) return;
      } on DioException catch (_) {
        /* Android and pre-migration API fallback. */
      }
      final response = await getIt<Dio>().get<Map<String, dynamic>>(
        '/v1/children/$id/enforcement/status',
      );
      if (mounted && widget.childId == id) {
        setState(() => _status = response.data?['status'] as String?);
      }
    } catch (_) {
      if (mounted && widget.childId == id) {
        setState(() => _status = 'unknown');
      }
    } finally {
      _loading = false;
    }
  }

  /// A child can sign into Safini on a different phone. Both status records
  /// remain on the server, so the most recent device report decides which
  /// platform the parent should see.
  Future<DateTime?> _installedAppsUpdatedAt(String childId) async {
    try {
      final response = await getIt<Dio>().get<Map<String, dynamic>>(
        '/v1/children/$childId/installed-apps',
      );
      return DateTime.tryParse(response.data?['updated_at']?.toString() ?? '');
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ios != null) {
      final s = S.of(context);
      final reported = DateTime.tryParse(_ios!['updated_at']?.toString() ?? '');
      final recent =
          reported != null && DateTime.now().difference(reported).inMinutes < 5;
      final authorized = _ios!['authorization'] == 'approved';
      final active = authorized && _ios!['monitoring_active'] == true;
      if (active && recent) return const SizedBox.shrink();
      // Without Screen Time nothing is limited on the iPhone at all, so say
      // that and what fixes it, not a status label (SAF-191).
      final lastSeen = _iosLastSeen(context, reported);
      final statusLine = !authorized
          ? null
          : active
          ? s.iosScreenTimeOn
          : s.iosScreenTimeOff;
      final subtitle = [
        ?statusLine,
        if (lastSeen.isNotEmpty) lastSeen,
      ].join('\n');
      return _Banner(
        warning: !active,
        title: authorized ? s.iosScreenTimeParent : s.iosScreenTimeNotSetUp,
        subtitle: subtitle.isEmpty ? null : subtitle,
        onTap: _load,
      );
    }
    if (_status == null || _status == 'active') return const SizedBox.shrink();
    final s = S.of(context);
    final message = switch (_status) {
      'not_configured' => s.enforcementNotConfigured,
      'attention_required' => s.enforcementAttention,
      'offline' => s.enforcementOffline,
      'signed_out' => s.enforcementSignedOut,
      _ => s.enforcementUnknown,
    };
    return _Banner(warning: true, title: message, onTap: _load);
  }
}

/// One look for every platform: the iOS status used to render as a bare,
/// unstyled list tile.
class _Banner extends StatelessWidget {
  const _Banner({
    required this.warning,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final bool warning;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        bottom: false,
        child: ListTile(
          // Only the icon carries the state colour; the sentence stays ink.
          leading: warning
              ? const Icon(Icons.warning_amber_rounded, color: AppColors.warning)
              : const Icon(Icons.info_outline),
          title: Text(title),
          subtitle: subtitle == null ? null : Text(subtitle!),
          onTap: onTap,
        ),
      ),
    );
  }
}

bool _isCurrentIosDevice(
  Map<String, dynamic>? ios,
  DateTime? installedAppsUpdatedAt,
) {
  if (ios == null) return false;
  if (installedAppsUpdatedAt == null) return true;
  final iosUpdatedAt = DateTime.tryParse(ios['updated_at']?.toString() ?? '');
  if (iosUpdatedAt == null) return false;
  return !installedAppsUpdatedAt.isAfter(iosUpdatedAt);
}

String _iosLastSeen(BuildContext context, DateTime? reported) {
  if (reported == null) return '';
  final local = reported.toLocal();
  final material = MaterialLocalizations.of(context);
  final time = material.formatTimeOfDay(TimeOfDay.fromDateTime(local));
  final now = DateTime.now();
  final sameDay =
      local.year == now.year &&
      local.month == now.month &&
      local.day == now.day;
  if (sameDay) return time;
  return '${material.formatShortDate(local)} $time';
}
