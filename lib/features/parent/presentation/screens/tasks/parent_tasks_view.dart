import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/child_avatar_look.dart';
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
    this.avatar = const ChildAvatarLook(),
  });

  final String name;
  final Color color;
  final List<TaskRowData> rows;

  /// Pre-localised "3 tasks · 45 coins".
  final String summary;
  final ChildAvatarLook avatar;

  int get coins => rows.fold(0, (sum, row) => sum + row.coins);
}

/// One day of the Done history: the day's label, what was paid that day, and
/// the day's tasks grouped by child. With one child in scope there is a single
/// group and its header is left out, since the chip already says who.
class TaskDayData {
  const TaskDayData({
    required this.label,
    required this.summary,
    required this.groups,
    this.showChildHeaders = true,
  });

  /// "Today", "Yesterday", "Monday", "Sep 12".
  final String label;

  /// Pre-localised "3 tasks · 45 coins".
  final String summary;
  final List<TaskGroupData> groups;
  final bool showChildHeaders;
}

class TaskScopeChip {
  const TaskScopeChip({
    required this.key,
    required this.label,
    this.color,
    this.hasAvatar = true,
    this.avatar = const ChildAvatarLook(),
  });

  final String key;
  final String label;
  final Color? color;
  final bool hasAvatar;
  final ChildAvatarLook avatar;
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
    this.days = const [],
  });

  final String scopeLine;
  final List<TaskScopeChip> chips;
  final String selectedScope;
  final Map<TaskLane, int> laneCounts;
  final TaskLane lane;
  final List<TaskGroupData> groups;
  final String emptyTitle;
  final String emptyBody;

  /// Done lane only: the history, newest day first. When set it replaces
  /// [groups], so a parent scrolls back through the days like a chat.
  final List<TaskDayData> days;

  /// Nothing in any lane for this scope.
  bool get hasNoTasks => laneCounts.values.every((count) => count == 0);
}

/// Parent · Tasks: scope chips, a three-way segmented filter, then one card per
/// child. The footnote at the bottom is part of the design - it is where the
/// coin rules are explained.
///
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
                      avatar: chip.hasAvatar ? chip.avatar : null,
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
        // Days are built as they scroll in: the Done history reaches back
        // to the first approved task, which is hundreds of rows in a month.
        if (data.days.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              0,
              AppSpacing.gutter,
              0,
            ),
            sliver: SliverList.builder(
              itemCount: data.days.length,
              itemBuilder: (context, index) => _Day(
                day: data.days[index],
                isFirst: index == 0,
                onOpenTask: onOpenTask,
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              data.days.isNotEmpty ? 0 : 16,
              AppSpacing.gutter,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (data.days.isEmpty) ...[
                  if (data.groups.isNotEmpty)
                    for (final group in data.groups) ...[
                      _Group(group: group, onOpenTask: onOpenTask),
                      const SizedBox(height: 16),
                    ]
                  else
                    _EmptyLane(title: data.emptyTitle, body: data.emptyBody),
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

/// A day header, overline style so it reads above the child headers inside
/// it, then that day's groups.
class _Day extends StatelessWidget {
  const _Day({
    required this.day,
    required this.isFirst,
    required this.onOpenTask,
  });

  final TaskDayData day;
  final bool isFirst;
  final ValueChanged<TaskRowData> onOpenTask;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(6, isFirst ? 20 : 12, 6, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  day.label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.overline.copyWith(color: AppColors.ink),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                day.summary,
                maxLines: 1,
                style: AppText.caption
                    .copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                    )
                    .nums,
              ),
            ],
          ),
        ),
        for (final group in day.groups) ...[
          _Group(
            group: group,
            onOpenTask: onOpenTask,
            showHeader: day.showChildHeaders,
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({
    required this.group,
    required this.onOpenTask,
    this.showHeader = true,
  });

  final TaskGroupData group;
  final ValueChanged<TaskRowData> onOpenTask;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showHeader)
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 9),
            child: Row(
              children: [
                DsKidFace(
                  name: group.name,
                  avatar: group.avatar,
                  color: group.color,
                  size: 22,
                  fontSize: 11,
                ),
                const SizedBox(width: 9),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      group.name,
                      maxLines: 1,
                      softWrap: false,
                      style: AppText.chip.copyWith(letterSpacing: -0.116),
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                const Expanded(child: DsDivider(color: AppColors.hairline)),
                const SizedBox(width: 9),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      group.summary,
                      maxLines: 1,
                      softWrap: false,
                      textAlign: TextAlign.right,
                      style: AppText.caption
                          .copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textTertiary,
                          )
                          .nums,
                    ),
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
