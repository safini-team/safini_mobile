import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:safini/features/parent/domain/models/parent_tasks_response_model.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_state.dart';
import 'package:safini/features/parent/presentation/screens/tasks/parent_tasks_view.dart';
import 'package:safini/features/parent/presentation/widgets/layout/parent_task_states.dart';
import 'package:safini/features/parent/presentation/widgets/tasks/review_sheet.dart';
import 'package:safini/features/parent/presentation/widgets/tasks/task_sheet.dart';
import 'package:safini/core/utils/task_category.dart';
import 'package:safini/core/utils/relative_date.dart';

/// Scope key used by the "Everyone" chip.
const String _allScope = 'all';

class ParentTasksScreen extends StatefulWidget {
  const ParentTasksScreen({super.key});

  @override
  State<ParentTasksScreen> createState() => _ParentTasksScreenState();
}

class _ParentTasksScreenState extends State<ParentTasksScreen> {
  String _scope = _allScope;
  TaskLane _lane = TaskLane.review;

  /// Until the parent picks a lane themselves, the screen opens on whichever
  /// one has something in it. Landing on an empty "To review" was the default
  /// on most days.
  bool _laneChosenByUser = false;

  Future<void> _reload() {
    final cubit = context.read<ParentTasksCubit>();
    return _scope == _allScope
        ? cubit.loadAllTasks()
        : cubit.loadTasks(childId: _scope);
  }

  void _selectScope(String scope) {
    if (scope == _scope) return;
    setState(() => _scope = scope);
    unawaited(_reload());
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocConsumer<ParentTasksCubit, ParentTasksState>(
      listener: (context, state) => _onState(context, state, s),
      builder: (context, state) {
        if (state is ParentTasksLoading || state is ParentTasksInitial) {
          return const ParentTasksSkeleton();
        }

        if (state is ParentTasksError) {
          return ParentTasksErrorState(
            message: state.message,
            canRetry: state.canRetry && !state.isUnauthorized,
            onRetry: _reload,
          );
        }

        final loaded = loadedTasksOf(state);
        if (loaded == null) return const ParentTasksSkeleton();

        return ParentTasksView(
          data: _buildData(context, loaded),
          onSelectScope: _selectScope,
          onSelectLane: (lane) => setState(() {
            _lane = lane;
            _laneChosenByUser = true;
          }),
          onOpenTask: (row) => _openTask(context, loaded, row.id),
          onNewTask: () => _openTask(context, loaded, null),
          onRefresh: _reload,
        );
      },
    );
  }

  void _onState(BuildContext context, ParentTasksState state, S s) {
    if ((state is ParentTasksError && state.isUnauthorized) ||
        (state is ParentTaskActionError && state.isUnauthorized)) {
      final message = state is ParentTasksError
          ? state.message
          : (state as ParentTaskActionError).message;
      unawaited(context.read<AuthSessionCubit>().forceSignOut(message));
      context.router.replace(const NamedRoute('login'));
      return;
    }
    if (state is ParentTaskActionError && state.isConflict) {
      AppSnackBar.warning(context, s.approvedTaskConflict);
    }
    if (state is ParentTaskSaved) {
      AppSnackBar.success(
        context,
        state.wasCreate ? s.taskCreatedMessage : s.taskUpdatedMessage,
      );
    }
    if (state is ParentTaskDeleted) {
      AppSnackBar.info(context, s.taskDeletedMessage);
    }
    if (state is ParentTaskReviewed) {
      if (state.isApproved) {
        AppSnackBar.success(context, s.taskApprovedMessage);
      } else {
        AppSnackBar.error(context, s.taskRejectedMessage);
      }
    }
  }

  Future<void> _openTask(
    BuildContext context,
    ParentTasksLoaded loaded,
    String? taskId,
  ) async {
    final cubit = context.read<ParentTasksCubit>();

    if (taskId == null) {
      await showTaskSheet(context, cubit: cubit, childId: _childIdFor(loaded));
      return;
    }

    final task = loaded.tasks.where((t) => t.id == taskId).firstOrNull;
    if (task == null) return;

    if (task.isPendingApproval) {
      await showReviewSheet(context, cubit: cubit, task: task);
      return;
    }
    if (task.isEditable) {
      await showTaskSheet(
        context,
        cubit: cubit,
        childId: task.childId ?? _childIdFor(loaded),
        task: task.toTaskModel(),
      );
    }
  }

