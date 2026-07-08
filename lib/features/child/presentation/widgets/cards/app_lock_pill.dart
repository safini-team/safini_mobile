import 'package:flutter/material.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';

/// A small pill with a lock icon, shown on an app-time card when redemptions
/// are disabled for that app.
class AppLockPill extends StatelessWidget {
  const AppLockPill({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = context.colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: muted.withValues(alpha: 0.2)),
      ),
      child: Icon(
        Icons.lock_outline_rounded,
        size: 18,
        color: muted.withValues(alpha: 0.5),
      ),
    );
  }
}
