import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/utils/constants/app_constants.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/features/parent/data/app_data.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_state.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/screens/apps/parent_installed_apps_screen.dart';
import 'package:safini/features/parent/presentation/screens/apps/parent_limits_view.dart';
import 'package:safini/features/parent/presentation/widgets/apps/add_app_sheet.dart';
import 'package:safini/features/parent/presentation/widgets/apps/app_limit_sheet.dart';

class ParentAppsScreen extends StatelessWidget {
  const ParentAppsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ParentAppsCubit>()..loadAppLimits(),
      child: const _ParentLimitsView(),
    );
  }
}

class _ParentLimitsView extends StatelessWidget {
  const _ParentLimitsView();

  Future<void> _setCap(
    BuildContext context,
    ParentAppsCubit cubit,
    int? minutes,
  ) async {
    final error = await cubit.setScreenTimeCap(minutes);
    if (error != null && context.mounted) {
      AppSnackBar.error(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParentAppsCubit, ParentAppsState>(
      builder: (context, state) {
        if (state is! ParentAppsLoaded) {
          return const ParentLimitsSkeleton();
        }

        final cubit = context.read<ParentAppsCubit>();
        final children =
            context
                .watch<ParentFamilyCubit>()
                .state
                .family
                ?.children
                .where((child) => child.id.isNotEmpty)
                .toList() ??
            const [];

        final selectedId = cubit.childId;
        final selected = children
            .where((child) => child.id == selectedId)
            .firstOrNull;

        // Read-only "apps on this phone" list. Hidden until the backend
        // installed-apps endpoint is live (see AppConstants).
        final VoidCallback? onSeeAllApps =
            AppConstants.childInstalledAppsShipped &&
                selectedId != null &&
                selectedId.isNotEmpty
            ? () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ParentInstalledAppsScreen(
                    childId: selectedId,
                    childName: selected?.nickname ?? '',
                  ),
                ),
              )
            : null;

        final apps = state.appLimits.map((limit) {
          final name = (limit['name'] ?? '').toString();
          return LimitsApp(
            slug: (limit['slug'] ?? '').toString(),
            name: name,
            emoji: AppData.getEmojiForApp(name),
            usedMinutes: (limit['used'] as int?) ?? 0,
            limitMinutes: (limit['limit'] as int?) ?? 0,
            isLimited: limit['isLimited'] as bool? ?? true,
            canRedeem: limit['canRedeem'] as bool? ?? true,
            redeemCoinCost: (limit['cost'] as int?) ?? 100,
            redeemRewardMinutes: (limit['reward'] as int?) ?? 30,
          );
        }).toList();

        return ParentLimitsView(
          data: ParentLimitsData(
            kids: [
              for (final child in children)
                LimitsKid(
                  id: child.id,
                  name: child.nickname,
                  color: AppColors.kidColor(child.id),
                ),
            ],
            selectedKidId: selectedId,
            kidName: selected?.nickname ?? '',
            apps: apps,
            capMinutes: state.screenTime.limitMinutes,
          ),
          onSelectKid: cubit.selectChild,
          onSetCap: (minutes) => _setCap(context, cubit, minutes),
          onOpenApp: (app) => showAppLimitSheet(
            context,
            cubit: cubit,
            app: app,
            childName: selected?.nickname ?? '',
          ),
          onAddApp: () => showAddAppSheet(context, cubit: cubit),
          onRefresh: () => cubit.loadAppLimits(),
          onSeeAllApps: onSeeAllApps,
        );
      },
    );
  }
}
