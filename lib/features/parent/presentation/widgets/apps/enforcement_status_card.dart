import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:safini/core/di/injection.dart';
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
          leading: Icon(
            active ? Icons.verified_user_outlined : Icons.warning_amber_rounded,
          ),
          title: Text(message),
          onTap: _load,
        ),
      ),
    );
  }
}
