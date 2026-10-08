import 'dart:async';

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
import 'package:safini/features/subscription/free_limit.dart';
import 'package:safini/features/subscription/pro_cubit.dart';
import 'package:safini/core/notifications/push_event.dart';
import 'package:safini/core/notifications/push_deep_links.dart';
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
import 'package:safini/features/onboarding/first_run_tour.dart';
import 'package:safini/core/translation/generated/l10n.dart';

class ParentMainScreen extends StatefulWidget {
  const ParentMainScreen({super.key});

  /// Which tab a tapped push opens.
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
    initialChildId: getIt<PushDeepLinks>().pending?.childId,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _push.attach();
    // Reads this family's plan and picks up App Store renewals and purchases
    // that were left unfinished.
    getIt<ProCubit>().start();
    _freeLimits = FreeLimitAlerts.instance.stream.listen(_onFreeLimit);
  }

  StreamSubscription<FreeLimit>? _freeLimits;
  bool _freeLimitShown = false;

  /// A free-plan limit from any screen, even one pushed over this one. A
  /// task for several children can hit it once per child; one sheet is
  /// enough.
  Future<void> _onFreeLimit(FreeLimit limit) async {
    if (!mounted || _freeLimitShown) return;
    _freeLimitShown = true;
    await showFreeLimitSheet(
      context,
      limit,
      canBuy: getIt<ProCubit>().canSell,
    );
    _freeLimitShown = false;
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
    _freeLimits?.cancel();
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

class _ParentMainView extends StatefulWidget {
  const _ParentMainView();

  @override
  State<_ParentMainView> createState() => _ParentMainViewState();
}

class _ParentMainViewState extends State<_ParentMainView> {
  final _tabBarKey = GlobalKey();
  final _reviewKey = GlobalKey();

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
              builder: (context, _) {
                // One list feeds both the bar and the tour, so the tour's
                // spotlight always matches the number of tabs.
                final tabs = [
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
                ];
                return FirstRunTour(
                  role: TourRole.parent,
                  userId: context.read<AuthSessionCubit>().state.userId,
                  selectedTab: state.selectedIndex,
                  onSelectTab: cubit.selectTab,
                  onOpenGifts: cubit.openPrizes,
                  tabBarKey: _tabBarKey,
                  tabCount: tabs.length,
                  reviewKey: _reviewKey,
                  child: Scaffold(
                    backgroundColor: AppColors.bgParent,
                    extendBody: true,
                    body: IndexedStack(
                      index: state.selectedIndex,
                      children: [
                        ParentMonitorScreen(reviewKey: _reviewKey),
                        const ParentTasksScreen(),
                        const ParentAppsScreen(),
                        const ParentFamilyScreen(),
                      ],
                    ),
                    bottomNavigationBar: KeyedSubtree(
                      key: _tabBarKey,
                      child: DsTabBar(
                        currentIndex: state.selectedIndex,
                        onTap: cubit.selectTab,
                        items: tabs,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
