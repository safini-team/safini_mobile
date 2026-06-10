import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_spacing.dart';

/// Single-select option chip used in the create-task sheet (emoji squares,
/// category pills, coin-reward pills). All selected/unselected styling lives
/// here; parents only pass [selected] and [onTap].
class SelectablePill extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final bool isSquare;
  final EdgeInsets? padding;

  const SelectablePill({
    super.key,
    required this.selected,
    required this.onTap,
    required this.child,
    this.isSquare = false,
    this.padding,
  });

  static const _unselectedBg = Color(0xFFF5F5F7);

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(isSquare ? AppRadius.lg : AppRadius.pill);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: isSquare ? 52 : null,
          height: isSquare ? 52 : null,
          padding: isSquare
              ? null
              : padding ??
                  const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
          alignment: isSquare ? Alignment.center : null,
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryLight : _unselectedBg,
            borderRadius: radius,
            border: Border.all(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(
              color: selected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
