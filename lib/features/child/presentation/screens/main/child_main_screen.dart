import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:safini/core/utils/widgets/layout/app_nav_bar.dart';
import 'package:safini/features/child/presentation/cubit/home/home_cubit.dart';
import 'package:safini/features/child/presentation/cubit/home/home_state.dart';
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
    return BlocProvider(
      create: (_) => ChildHomeCubit(),
      child: BlocBuilder<LocaleCubit, Locale>(
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
          body: IndexedStack(
            index: state.selectedIndex,
            children: ChildMainScreen._screens,
          ),
          bottomNavigationBar: AppNavBar(
            items: [
              AppNavBarItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: s.home,
                isSelected: state.selectedIndex == 0,
                onTap: () => cubit.selectTab(0),
              ),
              AppNavBarItem(
                icon: Icons.check_box_outlined,
                activeIcon: Icons.check_box_rounded,
                label: s.tasks,
                isSelected: state.selectedIndex == 1,
                onTap: () => cubit.selectTab(1),
              ),
              AppNavBarItem(
                icon: Icons.shopping_bag_outlined,
                activeIcon: Icons.shopping_bag_rounded,
                label: s.store,
                isSelected: state.selectedIndex == 2,
                onTap: () => cubit.selectTab(2),
              ),
              AppNavBarItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: s.profile,
                isSelected: state.selectedIndex == 3,
                onTap: () => cubit.selectTab(3),
              ),
            ],
          ),
        );
      },
    );
  }
}
