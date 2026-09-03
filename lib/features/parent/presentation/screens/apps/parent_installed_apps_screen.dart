import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/constants/controlled_apps.dart';
import 'package:safini/core/utils/relative_date.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/models/domain/models/installed_app.dart';
import 'package:safini/features/parent/data/app_data.dart';
import 'package:safini/features/parent/domain/models/child_app_usage_model.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_installed_apps_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_installed_apps_state.dart';
import 'package:safini/features/parent/presentation/screens/apps/parent_limits_view.dart';
import 'package:safini/features/parent/presentation/widgets/apps/app_limit_sheet.dart';

/// Parent · list of the apps installed on a child's device.
///
/// The child device enumerates its apps natively and uploads them; this screen
/// reads that snapshot back. Rows for apps that map to a backend catalog slug
/// (`ControlledApps.slugFor`) are tappable — they open the add / limit / block
/// flow on the shared `ParentAppsCubit` (provided by the Limits screen). Other
/// rows are informational only. Pushed from the Limits screen.
class ParentInstalledAppsScreen extends StatelessWidget {
  const ParentInstalledAppsScreen({
    super.key,
    required this.childId,
    required this.childName,
  });

  final String childId;
  final String childName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ParentInstalledAppsCubit>()..load(childId),
      child: _ParentInstalledAppsView(childId: childId, childName: childName),
    );
  }
}

class _ParentInstalledAppsView extends StatelessWidget {
  const _ParentInstalledAppsView({
    required this.childId,
    required this.childName,
  });

