import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/utils/widgets/ds/app_icons.dart';
import 'package:safini/core/utils/widgets/ds/ds_tab_bar.dart';
import 'package:safini/features/child/domain/controllers/child_controller.dart';
import 'package:safini/features/child/presentation/cubit/coins_cubit.dart';
import 'package:safini/features/child/presentation/cubit/home/home_cubit.dart';
import 'package:safini/features/child/presentation/cubit/home/home_state.dart';
import 'package:safini/features/child/presentation/cubit/profile_cubit.dart';
import 'package:safini/features/child/presentation/cubit/reward_store_cubit.dart';
import 'package:safini/features/common/auth/presentation/cubit/child_claim_cubit.dart';
import 'package:safini/features/common/profile/data/repositories/profile_repository.dart';
import 'package:safini/features/child/presentation/screens/home/child_home_screen.dart';
import 'package:safini/features/child/presentation/screens/tasks/child_tasks_screen.dart';
import 'package:safini/features/child/presentation/screens/store/child_reward_store_screen.dart';
import 'package:safini/features/child/presentation/screens/profile/child_profile_screen.dart';
import 'package:safini/core/translation/generated/l10n.dart';

class ChildMainScreen extends StatelessWidget {
  const ChildMainScreen({super.key});

  static const List<Widget> _screens = [
    ChildHomeScreen(),
    ChildTasksScreen(),
    ChildRewardStoreScreen(),
    ChildProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ChildHomeCubit()),
        // Hoisted: Today reads the streak from the profile and the "Almost
        // yours" teaser from the store, and the Store tab shares both.
        BlocProvider(
          create: (context) => ProfileCubit(
            getIt<ChildController>(),
            getIt<ProfileRepository>(),
            getIt<CoinsCubit>(),
            getIt<Dio>(),
          )..loadProfile(
            fallbackChild: context.read<ChildClaimCubit>().state.child,
          ),
        ),
        BlocProvider(create: (_) => getIt<RewardStoreCubit>()),
      ],
      child: BlocBuilder<LocaleCubit, Locale?>(
        builder: (context, locale) {
          return Localizations.override(
            context: context,
            locale: locale,
            child: const _ChildMainView(),
          );
        },
      ),
    );
  }
}

class _ChildMainView extends StatelessWidget {
  const _ChildMainView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChildHomeCubit, ChildHomeState>(
      builder: (context, state) {
        final s = S.of(context);
        final cubit = context.read<ChildHomeCubit>();

        return Scaffold(
          backgroundColor: AppColors.bgChild,
          // The tab bar is translucent, so the content has to run underneath it.
          extendBody: true,
          body: IndexedStack(
            index: state.selectedIndex,
            children: ChildMainScreen._screens,
          ),
          bottomNavigationBar: DsTabBar.child(
            currentIndex: state.selectedIndex,
            onTap: cubit.selectTab,
            items: [
              DsTabItem(
                label: s.tabToday,
                builder: (color) => AppIcons.tabHome(color: color),
              ),
              DsTabItem(
                label: s.tabTasks,
                builder: (color) => AppIcons.tabTasksChild(color: color),
              ),
              DsTabItem(
                label: s.tabStore,
                builder: (color) => AppIcons.tabStore(color: color),
              ),
              DsTabItem(
                label: s.tabMe,
                builder: (color) => AppIcons.tabMe(color: color),
              ),
            ],
          ),
        );
      },
    );
  }
}
