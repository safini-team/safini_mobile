import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/features/parent/data/app_data.dart';
import 'package:safini/features/parent/domain/models/parent_tasks_response_model.dart';
import 'package:safini/features/parent/presentation/cubit/home/home_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_state.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_state.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart';
import 'package:safini/features/parent/presentation/widgets/layout/parent_monitor_states.dart';
import 'package:safini/features/parent/presentation/widgets/tasks/review_sheet.dart';

class ParentMonitorScreen extends StatelessWidget {
  const ParentMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<ParentMonitorCubit>()..loadMonitorData(),
        ),
        BlocProvider(
          create: (context) => getIt<ParentTasksCubit>()..loadTasks(),
        ),
      ],
      child: const _ParentMonitorView(),
    );
  }
}

class _ParentMonitorView extends StatelessWidget {
  const _ParentMonitorView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ParentMonitorCubit, ParentMonitorState>(
      // When the parent switches child, reload that child's tasks so the review
      // list and the stat row match the child on the card.
      listenWhen: (prev, curr) =>
          curr is ParentMonitorLoaded &&
          (prev is! ParentMonitorLoaded ||
              prev.selectedChild?.id != curr.selectedChild?.id),
      listener: (context, state) {
        final childId = (state as ParentMonitorLoaded).selectedChild?.id;
        if (childId != null) {
          context.read<ParentTasksCubit>().loadTasks(childId: childId);
        }
      },
      child: BlocBuilder<ParentMonitorCubit, ParentMonitorState>(
        builder: (context, state) {
          if (state is ParentMonitorNoChild) {
            return const ParentTodayEmpty();
          }
          if (state is! ParentMonitorLoaded) {
            return const ParentTodaySkeleton();
          }

          return BlocBuilder<ParentTasksCubit, ParentTasksState>(
            builder: (context, tasksState) => ParentTodayView(
              data: _buildData(context, state, tasksState),
              onSelectKid: (index) =>
                  context.read<ParentMonitorCubit>().selectChild(index),
              onOpenSettings: () =>
                  context.router.push(const NamedRoute('parentSettings')),
              onOpenLimits: () => context.read<ParentHomeCubit>().selectTab(2),
              onOpenReview: (review) => _openReview(context, review.id),
              onApproveReview: (review) => context
                  .read<ParentTasksCubit>()
                  .reviewTask(review.id, approve: true),
              onRefresh: () async {
                await context.read<ParentMonitorCubit>().loadMonitorData();
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

  static ParentTasksLoaded? _loadedOf(ParentTasksState state) => switch (state) {
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
  ) {
    final child = state.selectedChild;
    final tasks = _loadedOf(tasksState);

    final apps =
        state.appLimits.map((limit) {
          final name = (limit['name'] ?? '').toString();
          return TodayApp(
            name: name,
            emoji: AppData.getEmojiForApp(name),
            usedMinutes: (limit['used'] as int?) ?? 0,
            limitMinutes: (limit['limit'] as int?) ?? 0,
          );
        }).toList()
          ..sort((a, b) => b.usedMinutes.compareTo(a.usedMinutes));

    // No family-wide allowance exists yet, so the ring reads the child's total
    // against the sum of their per-app limits.
    final used = apps.fold<int>(0, (sum, app) => sum + app.usedMinutes);
    final limit = apps.fold<int>(0, (sum, app) => sum + app.limitMinutes);

    final reviews = (tasks?.pendingApproval ?? const <ParentTaskInstanceModel>[])
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

    return ParentTodayData(
      kids: [
        for (final kid in state.children)
          TodayKid(
            id: kid.id,
            name: kid.nickname,
            color: AppColors.kidColor(kid.id),
          ),
      ],
      selectedIndex: state.selectedIndex,
      kidName: child?.nickname ?? '',
      usedMinutes: used,
      limitMinutes: limit,
      topApp: apps.isEmpty || apps.first.usedMinutes == 0
          ? ''
          : apps.first.name,
      tasksDone: tasks?.completedTasks.length ?? 0,
      tasksTotal: tasks?.tasks.length ?? 0,
      coins: child?.coinsBalance ?? 0,
      streakDays: child?.currentStreakDays,
      reviews: reviews,
      apps: apps.take(3).toList(),
    );
  }
}
