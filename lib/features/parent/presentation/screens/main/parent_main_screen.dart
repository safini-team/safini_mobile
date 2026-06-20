import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:auto_route/auto_route.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_state.dart';
import 'package:safini/core/utils/widgets/layout/app_nav_bar.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/features/parent/presentation/cubit/home/home_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/home/home_state.dart';
import 'package:safini/features/parent/presentation/cubit/parent_cubit.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_monitor_screen.dart';
import 'package:safini/features/parent/presentation/screens/tasks/parent_tasks_screen.dart';
import 'package:safini/features/parent/presentation/screens/apps/parent_apps_screen.dart';
import 'package:safini/features/parent/presentation/screens/family/parent_family_screen.dart';
import 'package:safini/core/translation/generated/l10n.dart';

class ParentMainScreen extends StatelessWidget {
  const ParentMainScreen({super.key});

  static const List<Widget> _screens = [
    ParentMonitorScreen(),
    ParentTasksScreen(),
    ParentAppsScreen(),
    ParentFamilyScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ParentHomeCubit()),
        BlocProvider(create: (_) => getIt<ParentCubit>()..loadProfile()),
      ],
      child: BlocListener<AuthSessionCubit, AuthSessionState>(
        listener: (context, state) {
          if (state.status == AuthSessionStatus.unauthenticated) {
            context.router.replaceAll([const NamedRoute('roleSelection')]);
          }
        },
        child: const _ParentMainView(),
      ),
    );
  }
}

class _ParentMainView extends StatelessWidget {
  const _ParentMainView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParentHomeCubit, ParentHomeState>(
      builder: (context, state) {
        final s = S.of(context);
        final cubit = context.read<ParentHomeCubit>();
        return Scaffold(
          body: IndexedStack(
            index: state.selectedIndex,
            children: ParentMainScreen._screens,
          ),
          bottomNavigationBar: AppNavBar(
            items: [
              AppNavBarItem(
                icon: Icons.grid_view_rounded,
                label: s.monitor,
                isSelected: state.selectedIndex == 0,
                onTap: () => cubit.selectTab(0),
              ),
              AppNavBarItem(
                icon: Icons.assignment_turned_in_outlined,
                label: s.tasks,
                isSelected: state.selectedIndex == 1,
                onTap: () => cubit.selectTab(1),
              ),
              AppNavBarItem(
                icon: Icons.smartphone_rounded,
                label: s.apps,
                isSelected: state.selectedIndex == 2,
                onTap: () => cubit.selectTab(2),
              ),
              AppNavBarItem(
                icon: Icons.people_alt_rounded,
                label: s.myFamily,
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
