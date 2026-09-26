import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/notifications/on_push.dart';
import 'package:safini/core/notifications/push_deep_links.dart';
import 'package:safini/core/notifications/push_event.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/utils/constants/app_constants.dart';
import 'package:safini/features/parent/data/app_data.dart';
import 'package:safini/features/parent/presentation/cubit/home/home_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/home/home_state.dart';
import 'package:safini/features/parent/presentation/widgets/apps/enforcement_status_card.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_state.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/screens/apps/parent_installed_apps_screen.dart';
import 'package:safini/features/parent/presentation/screens/apps/parent_limits_view.dart';
import 'package:safini/features/parent/presentation/widgets/apps/app_limit_sheet.dart';
import 'package:safini/features/prizes/parent_prizes_cubit.dart';
import 'package:safini/features/prizes/prize.dart';
import 'package:safini/features/prizes/widgets/parent_prize_list.dart';
import 'package:safini/features/prizes/widgets/prize_sheets.dart';

class ParentAppsScreen extends StatefulWidget {
  const ParentAppsScreen({super.key});

  @override
  State<ParentAppsScreen> createState() => _ParentAppsScreenState();
}

class _ParentAppsScreenState extends State<ParentAppsScreen> {
  late final ParentAppsCubit _cubit = getIt<ParentAppsCubit>()
    // A protection or limit push names the child it is about, so open on that
    // child rather than whoever was selected last.
    ..loadAppLimits(
      childId:
          getIt<PushDeepLinks>().take(PushDestination.parentLimits)?.childId ??
          context.read<ParentHomeCubit>().state.selectedChildId,
    );
  final ParentPrizesCubit _prizes = ParentPrizesCubit(getIt<PrizeApi>());
  StreamSubscription<PushTarget>? _deepLinks;

  @override
  void initState() {
    super.initState();
    // Covers a push tapped while this tab is already built.
    _deepLinks = getIt<PushDeepLinks>().stream
        .where((target) => target.destination == PushDestination.parentLimits)
        .listen((_) {
          final childId = getIt<PushDeepLinks>()
              .take(PushDestination.parentLimits)
              ?.childId;
          if (childId != null && mounted) {
            context.read<ParentHomeCubit>().selectChild(childId);
            _cubit.selectChild(childId);
          }
        });
  }

  @override
  void dispose() {
    _deepLinks?.cancel();
    _cubit.close();
    _prizes.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cubit),
        BlocProvider.value(value: _prizes),
      ],
      // Minutes used and what is locked just changed on the child's phone.
      child: BlocListener<ParentHomeCubit, ParentHomeState>(
        listenWhen: (previous, current) =>
            current.selectedIndex == 2 &&
            (previous.selectedIndex != 2 ||
                previous.selectedChildId != current.selectedChildId),
        listener: (context, home) {
          // Coming back within a few seconds keeps what is on screen.
          if (_cubit.isFreshFor(home.selectedChildId)) return;
          _cubit.loadAppLimits(childId: home.selectedChildId);
        },
        child: OnPush(
          types: const {
            PushType.appLimitReached,
            PushType.screenTimeReached,
            PushType.protectionAlert,
          },
          onPush: (event) {
            if (event.childId == _cubit.childId) _cubit.loadAppLimits();
          },
          child: const _ParentLimitsView(),
        ),
      ),
    );
  }
}

class _ParentLimitsView extends StatefulWidget {
  const _ParentLimitsView();

  @override
  State<_ParentLimitsView> createState() => _ParentLimitsViewState();
}

class _ParentLimitsViewState extends State<_ParentLimitsView> {
  bool _showingPrizes = false;

  @override
  void initState() {
    super.initState();
    _takePrizesRequest();
  }

