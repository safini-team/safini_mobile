import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:safini/features/models/data/dto/task_dto.dart';
import 'package:safini/features/models/domain/models/task_model.dart';
import 'package:safini/features/parent/domain/models/parent_tasks_response_model.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_state.dart';
import 'package:safini/features/parent/presentation/widgets/selectable_pill.dart';
import 'package:safini/features/parent/presentation/widgets/tiles/parent_task_tile.dart';

class ParentTasksScreen extends StatelessWidget {
  const ParentTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocProvider(
      create: (context) => getIt<ParentTasksCubit>()..loadTasks(),
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
                              context.read<ParentTasksCubit>().loadTasks(),
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
                              context.read<ParentTasksCubit>().loadTasks(),
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
    return ParentTaskTile(
      title: task.displayTitle,
      category: task.category,
      rewardCoins: task.rewardCoins,
      statusLabel: task.status,
      isPending: task.isPendingApproval,
      isCompleted: task.isCompleted,
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

// ── Task bottom sheet (create + edit) ─────────────────────────────────────────

/// Opens the create/edit task sheet. [task] == null → CREATE; otherwise EDIT.
Future<void> showTaskSheet(
  BuildContext context, {
  required ParentTasksCubit cubit,
  required String childId,
  TaskModel? task,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: TaskSheet(childId: childId, task: task),
    ),
  );
}

Future<void> showReviewSheet(
  BuildContext context, {
  required ParentTasksCubit cubit,
  required ParentTaskInstanceModel task,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: ReviewSheet(task: task),
    ),
  );
}

class ReviewSheet extends StatefulWidget {
  final ParentTaskInstanceModel task;

  const ReviewSheet({super.key, required this.task});

