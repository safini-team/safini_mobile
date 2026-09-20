import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/app_icons/app_icon_tile.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
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
/// reads that snapshot back. Every controllable row opens the add or edit flow
/// on the shared `ParentAppsCubit` (provided by the Limits screen), under the
/// slug the API names for that app (`InstalledApp.ruleSlug`). Phone, Messages
/// and Settings are listed as always allowed and offer no limit. Pushed from
/// the Limits screen.
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
      child: _ParentInstalledAppsView(childName: childName),
    );
  }
}

class _ParentInstalledAppsView extends StatelessWidget {
  const _ParentInstalledAppsView({required this.childName});

  final String childName;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.bgParent,
      body: Column(
        children: [
          DsNavBar(
            title: s.addAnAppLimit,
            backLabel: s.tabLimits,
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: DsScreenEntrance(
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
        ],
      ),
    );
  }
}

class _AppsList extends StatefulWidget {
  const _AppsList({
    required this.apps,
    required this.childName,
    this.updatedAt,
  });

  final List<InstalledApp> apps;
  final String childName;
  final DateTime? updatedAt;

  @override
  State<_AppsList> createState() => _AppsListState();
}

class _AppsListState extends State<_AppsList> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final syncedAt = widget.updatedAt;
    final cubit = context.read<ParentAppsCubit>();
    final filtered = widget.apps.where((app) {
      final query = _query.trim().toLowerCase();
      if (query.isEmpty) return true;
      return app.appName.toLowerCase().contains(query) ||
          app.packageName.toLowerCase().contains(query);
    }).toList();

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
            s.installedAppsSubtitle(widget.childName),
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
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            14,
            AppSpacing.gutter,
            0,
          ),
          child: TextField(
            key: const ValueKey('installed-app-search'),
            onChanged: (value) => setState(() => _query = value),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: s.installedAppsSearchHint,
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              filled: true,
              fillColor: AppColors.fill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ),
        DsOverline(s.installedAppsCount(filtered.length)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: filtered.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Text(
                    s.installedAppsNoMatch,
                    textAlign: TextAlign.center,
                    style: AppText.meta,
                  ),
                )
              : DsGroup(
                  children: [
                    for (final app in filtered)
                      _InstalledAppRow(
                        app: app,
                        slug: app.ruleSlug,
                        configured:
                            app.ruleSlug != null &&
                            cubit.ruleForSlug(app.ruleSlug!) != null,
                        onTap: () => _handleTap(context, app),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  /// Opens an existing rule or a draft that is persisted only when saved.
  Future<void> _handleTap(BuildContext context, InstalledApp app) async {
    final s = S.of(context);
    if (app.alwaysAllowed) {
      AppSnackBar.info(context, s.installedAppsAlwaysAllowedInfo);
      return;
    }
    final slug = app.ruleSlug;
    if (slug == null) {
      AppSnackBar.info(context, s.installedAppsNotControllable);
      return;
    }

    final cubit = context.read<ParentAppsCubit>();
    final existing = cubit.ruleForSlug(slug);
    final label = app.appName.isEmpty ? app.packageName : app.appName;

    if (existing != null) {
      await showAppLimitSheet(
        context,
        cubit: cubit,
        app: _limitsAppFor(existing, label, app.iconUrl),
        childName: widget.childName,
      );
      return;
    }

    await showAppLimitSheet(
      context,
      cubit: cubit,
      app: LimitsApp(
        slug: slug,
        name: label,
        emoji: AppData.getEmojiForApp(label),
        usedMinutes: 0,
        limitMinutes: 60,
        isLimited: true,
        canRedeem: true,
        redeemCoinCost: 100,
        redeemRewardMinutes: 30,
        iconUrl: app.iconUrl,
      ),
      childName: widget.childName,
      isNew: true,
    );
    if (mounted) setState(() {});
  }

  LimitsApp _limitsAppFor(
    ChildAppUsageModel rule,
    String fallbackName,
    String? fallbackIconUrl,
  ) {
    final name = rule.displayName.isEmpty ? fallbackName : rule.displayName;
    return LimitsApp(
      slug: rule.appSlug,
      name: name,
      emoji: AppData.getEmojiForApp(name),
      usedMinutes: rule.usedMinutes,
      limitMinutes: rule.dailyLimitMinutes,
      isBlocked: rule.isBlocked,
      isLimited: rule.isLimited,
      canRedeem: rule.canRedeem,
      redeemCoinCost: rule.redeemCoinCost,
      redeemRewardMinutes: rule.redeemRewardMinutes,
      iconUrl: rule.iconUrl ?? fallbackIconUrl,
    );
  }
}

class _InstalledAppRow extends StatelessWidget {
  const _InstalledAppRow({
    required this.app,
    required this.slug,
    required this.onTap,
    required this.configured,
  });

  final InstalledApp app;
  final String? slug;
  final VoidCallback onTap;
  final bool configured;

  @override
  Widget build(BuildContext context) {
    return DsRow(
      title: app.appName.isEmpty ? app.packageName : app.appName,
      subtitle: app.packageName,
      subtitleStyle: AppText.metaSm.copyWith(color: AppColors.textTertiary),
      leading: AppIconTile(
        emoji: AppData.getEmojiForApp(app.appName),
        iconUrl: app.iconUrl,
        size: 36,
        radius: AppRadius.sm,
        fontSize: 18,
      ),
      trailing: app.alwaysAllowed
          ? Text(
              S.of(context).installedAppsAlwaysAllowed,
              style: AppText.metaSm.copyWith(color: AppColors.textTertiary),
            )
          : slug != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (configured) ...[
                  Text(
                    S.of(context).installedAppsLimited,
                    style: AppText.metaSm.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(width: 4),
                ],
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.textTertiary,
                ),
              ],
            )
          : null,
      onTap: onTap,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.childName, this.endpointMissing = false});

  final String childName;
  final bool endpointMissing;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return _CenteredCard(
      emoji: '📱',
      title: s.installedAppsEmptyTitle,
      body: s.installedAppsEmptyBody(childName),
      // Dev-only: the empty state looks identical whether the child has never
      // synced or the GET 404'd. Say which, so "parent sees nothing" is quick
      // to pin down.
      footnote: !kDebugMode
          ? null
          : endpointMissing
          ? 'DEV: GET /installed-apps → 404 (endpoint not deployed, or wrong '
                'child id).'
          : 'DEV: GET ok, snapshot empty — the child device has not uploaded. '
                'The auto-upload runs once on child-shell mount and never on '
                'iOS; use the child DEV · Installed apps screen to force it.',
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
