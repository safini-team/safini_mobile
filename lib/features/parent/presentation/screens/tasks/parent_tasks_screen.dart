import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:safini/features/parent/domain/models/parent_tasks_response_model.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_state.dart';
import 'package:safini/features/parent/presentation/widgets/tasks/review_sheet.dart';
import 'package:safini/features/parent/presentation/widgets/tasks/task_sheet.dart';
import 'package:safini/features/parent/presentation/widgets/tiles/parent_task_tile.dart';

class ParentTasksScreen extends StatelessWidget {
  const ParentTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocProvider(
      create: (context) => getIt<ParentTasksCubit>()..loadAllTasks(),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: context.colorScheme.primary.withValues(alpha: 0.9),
          body: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.colorScheme.primary.withValues(alpha: 0.8),
                      context.colorScheme.primary,
                    ],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 20, 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            s.tasksAndRewards,
                            style: context.textTheme.displaySmall?.copyWith(
                              color: context.colorScheme.onPrimary,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => _openCreateTaskSheet(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: context.colorScheme.onPrimary
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  s.newBtn,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: context.colorScheme.onPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: context.colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(36),
                      topRight: Radius.circular(36),
                    ),
                  ),
                  child: BlocConsumer<ParentTasksCubit, ParentTasksState>(
                    listener: (context, state) {
                      if (state is ParentTasksError && state.isUnauthorized) {
                        unawaited(
                          context.read<AuthSessionCubit>().forceSignOut(
                            state.message,
                          ),
                        );
                        context.router.replace(const NamedRoute('login'));
                      }
                      if (state is ParentTaskActionError &&
                          state.isUnauthorized) {
                        unawaited(
                          context.read<AuthSessionCubit>().forceSignOut(
                            state.message,
                          ),
                        );
                        context.router.replace(const NamedRoute('login'));
                      }
                      if (state is ParentTaskActionError && state.isConflict) {
                        AppSnackBar.warning(context, s.approvedTaskConflict);
                      }
                      if (state is ParentTaskSaved) {
                        AppSnackBar.success(
                          context,
                          state.wasCreate
                              ? s.taskCreatedMessage
                              : s.taskUpdatedMessage,
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
                    },
                    builder: (context, state) {
                      if (state is ParentTasksLoading ||
                          state is ParentTasksInitial) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (state is ParentTasksError) {
                        return _ErrorState(
                          message: state.message,
                          canRetry: state.canRetry && !state.isUnauthorized,
                          onRetry: () =>
                              context.read<ParentTasksCubit>().loadAllTasks(),
                        );
                      }

                      final loadedState = switch (state) {
                        ParentTasksLoaded s => s,
                        ParentTaskSaving s => s.base,
                        ParentTaskSaved s => s.base,
                        ParentTaskDeleting s => s.base,
                        ParentTaskDeleted s => s.base,
                        ParentTaskActionError s => s.base,
                        ParentTaskReviewing s => s.base,
                        ParentTaskReviewed s => s.base,
                        _ => null,
                      };

                      if (loadedState != null) {
                        return RefreshIndicator(
                          onRefresh: () =>
                              context.read<ParentTasksCubit>().loadAllTasks(),
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 28, 20, 100),
                            children: [
                              Text(
                                loadedState.childName,
                                style: context.textTheme.labelLarge?.copyWith(
                                  color: context.colorScheme.onSurface
                                      .withValues(alpha: 0.55),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 18),
                              if (loadedState.pendingApproval.isNotEmpty) ...[
                                _buildSectionHeader(
                                  context,
                                  icon: Icons.access_time_filled,
                                  iconColor: Colors.amber,
                                  title: s.pendingApproval,
                                  badgeCount:
                                      loadedState.pendingApproval.length,
                                  badgeColor: Colors.amber,
                                ),
                                const SizedBox(height: 16),
                                ...loadedState.pendingApproval.map(
                                  (t) => _buildInstanceTile(context, t),
                                ),
                                const SizedBox(height: 32),
                              ],
                              _buildSectionHeader(
                                context,
                                icon: Icons.today_rounded,
                                iconColor: context.colorScheme.tertiary,
                                title: s.tasks,
                                badgeCount:
                                    loadedState.activeTasks.length +
                                    loadedState.completedTasks.length,
                                badgeColor: const Color(0xFFF2F0FF),
                                badgeTextColor: const Color(0xFF8B46FF),
                              ),
                              const SizedBox(height: 16),
                              if (loadedState.activeTasks.isEmpty &&
                                  loadedState.completedTasks.isEmpty)
                                _EmptySection(message: s.noTasksYet)
                              else ...[
                                ...loadedState.activeTasks.map(
                                  (t) => _buildInstanceTile(context, t),
                                ),
                                ...loadedState.completedTasks.map(
                                  (t) => _buildInstanceTile(context, t),
                                ),
                              ],
                            ],
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openCreateTaskSheet(BuildContext context) async {
    final cubit = context.read<ParentTasksCubit>();
    final loaded = _loadedOf(cubit.state);
    if (loaded == null) return;
    await showTaskSheet(context, cubit: cubit, childId: loaded.childId);
  }

  ParentTaskTile _buildInstanceTile(
    BuildContext context,
    ParentTaskInstanceModel task,
  ) {
    // In all-children mode this tells the tile which child the task belongs to.
    final childName =
        _loadedOf(context.read<ParentTasksCubit>().state)?.childNames[task.id];
    return ParentTaskTile(
      title: task.displayTitle,
      category: task.category,
      rewardCoins: task.rewardCoins,
      isPending: task.isPendingApproval,
      isCompleted: task.isCompleted,
      emoji: task.emoji,
      childName: childName,
      onTap: task.isPendingApproval
          ? () {
              final cubit = context.read<ParentTasksCubit>();
              showReviewSheet(context, cubit: cubit, task: task);
            }
          : task.isEditable
              ? () {
                  final cubit = context.read<ParentTasksCubit>();
                  final loaded = _loadedOf(cubit.state);
                  if (loaded == null) return;
                  showTaskSheet(
                    context,
                    cubit: cubit,
                    childId: loaded.childId,
                    task: task.toTaskModel(),
                  );
                }
              : null,
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    double iconSize = 24,
    required String title,
    int? badgeCount,
    Color? badgeColor,
    Color? badgeTextColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: iconSize),
        const SizedBox(width: 12),
        Text(
          title,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: context.colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 8),
        if (badgeCount != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badgeCount.toString(),
              style: context.textTheme.labelLarge?.copyWith(
                color: badgeTextColor ?? context.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}

// ── List helper widgets ───────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final bool canRetry;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.canRetry,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: context.colorScheme.error,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (canRetry) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String message;

  const _EmptySection({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        message,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.onSurface.withValues(alpha: 0.55),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}


/// Pulls the underlying loaded snapshot out of any task state.
ParentTasksLoaded? _loadedOf(ParentTasksState state) {
  return switch (state) {
    ParentTasksLoaded s => s,
    ParentTaskSaving s => s.base,
    ParentTaskSaved s => s.base,
    ParentTaskDeleting s => s.base,
    ParentTaskDeleted s => s.base,
    ParentTaskActionError s => s.base,
    _ => null,
  };
}
