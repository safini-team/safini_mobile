import 'package:safini/features/parent/presentation/cubit/home/home_state.dart';
import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/notifications/on_push.dart';
import 'package:safini/core/notifications/push_deep_links.dart';
import 'package:safini/core/notifications/push_event.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/features/parent/data/app_data.dart';
import 'package:safini/features/parent/domain/models/parent_tasks_response_model.dart';
import 'package:safini/features/parent/presentation/cubit/home/home_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_state.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_state.dart';
import 'package:safini/core/utils/widgets/on_app_resume.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart';
import 'package:safini/features/parent/presentation/screens/monitor/pending_review_counts.dart';
import 'package:safini/features/parent/presentation/widgets/layout/parent_monitor_states.dart';
import 'package:safini/features/parent/presentation/widgets/tasks/review_sheet.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/features/prizes/prize.dart';
import 'package:safini/features/prizes/prize_asks_cubit.dart';
import 'package:safini/features/prizes/widgets/prize_sheets.dart';

class ParentMonitorScreen extends StatelessWidget {
  const ParentMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          // A tapped weekly digest opens on the child it summarises.
          create: (context) => getIt<ParentMonitorCubit>()
            ..loadMonitorData(
              childId:
                  getIt<PushDeepLinks>()
                      .take(PushDestination.parentToday)
                      ?.childId ??
                  context.read<ParentHomeCubit>().state.selectedChildId,
            ),
        ),
        BlocProvider(
          create: (_) => PrizeAsksCubit(getIt<PrizeApi>())..load(),
        ),
        // The tasks cubit comes from the shell: a second instance here meant
        // an approval on the Tasks tab never reached this card, and the tab
        // badge never heard about one made from Today.
      ],
      child: const _ParentMonitorView(),
    );
  }
}

class _ParentMonitorView extends StatelessWidget {
  const _ParentMonitorView();

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => OnAppResume(
        // Coins, streak and screen time all move while the parent is away.
        onResume: () {
          context.read<ParentMonitorCubit>().loadMonitorData();
          context.read<PrizeAsksCubit>().load();
        },
        // ...and when a push says a limit ran out or protection changed.
        child: OnPush(
          types: const {
            PushType.appLimitReached,
            PushType.screenTimeReached,
            PushType.protectionAlert,
            PushType.childConnected,
          },
          onPush: (_) => context.read<ParentMonitorCubit>().loadMonitorData(),
          child: OnPush(
            types: const {PushType.prizeRequested, PushType.wishRequested},
            onPush: (_) => context.read<PrizeAsksCubit>().load(),
            child: _TodayPushTarget(child: _buildContent(context)),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ParentHomeCubit, ParentHomeState>(
          listenWhen: (previous, current) =>
              current.selectedIndex == 0 &&
              (previous.selectedIndex != 0 ||
                  previous.selectedChildId != current.selectedChildId),
          listener: (context, home) => context
              .read<ParentMonitorCubit>()
              .loadMonitorData(childId: home.selectedChildId),
        ),
        BlocListener<ParentTasksCubit, ParentTasksState>(
          // Approving pays coins and moves the streak, and both of those live
          // on the monitor's child row, not in the tasks cubit. Without this
          // the card kept showing the pre-approval balance until the parent
          // pulled to refresh.
          listenWhen: (prev, curr) =>
              curr is ParentTaskReviewed ||
              curr is ParentTaskSaved ||
              curr is ParentTaskDeleted,
          listener: (context, _) =>
              context.read<ParentMonitorCubit>().loadMonitorData(),
        ),
      ],
      child: BlocBuilder<ParentMonitorCubit, ParentMonitorState>(
        builder: (context, state) {
          if (state is ParentMonitorNoChild) {
            return const ParentTodayEmpty();
          }
          if (state is! ParentMonitorLoaded) {
            return const ParentTodaySkeleton();
          }

          final asks = context.watch<PrizeAsksCubit>().state;
          return BlocBuilder<ParentTasksCubit, ParentTasksState>(
            builder: (context, tasksState) => ParentTodayView(
              data: _buildData(context, state, tasksState, asks),
              onSelectKid: (index) => context
                  .read<ParentHomeCubit>()
                  .selectChild(state.children[index].id),
              onOpenSettings: () =>
                  context.router.push(const NamedRoute('parentSettings')),
              onOpenLimits: () => context.read<ParentHomeCubit>().selectTab(2),
              onOpenReview: (review) => review.kind == TodayReviewKind.task
                  ? _openReview(context, review.id)
                  : _openAsk(context, asks, review.id),
              onApproveReview: (review) => review.kind == TodayReviewKind.task
                  ? context.read<ParentTasksCubit>().reviewTask(
                      review.id,
                      approve: true,
                    )
                  : _answerAsk(context, asks, review.id, approve: true),
              onDeclineReview: (review) =>
                  _answerAsk(context, asks, review.id, approve: false),
              onRefresh: () async {
                final prizeAsks = context.read<PrizeAsksCubit>();
                await context.read<ParentMonitorCubit>().loadMonitorData();
                await prizeAsks.load();
                if (context.mounted) {
                  await context.read<ParentTasksCubit>().loadTasks();
                }
              },
            ),
          );
        },
      ),
    );
  }

