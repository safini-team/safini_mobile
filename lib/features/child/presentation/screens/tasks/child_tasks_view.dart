import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';

enum ChildTaskState { open, sent, done }

class ChildTaskRow {
  const ChildTaskRow({
    required this.id,
    required this.title,
    required this.meta,
    required this.coins,
    required this.state,
  });

  final String id;
  final String title;
  final String meta;
  final int coins;
  final ChildTaskState state;
}

class ChildTasksCategory {
  const ChildTasksCategory({required this.label, required this.selected});

  final String label;
  final bool selected;
}

class ChildTasksData {
  const ChildTasksData({
    required this.done,
    required this.total,
    required this.pendingCoins,
    required this.categories,
    required this.rows,
    required this.emptyMessage,
  });

  final int done;
  final int total;
  final int pendingCoins;
  final List<ChildTasksCategory> categories;
  final List<ChildTaskRow> rows;
  final String emptyMessage;

  String subtitle(S s) => s.childTasksSubtitle(done, total, pendingCoins);
}

/// Kid · Tasks: the whole list in one card, each row led by a state circle
/// rather than a checkbox the child can toggle. Sending happens in the sheet.
class ChildTasksView extends StatelessWidget {
  const ChildTasksView({
    super.key,
    required this.data,
    required this.onSelectCategory,
    required this.onOpenTask,
    this.onRefresh,
  });

  final ChildTasksData data;
  final ValueChanged<int> onSelectCategory;
  final ValueChanged<ChildTaskRow> onOpenTask;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return DsScreen(
      background: AppColors.bgChild,
      onRefresh: onRefresh,
      slivers: [
        SliverToBoxAdapter(
          child: DsLargeTitle(title: s.tabTasks, subtitle: data.subtitle(s)),
        ),
        SliverToBoxAdapter(
          child: DsChipStrip(
            children: [
              for (var i = 0; i < data.categories.length; i++)
                DsCategoryChip(
                  label: data.categories[i].label,
                  selected: data.categories[i].selected,
                  onTap: () => onSelectCategory(i),
                ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              18,
              AppSpacing.gutter,
              0,
            ),
            child: data.rows.isEmpty
                ? DsCard(
                    shadow: AppShadows.flat,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 26,
                    ),
                    child: Text(
                      data.emptyMessage,
                      style: AppText.meta,
                      textAlign: TextAlign.center,
                    ),
                  )
                : DsGroup(
                    children: [
                      for (final row in data.rows)
                        _TaskRow(row: row, onTap: () => onOpenTask(row)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.row, required this.onTap});

  final ChildTaskRow row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final done = row.state == ChildTaskState.done;

    return Pressable.row(
      onTap: onTap,
      child: Opacity(
        opacity: done ? 0.55 : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            children: [
              _StateCircle(state: row.state),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      row.title,
                      style: AppText.rowTitle.copyWith(
                        fontSize: 16.5,
                        letterSpacing: -0.198,
                        color: done ? AppColors.textMuted : AppColors.ink,
                        decoration: done
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: AppColors.textMuted,
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
              switch (row.state) {
                ChildTaskState.done => DsPill.paid(
                  label: S.of(context).pillPaid,
                  height: 24,
                  fontSize: 13,
                ),
                ChildTaskState.sent => DsPill(
                  label: S.of(context).pillWaiting,
                  background: AppColors.coinPillBg,
                  foreground: AppColors.coinPillFg,
                  height: 24,
                  fontSize: 13,
                ),
                ChildTaskState.open => DsPill.tint(
                  label: '+${row.coins}',
                  height: 24,
                ),
              },
            ],
          ),
        ),
      ),
    );
  }
}

/// `26px` circle: an empty 2px ring while open, amber with a tick once sent,
/// green once the parent has paid it.
class _StateCircle extends StatelessWidget {
  const _StateCircle({required this.state});

  final ChildTaskState state;

  @override
  Widget build(BuildContext context) {
    final fill = switch (state) {
      ChildTaskState.done => AppColors.success,
      ChildTaskState.sent => AppColors.coin,
      ChildTaskState.open => Colors.transparent,
    };

    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: state == ChildTaskState.open
            ? Border.all(color: AppColors.strokeQuiet, width: 2)
            : null,
      ),
      child: state == ChildTaskState.open
          ? null
          : AppIcons.check(size: 13, strokeWidth: 2.2),
    );
  }
}