  final String childId;
  final String childName;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.bgParent,
      body: Column(
        children: [
          DsNavBar(
            title: s.installedAppsTitle,
            backLabel: s.tabLimits,
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: DsScreenEntrance(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () =>
                    context.read<ParentInstalledAppsCubit>().refresh(),
                child:
                    BlocBuilder<
                      ParentInstalledAppsCubit,
                      ParentInstalledAppsState
                    >(
                      builder: (context, state) {
                        if (state is ParentInstalledAppsError) {
                          return _ErrorState(message: state.message);
                        }
                        if (state is ParentInstalledAppsLoaded) {
                          if (state.isEmpty) {
                            return _EmptyState(
                              childId: childId,
                              childName: childName,
                              endpointMissing: state.endpointMissing,
                            );
                          }
                          return _AppsList(
                            apps: state.apps,
                            childName: childName,
                            updatedAt: state.updatedAt,
                          );
                        }
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        );
                      },
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppsList extends StatelessWidget {
  const _AppsList({
    required this.apps,
    required this.childName,
    this.updatedAt,
  });

  final List<InstalledApp> apps;
  final String childName;
  final DateTime? updatedAt;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final syncedAt = updatedAt;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.only(bottom: 40),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.textGutter,
            14,
            AppSpacing.textGutter,
            0,
          ),
          child: Text(
            s.installedAppsSubtitle(childName),
            style: AppText.subtitle,
          ),
        ),
        if (syncedAt != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.textGutter,
              4,
              AppSpacing.textGutter,
              0,
            ),
            child: Text(
              s.installedAppsLastSynced(
                relativeDateLabel(context, s, syncedAt.toLocal()),
              ),
              style: AppText.metaSm.copyWith(color: AppColors.textTertiary),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.textGutter,
            8,
            AppSpacing.textGutter,
            0,
          ),
          child: Text(
            s.installedAppsTapHint,
            style: AppText.metaSm.copyWith(color: AppColors.textTertiary),
          ),
        ),
        DsOverline(s.installedAppsCount(apps.length)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: DsGroup(
            children: [
              for (final app in apps)
                _InstalledAppRow(
                  app: app,
                  slug: ControlledApps.slugFor(app.packageName),
                  onTap: () => _handleTap(context, app),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// A catalog-mapped app opens the add / limit / block flow; anything else
  /// just explains that Safini can't limit it yet.
  void _handleTap(BuildContext context, InstalledApp app) {
    final s = S.of(context);
    final slug = ControlledApps.slugFor(app.packageName);
    if (slug == null) {
      AppSnackBar.info(context, s.installedAppsNotControllable);
      return;
    }

    final cubit = context.read<ParentAppsCubit>();
    final existing = cubit.ruleForSlug(slug);
    final label = app.appName.isEmpty ? app.packageName : app.appName;

    if (existing != null) {
      showAppLimitSheet(
        context,
        cubit: cubit,
        app: _limitsAppFor(existing, label),
        childName: childName,
      );
      return;
    }

    showDsSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(s.installedAppsAddTitle(label), style: AppText.title3),
          const SizedBox(height: 8),
          Text(s.installedAppsAddBody, style: AppText.bodyRegular),
          const SizedBox(height: 22),
          DsPrimaryButton(
            label: s.installedAppsSetLimit,
            onTap: () {
              Navigator.of(sheetContext).pop();
              _addRule(context, cubit, slug, label, block: false);
            },
          ),
          const SizedBox(height: 10),
          DsPrimaryButton.secondary(
            label: s.installedAppsBlockCompletely,
            onTap: () {
              Navigator.of(sheetContext).pop();
              _addRule(context, cubit, slug, label, block: true);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _addRule(
    BuildContext context,
    ParentAppsCubit cubit,
    String slug,
    String label, {
    required bool block,
  }) async {
    final error = await cubit.addApp(
      slug: slug,
      name: label,
      dailyLimitMinutes: 60,
      redeemCoinCost: 100,
      redeemRewardMinutes: 30,
      isLimited: !block,
      canRedeem: !block,
    );
    if (!context.mounted) return;

    final s = S.of(context);
    if (error != null) {
      AppSnackBar.error(context, error);
      return;
    }
    if (block) {
      AppSnackBar.success(context, s.installedAppsBlockedSnack(label));
      return;
    }
    // Limit added with a default — open the sheet so the parent can tune it.
    final rule = cubit.ruleForSlug(slug);
    if (rule != null) {
      showAppLimitSheet(
        context,
        cubit: cubit,
        app: _limitsAppFor(rule, label),
        childName: childName,
      );
    }
  }

  LimitsApp _limitsAppFor(ChildAppUsageModel rule, String fallbackName) {
    final name = rule.displayName.isEmpty ? fallbackName : rule.displayName;
    return LimitsApp(
      slug: rule.appSlug,
      name: name,
      emoji: AppData.getEmojiForApp(name),
      usedMinutes: rule.usedMinutes,
      limitMinutes: rule.dailyLimitMinutes,
      isLimited: rule.isLimited,
      canRedeem: rule.canRedeem,
      redeemCoinCost: rule.redeemCoinCost,
      redeemRewardMinutes: rule.redeemRewardMinutes,
    );
  }
}

class _InstalledAppRow extends StatelessWidget {
  const _InstalledAppRow({
    required this.app,
    required this.slug,
    required this.onTap,
  });

  final InstalledApp app;
  final String? slug;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DsRow(
      title: app.appName.isEmpty ? app.packageName : app.appName,
      subtitle: app.packageName,
      subtitleStyle: AppText.metaSm.copyWith(color: AppColors.textTertiary),
      leading: DsEmojiTile(
        emoji: AppData.getEmojiForApp(app.appName),
        size: 36,
        radius: AppRadius.sm,
        fontSize: 18,
      ),
      trailing: slug != null
          ? const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textTertiary,
            )
          : null,
      onTap: onTap,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.childId,
    required this.childName,
    this.endpointMissing = false,
  });

  final String childId;
  final String childName;
  final bool endpointMissing;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return _CenteredCard(
      emoji: '📱',
      title: s.installedAppsEmptyTitle,
      body: s.installedAppsEmptyBody(childName),
      action: DsPrimaryButton.secondary(
        label: s.tryAgain,
        onTap: () => context.read<ParentInstalledAppsCubit>().refresh(),
      ),
      // Dev-only: the empty state looks identical whether the child has never
      // synced or the GET 404'd. Print which, plus the child_id we queried —
      // "parent sees nothing" is almost always a child_id mismatch between the
      // parent's selected child and the child device's own /me child_id.
      footnote: !kDebugMode
          ? null
          : endpointMissing
          ? 'DEV: GET /children/$childId/installed-apps → 404 '
                '(endpoint down, or this child_id does not exist).'
          : 'DEV: GET ok for child_id=$childId, but the snapshot is empty. '
                'Compare with the "child_id=" line on the child DEV · Installed '
                'apps screen — if they differ, the parent has the wrong child '
                'selected. The auto-upload also runs only once per child-app '
                'session and never on iOS.',
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return _CenteredCard(
      emoji: '⚠️',
      title: s.genericErrorRetry,
      body: message,
      action: DsPrimaryButton.secondary(
        label: s.tryAgain,
        onTap: () => context.read<ParentInstalledAppsCubit>().refresh(),
      ),
    );
  }
}

class _CenteredCard extends StatelessWidget {
  const _CenteredCard({
    required this.emoji,
    required this.title,
    required this.body,
    this.action,
    this.footnote,
  });

  final String emoji;
  final String title;
  final String body;
  final Widget? action;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.gutter,
          vertical: 40,
        ),
        child: DsCard(
          shadow: AppShadows.flat,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primaryTint,
                  shape: BoxShape.circle,
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(height: 14),
              Text(title, style: AppText.headline, textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text(body, style: AppText.meta, textAlign: TextAlign.center),
              if (action != null) ...[const SizedBox(height: 20), action!],
              if (footnote != null) ...[
                const SizedBox(height: 16),
                Text(
                  footnote!,
                  style: AppText.metaSm.copyWith(color: AppColors.textTertiary),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