  void _openReview(BuildContext context, String taskId) {
    final cubit = context.read<ParentTasksCubit>();
    final task = _loadedOf(cubit.state)?.tasks.firstWhere(
      (t) => t.id == taskId,
      orElse: () => const ParentTaskInstanceModel(id: '', status: ''),
    );
    if (task == null || task.id.isEmpty) return;
    showReviewSheet(context, cubit: cubit, task: task);
  }

  Future<void> _openAsk(
    BuildContext context,
    List<PrizeRequest> asks,
    String id,
  ) async {
    final ask = asks.where((a) => a.id == id).firstOrNull;
    if (ask == null) return;
    final answer = await showPrizeAnswerSheet(context, request: ask);
    if (answer == null || !context.mounted) return;
    await _answerAsk(
      context,
      asks,
      id,
      approve: answer.approve,
      coinCost: answer.coins,
    );
  }

  Future<void> _answerAsk(
    BuildContext context,
    List<PrizeRequest> asks,
    String id, {
    required bool approve,
    int? coinCost,
  }) async {
    final ask = asks.where((a) => a.id == id).firstOrNull;
    if (ask == null) return;
    final s = S.of(context);
    final monitor = context.read<ParentMonitorCubit>();
    final error = await context.read<PrizeAsksCubit>().answer(
      ask,
      approve: approve,
      coinCost: coinCost,
    );
    if (!context.mounted) return;
    if (error != null) {
      AppSnackBar.error(context, error.isEmpty ? s.networkError : error);
      return;
    }
    // A decline puts coins back on the child's balance card.
    if (!approve) monitor.loadMonitorData();
  }