  @override
  State<ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<ReviewSheet> {
  final _noteController = TextEditingController();
  bool? _approving;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit(bool approve) async {
    setState(() => _approving = approve);
    await context.read<ParentTasksCubit>().reviewTask(
      widget.task.id,
      approve: approve,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocListener<ParentTasksCubit, ParentTasksState>(
      listener: (context, state) {
        if (state is ParentTaskReviewed) {
          Navigator.of(context).pop();
        } else if (state is ParentTaskActionError &&
            !state.isConflict &&
            !state.isUnauthorized) {
          setState(() => _approving = null);
          AppSnackBar.error(context, state.message);
        }
      },
      child: BlocBuilder<ParentTasksCubit, ParentTasksState>(
        builder: (context, state) {
          final isBusy = state is ParentTaskReviewing;
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xl),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.xl,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Header
                      Row(
                        children: [
                          Text(
                            s.reviewTaskSheetTitle,
                            style: context.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              fontSize: 22,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: isBusy
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F2F5),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      // Task summary card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: context.colorScheme.primary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.task_alt_rounded,
                                color: context.colorScheme.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.task.displayTitle,
                                    style:
                                        context.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (widget.task.rewardCoins != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '🪙 ${widget.task.rewardCoins} coins',
                                      style:
                                          context.textTheme.bodySmall?.copyWith(
                                        color: context.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      // Note field
                      _SectionLabel(s.reviewNoteHint),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _noteController,
                        maxLines: 3,
                        maxLength: 2000,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: s.reviewNoteHint,
                          hintStyle: context.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(AppSpacing.lg),
                          counterStyle: context.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      // Approve button
                      _GradientButton(
                        label: s.approve,
                        isLoading: isBusy && _approving == true,
                        isEnabled: !isBusy,
                        onTap: isBusy ? null : () => _submit(true),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Reject button
                      _RejectButton(
                        label: s.reject,
                        isLoading: isBusy && _approving == false,
                        isEnabled: !isBusy,
                        onTap: isBusy ? null : () => _submit(false),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RejectButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback? onTap;

  const _RejectButton({
    required this.label,
    required this.isLoading,
    required this.isEnabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.55,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.error, width: 1.5),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: AppColors.error,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
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

class TaskSheet extends StatefulWidget {
  final String childId;

  /// When non-null the sheet is in EDIT mode, prefilled from this task.
  final TaskModel? task;

  const TaskSheet({super.key, required this.childId, this.task});

  bool get isEdit => task != null;

  @override
  State<TaskSheet> createState() => _TaskSheetState();
}

class _TaskSheetState extends State<TaskSheet> {
  final _titleController = TextEditingController();
  String? _selectedEmoji;
  String? _selectedCategory;
  int? _selectedCoins;

  static const _emojis = [
    '🧹',
    '📚',
    '✏️',
    '🎹',
    '🏃',
    '🔍',
    '🧮',
    '🎨',
    '⚽',
    '🛏️',
  ];
  static const _coinOptions = [10, 20, 30, 40, 50];

  bool get _canSubmit =>
      _titleController.text.trim().isNotEmpty && _selectedCoins != null;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    if (task != null) {
      _titleController.text = task.title;
      _selectedCategory = task.category;
      _selectedCoins = task.coinReward;
      final emoji = task.metadata?['emoji'];
      if (emoji is String && emoji.trim().isNotEmpty) {
        _selectedEmoji = emoji.trim();
      }
    }
    _titleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || _selectedCoins == null) return;
    final coins = _selectedCoins!.clamp(0, 100000);
    final cubit = context.read<ParentTasksCubit>();

    final original = widget.task;
    if (original == null) {
      // CREATE
      final request = TaskCreateRequestDto(
        title: title,
        category: _selectedCategory ?? 'other',
        taskType: 'custom',
        proofMode: 'text_image',
        verificationMode: 'parent_approval',
        coinReward: coins,
        xpReward: coins,
        metadata: _selectedEmoji != null ? {'emoji': _selectedEmoji} : null,
      );
      await cubit.createTask(widget.childId, request);
      return;
    }

    // EDIT — diff against the original task; send only what changed.
    final newCategory = _selectedCategory ?? original.category;
    final coinsChanged = coins != original.coinReward;
    final originalEmoji = original.metadata?['emoji'];
    final emojiChanged =
        _selectedEmoji != null && _selectedEmoji != originalEmoji;

    final request = TaskUpdateRequestDto(
      title: title != original.title ? title : null,
      category: newCategory != original.category ? newCategory : null,
      coinReward: coinsChanged ? coins : null,
      xpReward: coinsChanged ? coins : null,
      metadata: emojiChanged ? {'emoji': _selectedEmoji} : null,
    );

    if (request.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    await cubit.updateTask(original.id, request);
  }

  Future<void> _confirmAndDelete() async {
    final s = S.of(context);
    final cubit = context.read<ParentTasksCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Text(
          s.deleteTaskTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(s.deleteTaskBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              s.cancel,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              s.deleteTaskButton,
              style: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await cubit.deleteTask(widget.task!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocListener<ParentTasksCubit, ParentTasksState>(
      listener: (context, state) {
        if (state is ParentTaskSaved || state is ParentTaskDeleted) {
          Navigator.of(context).pop();
        } else if (state is ParentTaskActionError) {
          // Conflicts (approved task) close the sheet; the list screen shows
          // the message. Other errors stay so the parent can retry.
          if (state.isConflict) {
            Navigator.of(context).pop();
          } else if (!state.isUnauthorized) {
            AppSnackBar.error(context, state.message);
          }
        }
      },
      child: BlocBuilder<ParentTasksCubit, ParentTasksState>(
        builder: (context, state) {
          final isBusy =
              state is ParentTaskSaving || state is ParentTaskDeleting;
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xl),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.xl,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Header
                      Row(
                        children: [
                          Text(
                            widget.isEdit
                                ? s.editTaskSheetTitle
                                : s.createTaskSheetTitle,
                            style: context.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              fontSize: 22,
                            ),
                          ),
                          const Spacer(),
                          if (widget.isEdit) ...[
                            GestureDetector(
                              onTap: isBusy ? null : _confirmAndDelete,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.pill,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 16,
                                      color: AppColors.error,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      s.deleteTaskButton,
                                      style: const TextStyle(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                          ],
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F2F5),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ── Task Name ─────────────────────────────────────────
                      _SectionLabel(s.createTaskNameLabel),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _titleController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: s.createTaskNameHint,
                          hintStyle: context.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(AppSpacing.lg),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ── Emoji Picker ──────────────────────────────────────
                      _SectionLabel(s.createTaskPickEmojiLabel),
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        height: 56,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _emojis.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: AppSpacing.sm),
                          itemBuilder: (context, i) {
                            final emoji = _emojis[i];
                            return SelectablePill(
                              selected: _selectedEmoji == emoji,
                              isSquare: true,
                              onTap: () =>
                                  setState(() => _selectedEmoji = emoji),
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ── Category ──────────────────────────────────────────
                      _SectionLabel(s.createTaskCategoryTitle),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: _buildCategoryChips(s),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ── Reward ────────────────────────────────────────────
                      _SectionLabel(s.createTaskRewardLabel),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: _coinOptions.map((coins) {
                          return SelectablePill(
                            selected: _selectedCoins == coins,
                            onTap: () =>
                                setState(() => _selectedCoins = coins),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '🪙',
                                  style: TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 4),
                                Text('$coins'),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ── Submit ────────────────────────────────────────────
                      _GradientButton(
                        label: widget.isEdit
                            ? s.createTaskSaveButton
                            : s.createTaskAddButton,
                        isLoading: state is ParentTaskSaving,
                        isEnabled: _canSubmit && !isBusy,
                        onTap: _canSubmit && !isBusy ? _submit : null,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildCategoryChips(S s) {
    final labels = <String>[
      s.createTaskCategoryDailyChore,
      s.createTaskCategoryEducational,
      s.createTaskCategoryHobby,
      s.categoryFitness,
      s.categoryLogic,
      s.createTaskCategoryOther,
    ];
    const apiValues = <String>[
      'chore',
      'learn',
      'hobby',
      'fitness',
      'logic',
      'other',
    ];
    return List.generate(labels.length, (i) {
      final apiValue = apiValues[i];
      return SelectablePill(
        selected: _selectedCategory == apiValue,
        onTap: () => setState(() => _selectedCategory = apiValue),
        child: Text(labels[i], style: const TextStyle(fontSize: 13)),
      );
    });
  }
}

// ── Shared sheet sub-widgets ──────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontSize: 14,
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback? onTap;

  const _GradientButton({
    required this.label,
    required this.isLoading,
    required this.isEnabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.55,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.brandGradient,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