  String _childIdFor(ParentTasksLoaded loaded) =>
      _scope == _allScope ? loaded.childId : _scope;

  ParentTasksData _buildData(BuildContext context, ParentTasksLoaded loaded) {
    final s = S.of(context);

    final children = context
        .watch<ParentFamilyCubit>()
        .state
        .family
        ?.children
        .where((child) => child.id.isNotEmpty)
        .toList() ??
        const [];

    // In all-children mode the cubit tags each task with its child's name; in
    // single-child mode every task belongs to the loaded child.
    String childNameOf(ParentTaskInstanceModel task) =>
        loaded.childNames[task.id] ?? loaded.childName;

    TaskLane laneOf(ParentTaskInstanceModel task) => task.isPendingApproval
        ? TaskLane.review
        : task.isCompleted
        ? TaskLane.done
        : TaskLane.active;

    final counts = {
      TaskLane.review: loaded.pendingApproval.length,
      TaskLane.active: loaded.activeTasks.length,
      TaskLane.done: loaded.completedTasks.length,
    };

    final lane = _laneChosenByUser
        ? _lane
        : (counts[TaskLane.review]! > 0 ? TaskLane.review : TaskLane.active);

    final rows = loaded.tasks
        .where((task) => laneOf(task) == lane)
        .map(
          (task) => TaskRowData(
            id: task.id,
            title: task.displayTitle,
            meta: _metaFor(context, s, task),
            emoji: task.emoji ?? '📋',
            lane: laneOf(task),
            coins: task.rewardCoins ?? 0,
            childName: childNameOf(task),
          ),
        )
        .toList();

    // Group in family order so the cards do not reshuffle between filters.
    final order = children.map((child) => child.nickname).toList();
    final groups = <TaskGroupData>[];
    for (final name in [
      ...order,
      if (order.isEmpty) loaded.childName,
    ]) {
      final groupRows = rows.where((row) => row.childName == name).toList();
      if (groupRows.isEmpty) continue;
      final child = children.where((c) => c.nickname == name).firstOrNull;
      groups.add(
        TaskGroupData(
          name: name,
          color: AppColors.kidColor(child?.id ?? name),
          rows: groupRows,
          summary: s.taskGroupSummary(
            s.taskCount(groupRows.length),
            s.coinCountShort(
              groupRows.fold(0, (sum, row) => sum + row.coins),
            ),
          ),
        ),
      );
    }

    final scopeName = _scope == _allScope
        ? s.scopeEveryone
        : children.where((c) => c.id == _scope).firstOrNull?.nickname ??
              loaded.childName;

    return ParentTasksData(
      scopeLine: s.taskScopeLine(scopeName, s.taskCount(loaded.tasks.length)),
      chips: [
        TaskScopeChip(
          key: _allScope,
          label: s.scopeEveryone,
          hasAvatar: false,
        ),
        for (final child in children)
          TaskScopeChip(
            key: child.id,
            label: child.nickname,
            color: AppColors.kidColor(child.id),
          ),
      ],
      selectedScope: _scope,
      laneCounts: counts,
      lane: lane,
      groups: groups,
      emptyTitle: switch (lane) {
        TaskLane.review => s.emptyNothingToReview,
        TaskLane.active => s.emptyNoActiveTasks,
        TaskLane.done => s.emptyNothingPaidYet,
      },
      emptyBody: switch (lane) {
        TaskLane.review => s.emptyReviewBody,
        TaskLane.active => s.emptyActiveBody,
        TaskLane.done => s.emptyDoneBody,
      },
    );
  }

  /// "Home · Today", not "home · 2026-08-23". The row used to print the raw
  /// category slug and an ISO date, untranslated, in all three languages.
  String _metaFor(BuildContext context, S s, ParentTaskInstanceModel task) {
    final parts = <String>[
      taskCategoryLabel(s, task.category),
      relativeDateLabel(context, s, DateTime.tryParse(task.dueOn ?? '')),
      if (task.recurrence == 'daily') s.repeatDailyShort,
      if (task.recurrence == 'weekly') s.repeatWeeklyShort,
    ].where((part) => part.isNotEmpty).toList();
    return parts.join(' · ');
  }
}

/// Pulls the underlying loaded snapshot out of any task state.
ParentTasksLoaded? loadedTasksOf(ParentTasksState state) => switch (state) {
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
