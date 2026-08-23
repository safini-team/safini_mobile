import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/models/data/dto/task_dto.dart';
import 'package:safini/features/models/domain/models/family_model.dart';
import 'package:safini/features/models/domain/models/task_model.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_state.dart';

/// Opens the create/edit task sheet. [task] == null → CREATE, otherwise EDIT.
Future<void> showTaskSheet(
  BuildContext context, {
  required ParentTasksCubit cubit,
  required String childId,
  TaskModel? task,
}) {
  return showDsSheet<void>(
    context: context,
    builder: (context) => BlocProvider.value(
      value: cubit,
      child: TaskSheet(childId: childId, task: task),
    ),
  );
}

class TaskSheet extends StatefulWidget {
  const TaskSheet({super.key, required this.childId, this.task});

  final String childId;

  /// When non-null the sheet is in EDIT mode, prefilled from this task.
  final TaskModel? task;

  bool get isEdit => task != null;

  @override
  State<TaskSheet> createState() => _TaskSheetState();
}

class _TaskSheetState extends State<TaskSheet> {
  static const List<String> _emojis = [
    '🪴',
    '🧹',
    '🍽️',
    '📚',
    '🛏️',
    '🐕',
    '🧺',
    '🦷',
    '🎹',
    '🗑️',
  ];

  static const List<({String emoji, String key})> _categories = [
    (emoji: '🏠', key: 'home'),
    (emoji: '🎓', key: 'school'),
    (emoji: '🦷', key: 'health'),
    (emoji: '⚽', key: 'outdoor'),
  ];

  static String _categoryLabel(S s, String key) => switch (key) {
    'school' => s.catSchool,
    'health' => s.catHealth,
    'outdoor' => s.catOutdoor,
    _ => s.catHome,
  };

  static const int _coinStep = 5;

  final _title = TextEditingController();
  final _details = TextEditingController();

  String _emoji = _emojis.first;
  String _category = _categories.first.key;
  int _coins = 15;
  bool _photoProof = true;

  List<ChildSummaryModel> _children = const [];

  /// null means "everyone".
  String? _targetChildId;

  bool get _canSubmit => _title.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();

    _children =
        context
            .read<ParentFamilyCubit>()
            .state
            .family
            ?.children
            .where((child) => child.id.isNotEmpty)
            .toList() ??
        const [];
    _targetChildId = widget.childId;

    final task = widget.task;
    if (task != null) {
      _title.text = task.title;
      _details.text = task.description ?? '';
      _coins = task.coinReward;
      _photoProof = (task.proofMode ?? '').toLowerCase().contains('image');
      // A task seeded by the backend carries a category this sheet has no chip
      // for (`learn`, `fitness`, `logic`, `real_world`). Keep it instead of
      // defaulting to `home`, or every edit silently rewrites the category.
      final key = (task.category ?? '').toLowerCase();
      if (key.isNotEmpty) _category = key;
      final emoji = task.metadata?['emoji'];
      if (emoji is String && emoji.trim().isNotEmpty) _emoji = emoji.trim();
    }

