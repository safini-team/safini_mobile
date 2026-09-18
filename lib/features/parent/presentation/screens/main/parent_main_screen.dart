import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:auto_route/auto_route.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/utils/widgets/ds/app_icons.dart';
import 'package:safini/core/utils/widgets/ds/ds_tab_bar.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_state.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/notifications/push_event.dart';
import 'package:safini/core/notifications/push_shell.dart';
import 'package:safini/features/parent/presentation/cubit/home/home_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/home/home_state.dart';
import 'package:safini/features/parent/presentation/cubit/parent_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_state.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_monitor_screen.dart';
import 'package:safini/features/parent/presentation/screens/tasks/parent_tasks_screen.dart';
import 'package:safini/features/parent/presentation/screens/apps/parent_apps_screen.dart';
import 'package:safini/features/parent/presentation/screens/family/parent_family_screen.dart';
import 'package:safini/core/translation/generated/l10n.dart';

class ParentMainScreen extends StatefulWidget {
  const ParentMainScreen({super.key});

  static const List<Widget> _screens = [
    ParentMonitorScreen(),
    ParentTasksScreen(),
    ParentAppsScreen(),
    ParentFamilyScreen(),
  ];

  /// Which tab a tapped push opens, by its index in [_screens].
  static int? tabFor(PushDestination destination) => switch (destination) {
    PushDestination.parentToday => 0,
    PushDestination.parentTasks => 1,
    PushDestination.parentLimits => 2,
    PushDestination.parentFamily => 3,
    _ => null,
  };

  @override
  State<ParentMainScreen> createState() => _ParentMainScreenState();
}

class _ParentMainScreenState extends State<ParentMainScreen>
    with WidgetsBindingObserver {
  late final PushShell _push = PushShell(
    tabFor: ParentMainScreen.tabFor,
    selectTab: (index) => _home.selectTab(index),
    // The Family tab only needs to be shown; it refreshes on its own.
    consumedHere: const {PushDestination.parentFamily},
  );
  late final ParentHomeCubit _home = ParentHomeCubit(
    initialIndex: _push.initialTab(0),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _push.attach();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Registers on first build and again whenever the app language changes,
    // because that is the language the next push is written in.
    _push.register(Localizations.localeOf(context).languageCode);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _push.resumed();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _push.dispose();
    _home.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _home),
        BlocProvider(create: (_) => getIt<ParentCubit>()..loadProfile()),
        // Hoisted so the Tasks tab and its badge read the same list.
        BlocProvider(create: (_) => getIt<ParentTasksCubit>()..loadAllTasks()),
      ],
      child: BlocListener<AuthSessionCubit, AuthSessionState>(
        listener: (context, state) {
          if (state.status == AuthSessionStatus.unauthenticated) {
            context.router.replaceAll([const NamedRoute('login')]);
          }
        },
        child: const _ParentMainView(),
      ),
    );
  }
}

class _ParentMainView extends StatelessWidget {
  const _ParentMainView();

  /// The red tab badge counts everything waiting on the parent, across kids.
  static int _reviewCount(ParentTasksState state) {
    final loaded = switch (state) {
      ParentTasksLoaded() => state,
      ParentTaskSaving() => state.base,
      ParentTaskSaved() => state.base,
      ParentTaskDeleting() => state.base,
      ParentTaskDeleted() => state.base,
      ParentTaskReviewing() => state.base,
      ParentTaskReviewed() => state.base,
      ParentTaskActionError() => state.base,
      _ => null,
    };
    return loaded?.pendingApproval.length ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParentHomeCubit, ParentHomeState>(
      builder: (context, state) {
        final s = S.of(context);
        final cubit = context.read<ParentHomeCubit>();

        return BlocBuilder<ParentTasksCubit, ParentTasksState>(
          builder: (context, tasksState) {
            return BlocBuilder<LocaleCubit, Locale?>(
              builder: (context, _) => Scaffold(
                backgroundColor: AppColors.bgParent,
                extendBody: true,
                body: IndexedStack(
                  index: state.selectedIndex,
                  children: ParentMainScreen._screens,
                ),
                bottomNavigationBar: DsTabBar(
                  currentIndex: state.selectedIndex,
                  onTap: cubit.selectTab,
                  items: [
                    DsTabItem(
                      label: s.tabToday,
                      builder: (color) => AppIcons.tabHome(color: color),
                    ),
                    DsTabItem(
                      label: s.tabTasks,
                      builder: (color) => AppIcons.tabTasksParent(color: color),
                      badge: _reviewCount(tasksState),
                    ),
                    DsTabItem(
                      label: s.tabLimits,
                      builder: (color) => AppIcons.tabLimits(color: color),
                    ),
                    DsTabItem(
                      label: s.tabFamily,
                      builder: (color) => AppIcons.tabFamily(color: color),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