  static ParentTasksLoaded? _loadedOf(ParentTasksState state) =>
      switch (state) {
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

  ParentTodayData _buildData(
    BuildContext context,
    ParentMonitorLoaded state,
    ParentTasksState tasksState,
    List<PrizeRequest> asks,
  ) {
    final child = state.selectedChild;
    final tasks = _loadedOf(tasksState);

    final ruleApps = state.appLimits.map((limit) {
      final name = (limit['name'] ?? '').toString();
      return TodayApp(
        name: name,
        emoji: AppData.getEmojiForApp(name),
        usedMinutes: (limit['used'] as int?) ?? 0,
        limitMinutes: (limit['limit'] as int?) ?? 0,
        iconUrl: limit['icon'] as String?,
      );
    }).toList()..sort((a, b) => b.usedMinutes.compareTo(a.usedMinutes));

    // Every app the child opened, not only the ones with a rule. The rule rows
    // stand in when the device-usage request failed.
    final device = state.deviceUsage;
    final apps = device == null
        ? ruleApps.where((app) => app.usedMinutes > 0).toList()
        : [
            for (final app in device.apps)
              TodayApp(
                name: app.displayName,
                emoji: AppData.getEmojiForApp(app.displayName),
                usedMinutes: app.usedMinutes,
                limitMinutes: app.hasRule && app.isLimited && !app.isBlocked
                    ? app.dailyLimitMinutes ?? 0
                    : 0,
                iconUrl: app.iconUrl,
              ),
          ];

    // The list covers the whole family, so the card takes the selected
    // child's share of it rather than labelling someone else's task with
    // this child's name.
    final childTasks = (tasks?.tasks ?? const <ParentTaskInstanceModel>[])
        .where(
          (task) => child == null || (task.childId ?? child.id) == child.id,
        )
        .toList();

    final reviews = childTasks
        .where((task) => task.isPendingApproval)
        .map(
          (task) => TodayReview(
            id: task.id,
            title: task.displayTitle,
            meta: [
              child?.nickname ?? '',
              if ((task.category ?? '').isNotEmpty) task.category!,
            ].where((part) => part.isNotEmpty).join(' · '),
            kidName: child?.nickname ?? '',
            color: AppColors.kidColor(child?.id ?? child?.nickname),
            coins: task.rewardCoins ?? 0,
          ),
        )
        .toList();
    final s = S.of(context);
    for (final ask in asks) {
      if (child != null && ask.childId != child.id) continue;
      final name = ask.childNickname ?? child?.nickname ?? '';
      reviews.add(
        TodayReview(
          id: ask.id,
          title: '${ask.displayEmoji} ${ask.title}',
          meta: [
            name,
            ask.isWish ? s.wishLabel : s.prizeLabel,
          ].where((part) => part.isNotEmpty).join(' · '),
          kidName: name,
          color: AppColors.kidColor(ask.childId),
          coins: ask.coinCost,
          kind: ask.isWish ? TodayReviewKind.wish : TodayReviewKind.prize,
        ),
      );
    }

    return ParentTodayData(
      usageAvailable: state.screenTime.usageAvailable,
      configurationAvailable: state.screenTime.configurationAvailable != false,
      kids: [
        for (final kid in state.children)
          TodayKid(
            id: kid.id,
            name: kid.nickname,
            color: AppColors.kidColor(kid.id),
            pendingReviewCount: pendingReviewCountForChild(
              childId: kid.id,
              tasks: tasks?.tasks ?? const [],
              asks: asks,
            ),
          ),
      ],
      selectedIndex: state.selectedIndex,
      kidName: child?.nickname ?? '',
      usedMinutes: state.screenTime.usedMinutes,
      limitMinutes: state.screenTime.limitMinutes,
      remainingMinutes: state.screenTime.remainingMinutes,
      nextResetAt: state.screenTime.nextResetAt,
      topApp: apps.isEmpty || apps.first.usedMinutes == 0
          ? ''
          : apps.first.name,
      tasksDone: childTasks.where((task) => task.isCompleted).length,
      tasksTotal: childTasks.length,
      coins: child?.coinsBalance ?? 0,
      streakDays: child?.currentStreakDays,
      reviews: reviews,
      apps: state.screenTime.usageAvailable ? apps : [],
    );
  }
}

/// Switches Today to the child a digest tapped while the tab is open is about.
class _TodayPushTarget extends StatefulWidget {
  const _TodayPushTarget({required this.child});

  final Widget child;

  @override
  State<_TodayPushTarget> createState() => _TodayPushTargetState();
}

class _TodayPushTargetState extends State<_TodayPushTarget> {
  StreamSubscription<PushTarget>? _deepLinks;

  @override
  void initState() {
    super.initState();
    _deepLinks = getIt<PushDeepLinks>().stream
        .where((target) => target.destination == PushDestination.parentToday)
        .listen((_) {
          final target = getIt<PushDeepLinks>().take(
            PushDestination.parentToday,
          );
          if (target != null && mounted) {
            context.read<ParentHomeCubit>().selectChild(target.childId);
          }
        });
  }

  @override
  void dispose() {
    _deepLinks?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
