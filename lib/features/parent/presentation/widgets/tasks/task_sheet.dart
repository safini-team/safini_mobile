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
import 'package:safini/features/models/domain/models/task_voice.dart';
import 'package:safini/features/parent/domain/models/task_idea.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_state.dart';
import 'package:safini/features/parent/presentation/widgets/tasks/task_voice_recorder.dart';
import 'package:safini/core/utils/task_category.dart';

enum _NewTaskChoice { custom }

/// Lets the parent choose a localized template or start with a blank task.
/// Nothing is saved until the following editor is submitted.
Future<void> showNewTaskChooser(
  BuildContext context, {
  required ParentTasksCubit cubit,
  required String childId,
}) async {
  final choice = await showDsSheet<Object>(
    context: context,
    builder: (sheetContext) {
      final s = S.of(sheetContext);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(s.chooseTaskTitle, style: AppText.title3),
          const SizedBox(height: 6),
          Text(s.chooseTaskBody, style: AppText.bodyRegular),
          const SizedBox(height: 18),
          DsPrimaryButton.secondary(
            label: s.newCustomTask,
            icon: const Icon(Icons.edit_rounded, size: 19),
            onTap: () => Navigator.of(sheetContext).pop(_NewTaskChoice.custom),
          ),
          const SizedBox(height: 22),
          DsOverlineText(s.taskTemplatesTitle),
          const SizedBox(height: 10),
          DsGroup(
            children: [
              for (final idea in TaskIdea.values)
                DsRow(
                  onTap: () => Navigator.of(sheetContext).pop(idea),
                  title: idea.title(s),
                  subtitle: [
                    idea.recurrence == 'weekly'
                        ? s.repeatWeeklyShort
                        : s.repeatDailyShort,
                    s.coinCountShort(idea.coins),
                    if (idea.photoProof) s.needsPhotoProof,
                  ].join(' · '),
                  leading: DsEmojiTile(emoji: idea.emoji, size: 36),
                  trailing: AppIcons.chevronRight(),
                ),
            ],
          ),
        ],
      );
    },
  );
  if (!context.mounted || choice == null) return;
  await showTaskSheet(
    context,
    cubit: cubit,
    childId: childId,
    idea: choice is TaskIdea ? choice : null,
  );
}

/// Opens the create/edit task sheet. [task] == null → CREATE, otherwise EDIT.
/// [idea] prefills a CREATE; nothing is saved until the parent taps Add.
Future<void> showTaskSheet(
  BuildContext context, {
  required ParentTasksCubit cubit,
  required String childId,
  TaskModel? task,
  TaskIdea? idea,
}) {
  return showDsSheet<void>(
    context: context,
    builder: (context) => BlocProvider.value(
      value: cubit,
      child: TaskSheet(childId: childId, task: task, idea: idea),
    ),
  );
}

class TaskSheet extends StatefulWidget {
  const TaskSheet({
    super.key,
    required this.childId,
    this.task,
    this.idea,
    this.voiceCapture,
    this.voicePlayback,
  });

  final String childId;

  /// When non-null the sheet is in EDIT mode, prefilled from this task.
  final TaskModel? task;

  /// The task idea a CREATE starts from. Ignored in EDIT mode.
  final TaskIdea? idea;

  /// Injected in tests so the sheet never opens the microphone plugin.
  final TaskVoiceCapture? voiceCapture;
  final TaskVoicePlayback? voicePlayback;

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

  /// All eight, from the shared catalogue. The sheet used to offer four of
  /// its own invention while the backend seeded four different ones into the
  /// same column.
  static const List<TaskCategory> _categories = TaskCategory.values;

  static const int _coinStep = 5;

  final _title = TextEditingController();
  final _details = TextEditingController();

  String _emoji = _emojis.first;

  /// The picker's row: an emoji the task or idea brought that is not one of
  /// the ten stays first, so tapping another one does not lose it for good.
  late final List<String> _emojiOptions;