  /// "Add a prize" on the Today checklist opens this tab on Prizes.
  void _takePrizesRequest() {
    final home = context.read<ParentHomeCubit>();
    if (!home.state.showPrizes) return;
    _showingPrizes = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => home.prizesShown());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ParentHomeCubit, ParentHomeState>(
      listenWhen: (previous, current) =>
          current.showPrizes && !previous.showPrizes,
      listener: (context, _) => setState(_takePrizesRequest),
      child: _buildLimits(context),
    );
  }

  Widget _buildLimits(BuildContext context) {
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
        final prizes = context.watch<ParentPrizesCubit>();
        final childName = selected?.nickname ?? '';
        if (_showingPrizes &&
            selectedId != null &&
            prizes.state.childId != selectedId) {
          prizes.load(selectedId);
        }

        // Every installed app with a rule slug is tappable (add / edit / block),
        // so the pushed screen keeps this ParentAppsCubit alive.
        final VoidCallback? onAddApp =
            AppConstants.childInstalledAppsShipped &&
                selectedId != null &&
                selectedId.isNotEmpty
            ? () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: cubit,
                    child: ParentInstalledAppsScreen(
                      childId: selectedId,
                      childName: selected?.nickname ?? '',
                    ),
                  ),
                ),
              )
            : null;

        final apps = state.appLimits.map((limit) {
          final name = (limit['name'] ?? '').toString();
          return LimitsApp(
            usageAvailable: state.screenTime.usageAvailable,
            slug: (limit['slug'] ?? '').toString(),
            name: name,
            emoji: AppData.getEmojiForApp(name),
            usedMinutes: (limit['used'] as int?) ?? 0,
            limitMinutes: (limit['limit'] as int?) ?? 0,
            isBlocked: limit['isBlocked'] == true,
            isLimited: limit['isLimited'] as bool? ?? true,
            canRedeem: limit['canRedeem'] as bool? ?? true,
            redeemCoinCost: (limit['cost'] as int?) ?? 100,
            redeemRewardMinutes: (limit['reward'] as int?) ?? 30,
            iconUrl: limit['icon'] as String?,
          );
        }).toList();

        return Column(
          children: [
            if (selectedId != null && !_showingPrizes)
              EnforcementStatusCard(
                key: ValueKey(selectedId),
                childId: selectedId,
              ),
            Expanded(
              child: ParentLimitsView(
                data: ParentLimitsData(
                  usageAvailable: state.screenTime.usageAvailable,
                  configurationAvailable:
                      state.screenTime.configurationAvailable != false,
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
                  usedMinutes: state.screenTime.usedMinutes,
                  remainingMinutes: state.screenTime.remainingMinutes,
                  nextResetAt: state.screenTime.nextResetAt,
                ),
                onSelectKid: (id) {
                  context.read<ParentHomeCubit>().selectChild(id);
                },
                onSetCap: selectedId == null ? null : cubit.setScreenTimeCap,
                onOpenApp: (app) => showAppLimitSheet(
                  context,
                  cubit: cubit,
                  app: app,
                  childName: selected?.nickname ?? '',
                ),
                onAddApp: onAddApp,
                onRefresh: () => _showingPrizes
                    ? prizes.load()
                    : cubit.loadAppLimits(),
                showingPrizes: _showingPrizes,
                onShowPrizes: selectedId == null
                    ? null
                    : (show) {
                        setState(() => _showingPrizes = show);
                        if (show) prizes.load(selectedId);
                      },
                prizeSlivers: parentPrizeSlivers(
                  context,
                  state: prizes.state,
                  childName: childName,
                  onAdd: () => showNewPrizeChooser(
                    context,
                    cubit: prizes,
                    childName: childName,
                  ),
                  onOpen: (prize) => showPrizeEditor(
                    context,
                    cubit: prizes,
                    childName: childName,
                    prize: prize,
                  ),
                  onIdea: (idea) => showPrizeEditor(
                    context,
                    cubit: prizes,
                    childName: childName,
                    idea: idea,
                  ),
                  onRetry: prizes.load,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
