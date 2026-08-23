import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/core/utils/widgets/skeleton/skeleton_loader.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';

/// Loading state for Parent · Today - the same silhouette as the real screen so
/// nothing jumps when the data lands.
class ParentTodaySkeleton extends StatelessWidget {
  const ParentTodaySkeleton({super.key});

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
                children: [
                  const SkeletonBox(width: 140, height: 13, radius: 4),
                  const SizedBox(height: 8),
                  const SkeletonBox(width: 120, height: 32, radius: 8),
                  const SizedBox(height: 24),
                  Row(
                    children: const [
                      SkeletonBox(width: 104, height: 38, radius: 100),
                      SizedBox(width: 8),
                      SkeletonBox(width: 104, height: 38, radius: 100),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const SkeletonBox(
                    height: 208,
                    radius: AppRadius.feature,
                  ),
                  const SizedBox(height: 34),
                  const SkeletonBox(width: 180, height: 20, radius: 6),
                  const SizedBox(height: 14),
                  const SkeletonBox(height: 150, radius: AppRadius.group),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// No child on the account yet. The design has no artboard for this, so it uses
/// the design's own empty-state card shape plus the primary button.
class ParentTodayEmpty extends StatelessWidget {
  const ParentTodayEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return DsScreen(
      slivers: [
        SliverToBoxAdapter(
          child: DsLargeTitle(
            title: s.tabToday,
            subtitle: s.noChildrenFoundYet,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              26,
              AppSpacing.gutter,
              0,
            ),
            child: DsCard(
              shadow: AppShadows.flat,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 30,
              ),
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryTint,
                      shape: BoxShape.circle,
                    ),
                    child: AppIcons.plus(size: 20),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    s.addChild,
                    style: AppText.headline,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s.noChildYetBody,
                    style: AppText.meta,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: DsPrimaryButton(
                      label: s.addChild,
                      onTap: () async {
                        final router = context.router;
                        final familyCubit = context.read<ParentFamilyCubit>();
                        final added = await router.push<bool>(
                          const NamedRoute('addChild'),
                        );
                        if (added == true) {
                          familyCubit.loadCurrentFamily(refresh: true);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
