import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';

class EarnMoreCoinsBanner extends StatelessWidget {
  final VoidCallback onGoToTasks;

  const EarnMoreCoinsBanner({super.key, required this.onGoToTasks});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Earn More Coins',
            style: context.textTheme.headlineSmall?.copyWith(
              color: context.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Complete your daily quests to earn more coins!',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onGoToTasks,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: context.colorScheme.primary,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
              child: Text(
                'Go to Tasks',
                style: context.textTheme.labelLarge?.copyWith(
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