  TaskCategory _category = TaskCategory.home;
  String _recurrence = 'none';
  int _recurrenceDays = 0;
  String? _recurrenceError;
  int _coins = 15;
  bool _photoProof = true;
  TaskVoiceSave _voiceSave = TaskVoiceSave.unchanged;
  bool _voiceBusy = false;

  /// Set when create succeeded but attaching the voice note failed, so Save
  /// retries the attach on those tasks instead of creating them again.
  List<TaskVoiceTarget> _pendingVoice = const [];

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
      _category = TaskCategory.tryParse(task.category) ?? TaskCategory.home;
      _recurrence = task.recurrence;
      _recurrenceDays = task.recurrenceDays ?? 0;
      final emoji = task.metadata?['emoji'];
      if (emoji is String && emoji.trim().isNotEmpty) _emoji = emoji.trim();
    } else if (widget.idea case final idea?) {
      _coins = idea.coins;
      _photoProof = idea.photoProof;
      _category = idea.category;
      _recurrence = idea.recurrence;
      _recurrenceDays = idea.recurrenceDays ?? 0;
      _emoji = idea.emoji;
    }
    _emojiOptions = [if (!_emojis.contains(_emoji)) _emoji, ..._emojis];

    _title.addListener(() => setState(() {}));
  }

  bool _hasAppliedIdeaText = false;

  /// The idea's words come in the parent's language, which initState cannot
  /// look up yet.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final idea = widget.task == null ? widget.idea : null;
    if (idea == null || _hasAppliedIdeaText) return;
    _hasAppliedIdeaText = true;
    final s = S.of(context);
    _title.text = idea.title(s);
    _details.text = idea.details(s);
  }

  @override
  void dispose() {
    _title.dispose();
    _details.dispose();
    super.dispose();
  }

  static String _weekdayLabel(S s, int index) => switch (index) {
    0 => s.weekdayMon,
    1 => s.weekdayTue,
    2 => s.weekdayWed,
    3 => s.weekdayThu,
    4 => s.weekdayFri,
    5 => s.weekdaySat,
    _ => s.weekdaySun,
  };

  /// Values the API documents: `text_image`, `reported_metric`, `none`.
  /// `text` was never one of them.
  String get _proofMode => _photoProof ? 'text_image' : 'none';

  Future<void> _submit() async {
    final title = _title.text.trim();
    if (title.isEmpty) return;

    // The API rejects this too, but the parent should find out here rather
    // than through a 422 after the sheet closes.
    if (_recurrence == 'weekly' && _recurrenceDays == 0) {
      setState(() => _recurrenceError = S.of(context).pickAtLeastOneDay);
      return;
    }

    final details = _details.text.trim();
    final coins = _coins.clamp(0, 100000);
    final cubit = context.read<ParentTasksCubit>();
    final original = widget.task;
    final keepingExistingVoice =
        original?.hasVoiceInstruction == true &&
        !_voiceSave.remove &&
        _voiceSave.attach == null;
    final hasVoice = _voiceSave.attach != null || keepingExistingVoice;
    final description = descriptionForTaskSave(
      title: title,
      details: details,
      hasVoice: hasVoice,
    );

    if (original == null) {
      if (_pendingVoice.isNotEmpty) {
        await cubit.retryVoice(_pendingVoice, voice: _voiceSave);
        return;
      }
      final request = TaskCreateRequestDto(
        title: title,
        description: description,
        category: _category.key,
        taskType: 'custom',
        proofMode: _proofMode,
        verificationMode: 'parent_approval',
        coinReward: coins,
        xpReward: coins,
        recurrence: _recurrence,
        recurrenceDays: _recurrence == 'weekly' ? _recurrenceDays : null,
        metadata: {
          'emoji': _emoji,
          if (widget.idea case final idea?) TaskIdea.metadataKey: idea.key,
        },
      );
      final targetIds = _targetChildId == null
          ? _children.map((child) => child.id).toList()
          : <String>[_targetChildId!];
      await cubit.createTaskForChildren(
        targetIds.isEmpty ? [widget.childId] : targetIds,
        request,
        voice: _voiceSave,
      );
      return;
    }

    // EDIT - diff against the original and send only what changed.
    final originalEmoji = original.metadata?['emoji'];
    final nextDescription = description ?? '';
    final originalDescription = original.description ?? '';
    final request = TaskUpdateRequestDto(
      title: title != original.title ? title : null,
      description: nextDescription != originalDescription
          ? nextDescription
          : null,
      category: _category.key != original.category ? _category.key : null,
      coinReward: coins != original.coinReward ? coins : null,
      xpReward: coins != original.coinReward ? coins : null,
      recurrence: _recurrence != original.recurrence ? _recurrence : null,
      recurrenceDays: _recurrence == 'weekly' ? _recurrenceDays : null,
      // The server replaces metadata whole, so keep what else it holds - the
      // idea a task came from, for one.
      metadata: _emoji != originalEmoji
          ? {...?original.metadata, 'emoji': _emoji}
          : null,
    );

    if (request.isEmpty && !_voiceSave.hasWork) {
      Navigator.of(context).pop();
      return;
    }
    await cubit.updateTask(
      original.id,
      request,
      childId: original.childId ?? widget.childId,
      voice: _voiceSave,
    );
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
          if (state.pendingVoice.isNotEmpty) {
            _pendingVoice = state.pendingVoice;
          }
          // A conflict (already-approved task) closes the sheet and the list
          // screen shows why; anything else stays so the parent can retry.
          if (state.isConflict) {
            Navigator.of(context).pop();
          } else if (!state.isUnauthorized) {
            AppSnackBar.error(
              context,
              state.pendingVoice.isNotEmpty
                  ? S.of(context).voiceAttachFailed
                  : state.message,
            );
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
                options: _emojiOptions,
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
              const SizedBox(height: 14),
              TaskVoiceRecorderPanel(
                existingUrl: widget.task?.voiceInstructionUrl,
                existingDurationMs: widget.task?.voiceInstructionDurationMs,
                capture: widget.voiceCapture,
                playback: widget.voicePlayback,
                onBusy: (busy) => setState(() => _voiceBusy = busy),
                onChanged: (value) => setState(() => _voiceSave = value),
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
                      label: category.label(s),
                      emoji: category.emoji,
                      selected: category == _category,
                      restBackground: AppColors.fill,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      onTap: () => setState(() => _category = category),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              DsOverlineText(s.repeatLabel),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final option in const [
                    ('none', '1️⃣'),
                    ('daily', '🔁'),
                    ('weekly', '📅'),
                  ])
                    DsCategoryChip(
                      label: switch (option.$1) {
                        'daily' => s.repeatDaily,
                        'weekly' => s.repeatWeekly,
                        _ => s.repeatOnce,
                      },
                      emoji: option.$2,
                      selected: option.$1 == _recurrence,
                      restBackground: AppColors.fill,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      onTap: () => setState(() {
                        _recurrence = option.$1;
                        _recurrenceError = null;
                        // Mon-Fri is what a parent almost always means by
                        // "some days", so it beats an empty picker.
                        if (_recurrence == 'weekly' && _recurrenceDays == 0) {
                          _recurrenceDays = 1 | 2 | 4 | 8 | 16;
                        }
                      }),
                    ),
                ],
              ),
              if (_recurrence == 'weekly') ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (var index = 0; index < 7; index++)
                      DsCategoryChip(
                        label: _weekdayLabel(s, index),
                        selected: _recurrenceDays & (1 << index) != 0,
                        restBackground: AppColors.fill,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        onTap: () => setState(() {
                          _recurrenceDays ^= 1 << index;
                          _recurrenceError = null;
                        }),
                      ),
                  ],
                ),
              ],
              if (_recurrenceError != null) ...[
                const SizedBox(height: 8),
                DsFootnote(_recurrenceError!, top: 0),
              ],
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
                        onTap: () => setState(() => _targetChildId = child.id),
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
                enabled: _canSubmit && !_voiceBusy,
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
                          color: selected ? AppColors.surface : AppColors.fill,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: selected
                              ? Border.all(color: AppColors.primary, width: 2)
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
                    style: AppText.rowTitleLg
                        .copyWith(fontWeight: FontWeight.w600)
                        .nums,
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
