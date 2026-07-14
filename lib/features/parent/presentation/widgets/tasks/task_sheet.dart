import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/features/models/data/dto/task_dto.dart';
import 'package:safini/features/models/domain/models/family_model.dart';
import 'package:safini/features/models/domain/models/task_model.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_state.dart';
import 'package:safini/features/parent/presentation/widgets/buttons/gradient_button.dart';
import 'package:safini/features/parent/presentation/widgets/selectable_pill.dart';
import 'package:safini/features/parent/presentation/widgets/tasks/task_section_label.dart';

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

  // Children this task can target. `_targetChildId == null` means "all children".
  List<ChildSummaryModel> _children = const [];
  String? _targetChildId;

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
    _children = context
            .read<ParentFamilyCubit>()
            .state
            .family
            ?.children
            .where((c) => c.id.isNotEmpty)
            .toList() ??
        const [];
    // Default target: the child the sheet was opened for.
    _targetChildId = widget.childId;

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
      // `_targetChildId == null` → all children; otherwise the picked one.
      final targetIds = _targetChildId == null
          ? _children.map((c) => c.id).toList()
          : <String>[_targetChildId!];
      await cubit.createTaskForChildren(
        targetIds.isEmpty ? [widget.childId] : targetIds,
        request,
      );
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
                      TaskSectionLabel(s.createTaskNameLabel),
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

                      // ── Target child (create mode, 2+ children) ───────────
                      if (!widget.isEdit && _children.length > 1) ...[
                        const TaskSectionLabel('Кому задание'),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            SelectablePill(
                              selected: _targetChildId == null,
                              onTap: () =>
                                  setState(() => _targetChildId = null),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              child: const Text('Все дети'),
                            ),
                            ..._children.map(
                              (c) => SelectablePill(
                                selected: _targetChildId == c.id,
                                onTap: () =>
                                    setState(() => _targetChildId = c.id),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                child: Text(c.nickname),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],

                      // ── Emoji Picker ──────────────────────────────────────
                      TaskSectionLabel(s.createTaskPickEmojiLabel),
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
                      TaskSectionLabel(s.createTaskCategoryTitle),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: _buildCategoryChips(s),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ── Reward ────────────────────────────────────────────
                      TaskSectionLabel(s.createTaskRewardLabel),
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
                      GradientButton(
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

