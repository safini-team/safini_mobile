import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/models/domain/models/installed_app.dart';
import 'package:safini/features/parent/data/app_data.dart';
import 'package:safini/features/parent/presentation/cubit/parent_installed_apps_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_installed_apps_state.dart';

/// Parent · read-only list of the apps installed on a child's device.
///
/// The child device enumerates its apps natively and uploads them; this screen
/// only reads that snapshot back. Pushed from the Limits screen.
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
            title: s.installedAppsTitle,
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
                          return _EmptyState(childName: childName);
                        }
                        return _AppsList(
                          apps: state.apps,
                          childName: childName,
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

class _AppsList extends StatelessWidget {
  const _AppsList({required this.apps, required this.childName});

  final List<InstalledApp> apps;
  final String childName;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

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
        DsOverline(s.installedAppsCount(apps.length)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: DsGroup(
            children: [
              for (final app in apps)
                DsRow(
                  title: app.appName.isEmpty ? app.packageName : app.appName,
                  subtitle: app.packageName,
                  subtitleStyle: AppText.metaSm.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  leading: DsEmojiTile(
                    emoji: AppData.getEmojiForApp(app.appName),
                    size: 36,
                    radius: AppRadius.sm,
                    fontSize: 18,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.childName});

  final String childName;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return _CenteredCard(
      emoji: '📱',
      title: s.installedAppsEmptyTitle,
      body: s.installedAppsEmptyBody(childName),
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
  });

  final String emoji;
  final String title;
  final String body;
  final Widget? action;

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
            ],
          ),
        ),
      ),
    );
  }
}
