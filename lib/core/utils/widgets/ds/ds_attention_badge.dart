import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_typography.dart';

/// Label for a red attention count: quiet at 0, capped at `9+`.
String? attentionBadgeLabel(int count) {
  if (count <= 0) return null;
  return count > 9 ? '9+' : '$count';
}

/// The Tasks-tab badge: an `AppColors.danger` pill.
class DsAttentionBadge extends StatelessWidget {
  const DsAttentionBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final label = attentionBadgeLabel(count);
    if (label == null) return const SizedBox.shrink();
    return Container(
      constraints: const BoxConstraints(minWidth: 17),
      height: 17,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: AppColors.textOnPrimary,
          height: 1,
          fontFeatures: AppText.tabular,
        ),
      ),
    );
  }
}