    _title.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    _details.dispose();
    super.dispose();
  }

  /// Values the API documents: `text_image`, `reported_metric`, `none`.
  /// `text` was never one of them.
  String get _proofMode => _photoProof ? 'text_image' : 'none';

  Future<void> _submit() async {
    final title = _title.text.trim();
    if (title.isEmpty) return;

    final details = _details.text.trim();
    final coins = _coins.clamp(0, 100000);
    final cubit = context.read<ParentTasksCubit>();
    final original = widget.task;

    if (original == null) {
      final request = TaskCreateRequestDto(
        title: title,
        description: details.isEmpty ? title : details,
        category: _category,
        taskType: 'custom',
        proofMode: _proofMode,
        verificationMode: 'parent_approval',
        coinReward: coins,
        xpReward: coins,
        metadata: {'emoji': _emoji},
      );
      final targetIds = _targetChildId == null
          ? _children.map((child) => child.id).toList()
          : <String>[_targetChildId!];
      await cubit.createTaskForChildren(
        targetIds.isEmpty ? [widget.childId] : targetIds,
        request,
      );
      return;
    }

    // EDIT - diff against the original and send only what changed.
    final originalEmoji = original.metadata?['emoji'];
    final request = TaskUpdateRequestDto(
      title: title != original.title ? title : null,
      description: details != (original.description ?? '') ? details : null,
      category: _category != original.category ? _category : null,
      coinReward: coins != original.coinReward ? coins : null,
      xpReward: coins != original.coinReward ? coins : null,
      metadata: _emoji != originalEmoji ? {'emoji': _emoji} : null,
    );

    if (request.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    await cubit.updateTask(original.id, request);
  }

  Future<void> _confirmDelete() async {
    final s = S.of(context);
    final cubit = context.read<ParentTasksCubit>();

    final confirmed = await showDsSheet<bool>(
      context: context,
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(s.deleteTaskTitle, style: AppText.title3),
          const SizedBox(height: 8),
          Text(s.deleteTaskBody, style: AppText.bodyRegular),
          const SizedBox(height: 22),
          DsPrimaryButton(
            label: s.deleteTaskButton,
            background: AppColors.danger,
            shadow: const [],
            onTap: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: 9),
          DsPrimaryButton.secondary(
            label: s.cancel,
            onTap: () => Navigator.of(context).pop(false),
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
    return BlocListener<ParentTasksCubit, ParentTasksState>(
      listener: (context, state) {
        if (state is ParentTaskSaved || state is ParentTaskDeleted) {
          Navigator.of(context).pop();
        } else if (state is ParentTaskActionError) {
          // A conflict (already-approved task) closes the sheet and the list
          // screen shows why; anything else stays so the parent can retry.
          if (state.isConflict) {
            Navigator.of(context).pop();
          } else if (!state.isUnauthorized) {
            AppSnackBar.error(context, state.message);
          }
        }
      },
      child: BlocBuilder<ParentTasksCubit, ParentTasksState>(
        builder: (context, state) {
          final s = S.of(context);
          final busy = state is ParentTaskSaving || state is ParentTaskDeleting;
          final targetName = _targetChildId == null
              ? null
              : _children
                    .where((child) => child.id == _targetChildId)
                    .firstOrNull
                    ?.nickname;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.isEdit ? s.editTaskSheetTitle : s.newTask,
                style: AppText.title3,
              ),
              const SizedBox(height: 18),
              _IconPicker(
                emoji: _emoji,
                options: _emojis,
                onSelect: (value) => setState(() => _emoji = value),
              ),
              const SizedBox(height: 14),
              _FieldPanel(
                title: _title,
                details: _details,
                coins: _coins,
                photoProof: _photoProof,
                onLess: () => setState(
                  () => _coins = (_coins - _coinStep).clamp(5, 100000),
                ),
                onMore: () => setState(() => _coins += _coinStep),
                onPhotoProof: (value) => setState(() => _photoProof = value),
              ),
              const SizedBox(height: 20),
              DsOverlineText(s.createTaskCategoryTitle),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final category in _categories)
                    DsCategoryChip(
                      label: _categoryLabel(s, category.key),
                      emoji: category.emoji,
                      selected: category.key == _category,
                      restBackground: AppColors.fill,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      onTap: () => setState(() => _category = category.key),
                    ),
                ],
              ),
              if (!widget.isEdit && _children.isNotEmpty) ...[
                const SizedBox(height: 20),
                DsOverlineText(s.whoSection),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    DsKidChip(
                      name: s.scopeEveryone,
                      showAvatar: false,
                      avatarSize: 26,
                      selected: _targetChildId == null,
                      onTap: () => setState(() => _targetChildId = null),
                    ),
                    for (final child in _children)
                      DsKidChip(
                        name: child.nickname,
                        color: AppColors.kidColor(child.id),
                        avatarSize: 26,
                        selected: _targetChildId == child.id,
                        onTap: () =>
                            setState(() => _targetChildId = child.id),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              DsPrimaryButton(
                label: widget.isEdit
                    ? s.saveChanges
                    : targetName == null
                    ? s.addToEveryonesList
                    : s.addToList(targetName),
                enabled: _canSubmit,
                busy: busy,
                onTap: _submit,
              ),
              if (widget.isEdit) ...[
                const SizedBox(height: 4),
                DsDestructiveButton(
                  label: S.of(context).deleteTaskButton,
                  filled: false,
                  onTap: busy ? null : _confirmDelete,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _IconPicker extends StatelessWidget {
  const _IconPicker({
    required this.emoji,
    required this.options,
    required this.onSelect,
  });

  final String emoji;
  final List<String> options;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DsEmojiTile(
          emoji: emoji,
          size: 56,
          radius: AppRadius.control,
          background: AppColors.primaryTint,
          fontSize: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              DsOverlineText(S.of(context).iconSection),
              const SizedBox(height: 7),
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: options.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final selected = option == emoji;
                    return Pressable(
                      onTap: () => onSelect(option),
                      scale: 0.92,
                      child: Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.surface
                              : AppColors.fill,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: selected
                              ? Border.all(
                                  color: AppColors.primary,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Text(
                          option,
                          style: const TextStyle(fontSize: 17, height: 1.15),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FieldPanel extends StatelessWidget {
  const _FieldPanel({
    required this.title,
    required this.details,
    required this.coins,
    required this.photoProof,
    required this.onLess,
    required this.onMore,
    required this.onPhotoProof,
  });

  final TextEditingController title;
  final TextEditingController details;
  final int coins;
  final bool photoProof;
  final VoidCallback onLess;
  final VoidCallback onMore;
  final ValueChanged<bool> onPhotoProof;

  @override
  Widget build(BuildContext context) {
    return DsSheetPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          _FieldRow(
            label: S.of(context).taskFieldLabel,
            child: TextField(
              controller: title,
              textCapitalization: TextCapitalization.sentences,
              cursorColor: AppColors.primary,
              style: AppText.rowTitleLg,
              decoration: _fieldDecoration(S.of(context).taskTitleHint),
            ),
          ),
          const DsDivider(),
          _FieldRow(
            label: S.of(context).detailsFieldLabel,
            alignTop: true,
            child: TextField(
              controller: details,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              cursorColor: AppColors.primary,
              style: AppText.body.copyWith(
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
              decoration: _fieldDecoration(S.of(context).taskDetailsHint),
            ),
          ),
          const DsDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text(
                    S.of(context).rewardFieldLabel,
                    style: AppText.field,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    S.of(context).coinCountShort(coins),
                    style: AppText.rowTitleLg.copyWith(
                      fontWeight: FontWeight.w600,
                    ).nums,
                  ),
                ),
                DsStepper.onPanel(onLess: onLess, onMore: onMore),
              ],
            ),
          ),
          const DsDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    S.of(context).needsPhotoProof,
                    style: AppText.rowTitleLg,
                  ),
                ),
                DsSwitch(value: photoProof, onChanged: onPhotoProof),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static InputDecoration _fieldDecoration(String hint) => InputDecoration(
    filled: false,
    isDense: true,
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    contentPadding: EdgeInsets.zero,
    hintText: hint,
    hintStyle: AppText.body.copyWith(
      fontWeight: FontWeight.w400,
      color: AppColors.textTertiary,
    ),
  );
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.label,
    required this.child,
    this.alignTop = false,
  });

  final String label;
  final Widget child;
  final bool alignTop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: alignTop
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: alignTop ? 2 : 0),
            child: SizedBox(
              width: 70,
              child: Text(label, style: AppText.field),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}
