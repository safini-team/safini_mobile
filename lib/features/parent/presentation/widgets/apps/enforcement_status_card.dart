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
        setState(() => _ios = ios.data?["platform"] == "ios" ? ios.data : null);
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
      final active =
          _ios!['authorization'] == 'approved' &&
          _ios!['monitoring_active'] == true;
      final statusLine = active ? s.iosScreenTimeOn : s.iosScreenTimeOff;
      final lastSeen = _iosLastSeen(context, reported);
      return Material(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          bottom: false,
          child: ListTile(
            leading: Icon(
              active && recent ? Icons.shield_outlined : Icons.info_outline,
            ),
            title: Text(s.iosScreenTimeParent),
            subtitle: Text(
              lastSeen.isEmpty ? statusLine : '$statusLine\n$lastSeen',
            ),
            onTap: _load,
          ),
        ),
      );
    }
    if (_status == null) return const SizedBox.shrink();
    final s = S.of(context);
    final active = _status == 'active';
    final message = switch (_status) {
      'active' => s.enforcementActive,
      'not_configured' => s.enforcementNotConfigured,
      'attention_required' => s.enforcementAttention,
      'offline' => s.enforcementOffline,
      _ => s.enforcementUnknown,
    };
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        bottom: false,
        child: ListTile(
          // Only the icon carries the state colour; the sentence stays ink.
          leading: Icon(
            active ? Icons.verified_user_outlined : Icons.warning_amber_rounded,
            color: active ? AppColors.success : AppColors.warning,
          ),
          title: Text(message),
          onTap: _load,
        ),
      ),
    );
  }
}

String _iosLastSeen(BuildContext context, DateTime? reported) {
  if (reported == null) return '';
  final local = reported.toLocal();
  final material = MaterialLocalizations.of(context);
  final time = material.formatTimeOfDay(TimeOfDay.fromDateTime(local));
  final now = DateTime.now();
  final sameDay =
      local.year == now.year && local.month == now.month && local.day == now.day;
  if (sameDay) return time;
  return '${material.formatShortDate(local)} $time';
}
