import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';

enum TaskLane { review, active, done }

String laneLabel(S s, TaskLane lane) => switch (lane) {
  TaskLane.review => s.laneToReview,
  TaskLane.active => s.laneActive,
  TaskLane.done => s.laneDone,
};

class TaskRowData {
  const TaskRowData({
    required this.id,
    required this.title,
    required this.meta,
    required this.emoji,
    required this.lane,
    required this.coins,
    required this.childName,
  });

  final String id;
  final String title;
  final String meta;
  final String emoji;
  final TaskLane lane;
  final int coins;
  final String childName;
}

class TaskGroupData {
  const TaskGroupData({
    required this.name,
    required this.color,
    required this.rows,
    required this.summary,
  });

  final String name;
  final Color color;
  final List<TaskRowData> rows;

  /// Pre-localised "3 tasks · 45 coins".
  final String summary;

  int get coins => rows.fold(0, (sum, row) => sum + row.coins);
}

class TaskScopeChip {
  const TaskScopeChip({
    required this.key,
    required this.label,
    this.color,
    this.hasAvatar = true,
  });

  final String key;
  final String label;
  final Color? color;
  final bool hasAvatar;
}

class ParentTasksData {
  const ParentTasksData({
    required this.scopeLine,
    required this.chips,
    required this.selectedScope,
    required this.laneCounts,
    required this.lane,
    required this.groups,
    required this.emptyTitle,
    required this.emptyBody,
  });

  final String scopeLine;
  final List<TaskScopeChip> chips;
  final String selectedScope;
  final Map<TaskLane, int> laneCounts;
  final TaskLane lane;
  final List<TaskGroupData> groups;
  final String emptyTitle;
  final String emptyBody;
}

/// Parent · Tasks: scope chips, a three-way segmented filter, then one card per
/// child. The footnote at the bottom is part of the design - it is where the
/// coin rules are explained.
class ParentTasksView extends StatelessWidget {
  const ParentTasksView({
    super.key,
    required this.data,
    required this.onSelectScope,
    required this.onSelectLane,
    required this.onOpenTask,
    required this.onNewTask,
    this.onRefresh,
  });

  final ParentTasksData data;
  final ValueChanged<String> onSelectScope;
  final ValueChanged<TaskLane> onSelectLane;
  final ValueChanged<TaskRowData> onOpenTask;
  final VoidCallback onNewTask;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return DsScreen(
      onRefresh: onRefresh,
      floatingAction: DsFloatingAction(
        label: s.newTask,
        icon: AppIcons.plus(size: 15, color: AppColors.textOnPrimary),
        onTap: onNewTask,
      ),
      slivers: [
        SliverToBoxAdapter(
          child: DsLargeTitle(title: s.tabTasks, subtitle: data.scopeLine),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.textGutter,
              14,
              AppSpacing.textGutter,
              0,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: DsKidPicker(
                selectedKey: data.selectedScope,
                options: [
                  for (final chip in data.chips)
                    DsPickerOption(
                      key: chip.key,
                      label: chip.label,
                      color: chip.color ?? AppColors.textTertiary,
                      initial: chip.hasAvatar ? null : '·',
                    ),
                ],
                onSelect: onSelectScope,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              14,
              AppSpacing.gutter,
              0,
            ),
            child: DsSegmentedControl(
              selectedIndex: TaskLane.values.indexOf(data.lane),
              onChanged: (index) => onSelectLane(TaskLane.values[index]),
              labels: [
                for (final lane in TaskLane.values)
                  data.laneCounts[lane] == 0
                      ? laneLabel(s, lane)
                      : '${laneLabel(s, lane)} ${data.laneCounts[lane]}',
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              16,
              AppSpacing.gutter,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (data.groups.isEmpty)
                  _EmptyLane(title: data.emptyTitle, body: data.emptyBody)
                else
                  for (final group in data.groups) ...[
                    _Group(group: group, onOpenTask: onOpenTask),
                    const SizedBox(height: 16),
                  ],
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    s.coinsPaidAfterApproval,
                    style: AppText.footnote,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.group, required this.onOpenTask});

  final TaskGroupData group;
  final ValueChanged<TaskRowData> onOpenTask;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 0, 6, 9),
          child: Row(
            children: [
              DsInitialAvatar(
                name: group.name,
                color: group.color,
                size: 22,
                fontSize: 11,
              ),
              const SizedBox(width: 9),
              Flexible(
                child: Text(
                  group.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.chip.copyWith(letterSpacing: -0.116),
                ),
              ),
              const SizedBox(width: 9),
              const Expanded(child: DsDivider(color: AppColors.hairline)),
              const SizedBox(width: 9),
              Flexible(
                child: Text(
                  group.summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: AppText.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                  ).nums,
                ),
              ),
            ],
          ),
        ),
        DsGroup(
          verticalPadding: 2,
          children: [
            for (final row in group.rows)
              _TaskRow(row: row, onTap: () => onOpenTask(row)),
          ],
        ),
      ],
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.row, required this.onTap});

  final TaskRowData row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDone = row.lane == TaskLane.done;

    return Pressable.row(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            DsEmojiTile(
              emoji: row.emoji,
              size: 32,
              radius: AppRadius.xs,
              fontSize: 16,
              background: isDone ? AppColors.fill : AppColors.primaryTint,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    row.title,
                    style: AppText.rowTitle.copyWith(
                      color: isDone ? AppColors.textMuted : AppColors.ink,
                    ),
                  ),
                  if (row.meta.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(row.meta, style: AppText.metaSm),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            switch (row.lane) {
              TaskLane.review => DsPill.pending(label: S.of(context).pillCheck),
              TaskLane.done => DsPill.paid(label: S.of(context).pillPaid),
              TaskLane.active => DsPill.muted(label: '${row.coins}'),
            },
            const SizedBox(width: 9),
            AppIcons.chevronRight(),
          ],
        ),
      ),
    );
  }
}

class _EmptyLane extends StatelessWidget {
  const _EmptyLane({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return DsCard(
      shadow: AppShadows.flat,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      child: Column(
        children: [
          Text(
            title,
            style: AppText.rowTitleStrong,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(body, style: AppText.meta, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
