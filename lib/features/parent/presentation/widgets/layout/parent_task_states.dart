import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/core/utils/widgets/skeleton/skeleton_loader.dart';

/// Loading silhouette for Parent · Tasks.
class ParentTasksSkeleton extends StatelessWidget {
  const ParentTasksSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScreen(
      animateEntrance: false,
      slivers: [
        SliverToBoxAdapter(
          child: Skeleton(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.textGutter,
                6,
                AppSpacing.textGutter,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: 120, height: 32, radius: 8),
                  SizedBox(height: 10),
                  SkeletonBox(width: 200, height: 14, radius: 4),
                  SizedBox(height: 20),
                  SkeletonBox(height: 38, radius: 100),
                  SizedBox(height: 14),
                  SkeletonBox(height: 42, radius: AppRadius.md),
                  SizedBox(height: 24),
                  SkeletonBox(height: 132, radius: AppRadius.group),
                  SizedBox(height: 16),
                  SkeletonBox(height: 132, radius: AppRadius.group),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Load failure with a retry, in the design's card language.
class ParentTasksErrorState extends StatelessWidget {
  const ParentTasksErrorState({
    super.key,
    required this.message,
    required this.canRetry,
    required this.onRetry,
  });

  final String message;
  final bool canRetry;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return DsScreen(
      slivers: [
        SliverToBoxAdapter(child: DsLargeTitle(title: s.tabTasks)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              24,
              AppSpacing.gutter,
              0,
            ),
            child: DsCard(
              shadow: AppShadows.flat,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 26,
              ),
              child: Column(
                children: [
                  Text(
                    message,
                    style: AppText.rowTitleStrong,
                    textAlign: TextAlign.center,
                  ),
                  if (canRetry) ...[
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: DsPrimaryButton(label: s.tryAgain, onTap: onRetry),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
