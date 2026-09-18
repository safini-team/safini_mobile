import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/notifications/push_event.dart';
import 'package:safini/core/notifications/push_shell.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/utils/widgets/ds/app_icons.dart';
import 'package:safini/core/utils/widgets/ds/ds_tab_bar.dart';
import 'package:safini/features/child/domain/controllers/child_controller.dart';
import 'package:safini/features/child/presentation/cubit/app_block_cubit.dart';
import 'package:safini/features/child/presentation/cubit/coins_cubit.dart';
import 'package:safini/features/child/presentation/cubit/home/home_cubit.dart';
import 'package:safini/features/child/presentation/cubit/home/home_state.dart';
import 'package:safini/features/child/presentation/cubit/profile_cubit.dart';
import 'package:safini/features/child/presentation/cubit/reward_store_cubit.dart';
import 'package:safini/features/child/presentation/screens/blocking/child_app_block_gate.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_state.dart';
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

  /// Which tab a tapped push opens, by its index in [_screens].
  static int? tabFor(PushDestination destination) => switch (destination) {
    PushDestination.childToday => 0,
    PushDestination.childTasks => 1,
    _ => null,
  };

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
        BlocProvider(create: (_) => getIt<ChildAppBlockCubit>()..start()),
      ],
      // A child account can be deleted by its parent while this shell is open.
      // The session then ends under the child's feet, same as the parent shell
      // (parent_main_screen.dart), so leave for the login screen.
      child: BlocListener<AuthSessionCubit, AuthSessionState>(
        listener: (context, state) {
          if (state.status == AuthSessionStatus.unauthenticated) {
            context.router.replaceAll([const NamedRoute('login')]);
          }
        },
        child: BlocBuilder<LocaleCubit, Locale?>(
          builder: (context, locale) {
            return Localizations.override(
              context: context,
              locale: locale,
              // Outside the gate: a child still setting up app limits should
              // already hear about the tasks their parent is adding.
              child: const _ChildPushBridge(
                child: ChildAppBlockGate(child: _ChildMainView()),
              ),
            );
          },
        ),
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

/// Registers the child's phone for pushes and opens the tab a tapped one is
/// about. The Tasks tab takes a task id itself, to open that task.
class _ChildPushBridge extends StatefulWidget {
  const _ChildPushBridge({required this.child});

  final Widget child;

  @override
  State<_ChildPushBridge> createState() => _ChildPushBridgeState();
}

class _ChildPushBridgeState extends State<_ChildPushBridge>
    with WidgetsBindingObserver {
  late final PushShell _push = PushShell(
    tabFor: ChildMainScreen.tabFor,
    selectTab: (index) => context.read<ChildHomeCubit>().selectTab(index),
    consumedHere: const {PushDestination.childToday},
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final tab = _push.initialTab(-1);
    if (tab >= 0) context.read<ChildHomeCubit>().selectTab(tab);
    _push.attach();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
