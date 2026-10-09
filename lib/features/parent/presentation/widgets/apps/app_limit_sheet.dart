import 'package:flutter/material.dart';
import 'package:safini/core/app_icons/app_icon_tile.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_motion.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/models/domain/models/device_usage.dart';
import 'package:safini/features/models/presentation/widgets/week_bars.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_cubit.dart';
import 'package:safini/features/parent/presentation/screens/apps/parent_limits_view.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart'
    show formatHm;

/// The per-app sheet, in two parts.
///
/// An app with no limit opens on its last 7 days under one button, "Add a
/// limit": the parent sees how much the app is used before deciding. Tapping
/// the button swaps the sheet for the editor, in place.
///
/// The editor has three things to set: a daily limit or a full block, whether
/// the child may buy extra time, and what that time costs. The price rows
/// appear only while buying is on. Removing a limit is its own button, not a
/// switch, so "has a limit" and "does not" are never a toggle apart.
///
/// This is also the only place a parent can set the coin price.
///
/// The artboard's "Off after 21:00" schedule row still has no API behind it
/// and is left out rather than faked.
///
/// [week] is this app's own last 7 days, oldest first; null when the child's
/// phone keeps its usage to itself. [startEditing] false opens an app that has
/// no limit on the week instead of the editor.
Future<void> showAppLimitSheet(
  BuildContext context, {
  required ParentAppsCubit cubit,
  required LimitsApp app,
  required String childName,
  bool isNew = false,
  List<DayUsage>? week,
  bool startEditing = true,
}) {
  return showDsSheet<void>(
    context: context,
    builder: (context) => _AppLimitSheet(
      cubit: cubit,
      app: app,
      childName: childName,
      isNew: isNew,
      week: week,
      startEditing: startEditing,
    ),
  );
}

class _AppLimitSheet extends StatefulWidget {
  const _AppLimitSheet({
    required this.cubit,
    required this.app,
    required this.childName,
    required this.isNew,
    required this.week,
    required this.startEditing,
  });

  final ParentAppsCubit cubit;
  final LimitsApp app;
  final String childName;
  final bool isNew;
  final List<DayUsage>? week;
  final bool startEditing;

  @override
  State<_AppLimitSheet> createState() => _AppLimitSheetState();
}

class _AppLimitSheetState extends State<_AppLimitSheet> {
  // An app that was never capped starts the editor on an hour, not on a stale
  // or zero value that would read as "no free time".
  late int _limit = widget.app.isLimited || widget.app.limitMinutes > 0
      ? widget.app.limitMinutes
      : 60;
  late bool _isBlocked = widget.app.isBlocked;
  late bool _canRedeem = widget.app.canRedeem;
  late int _cost = widget.app.redeemCoinCost;
  late int _reward = widget.app.redeemRewardMinutes;
  late bool _editing = widget.startEditing;

  static const int _step = 15;
  static const int _costStep = 10;

  bool get _hasLimit => widget.app.isLimited || widget.app.isBlocked;

  double get _progress =>
      _limit <= 0 ? 0 : (widget.app.usedMinutes / _limit).clamp(0.0, 1.0);

  bool get _isOver => widget.app.usedMinutes > _limit;

  Future<void> _save() => _write(
    isBlocked: _isBlocked,
    isLimited: true,
    limit: _limit,
    canRedeem: _canRedeem,
    cost: _cost,
    reward: _reward,
  );

  /// Takes the cap and the block off but keeps the rule, so the price the
  /// parent set is still there if they add a limit again.
  Future<void> _remove() => _write(
    isBlocked: false,
    isLimited: false,
    limit: widget.app.limitMinutes,
    canRedeem: widget.app.canRedeem,
    cost: widget.app.redeemCoinCost,
    reward: widget.app.redeemRewardMinutes,
  );

  Future<void> _write({
    required bool isBlocked,
    required bool isLimited,
    required int limit,
    required bool canRedeem,
    required int cost,
    required int reward,
  }) async {
    final navigator = Navigator.of(context);
    final messengerContext = context;

    final unchanged =
        !widget.isNew &&
        isBlocked == widget.app.isBlocked &&
        isLimited == widget.app.isLimited &&
        canRedeem == widget.app.canRedeem &&
        limit == widget.app.limitMinutes &&
        cost == widget.app.redeemCoinCost &&
        reward == widget.app.redeemRewardMinutes;
    if (!unchanged) {
      // One PUT for the whole rule rather than one per field: the endpoint
      // replaces it wholesale anyway, and two calls could half-apply.
      final error = widget.isNew
          ? await widget.cubit.addApp(
              slug: widget.app.slug,
              name: widget.app.name,
              dailyLimitMinutes: limit,
              isBlocked: isBlocked,
              isLimited: isLimited,
              canRedeem: canRedeem,
              redeemCoinCost: cost,
              redeemRewardMinutes: reward,
            )
          : await widget.cubit.updateRule(
              widget.app.slug,
              dailyLimitMinutes: limit,
              isBlocked: isBlocked,
              isLimited: isLimited,
              canRedeem: canRedeem,
              redeemCoinCost: cost,
              redeemRewardMinutes: reward,
            );
      if (error != null) {
        if (mounted && error.isNotEmpty) AppSnackBar.error(context, error);
        return;
      }
    }
    navigator.pop();

    if (widget.childName.isNotEmpty && messengerContext.mounted) {
      AppSnackBar.success(
        messengerContext,
        S.of(messengerContext).savedForName(widget.childName),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Header(app: widget.app, hasLimit: _hasLimit),
        const SizedBox(height: 22),
        AnimatedSize(
          duration: AppMotion.tint,
          curve: AppMotion.spring,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: AppMotion.tint,
            child: KeyedSubtree(
              key: ValueKey(_editing),
              child: _editing ? _editor(context) : _week(context),
            ),
          ),
        ),
      ],
    );
  }

  /// No limit yet: the button first, then how much the app is used.
  Widget _week(BuildContext context) {
    final s = S.of(context);
    final week = widget.week;
    final total = week?.fold(0, (sum, day) => sum + day.minutes) ?? 0;
    final used = week?.where((day) => day.minutes > 0).length ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DsPrimaryButton(
          label: s.addLimitAction,
          onTap: () => setState(() => _editing = true),
        ),
        if (week != null && week.isNotEmpty) ...[
          const SizedBox(height: 22),
          DsOverlineText(s.lastSevenDays),
          const SizedBox(height: 10),
          DsSheetPanel(
            padding: const EdgeInsets.all(18),
            radius: AppRadius.card,
            child: total == 0
                ? Text(s.notUsedLastSevenDays, style: AppText.meta)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.averagePerDay(formatHm(s, (total / used).round())),
                        style: AppText.rowTitleStrong,
                      ),
                      const SizedBox(height: 16),
                      WeekBars(days: week),
                    ],
                  ),
          ),
        ],
      ],
    );
  }

  Widget _editor(BuildContext context) {
    final s = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DsSegmentedControl(
          labels: [s.dailyLimit, s.blockSegment],
          selectedIndex: _isBlocked ? 1 : 0,
          onChanged: (index) => setState(() => _isBlocked = index == 1),
        ),
        const SizedBox(height: 12),
        if (_isBlocked)
          DsSheetPanel(
            padding: const EdgeInsets.all(18),
            radius: AppRadius.card,
            child: Text(s.manualBlockHint, style: AppText.meta),
          )
        else ...[
          _limitPanel(s),
          const SizedBox(height: 12),
          _extraTimePanel(s),
        ],
        const SizedBox(height: 22),
        DsPrimaryButton(
          label: widget.childName.isEmpty
              ? s.save
              : s.saveForName(widget.childName),
          onTap: _save,
        ),
        if (_hasLimit && !widget.isNew)
          DsDestructiveButton(
            label: s.removeLimit,
            filled: false,
            onTap: _remove,
          ),
      ],
    );
  }

  Widget _limitPanel(S s) {
    return DsSheetPanel(
      padding: const EdgeInsets.all(18),
      radius: AppRadius.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                // A limit of 0 means no free minutes, not "no limit".
                child: Text(
                  _limit <= 0 ? s.noFreeTime : formatHm(s, _limit),
                  style: AppText.title2.nums,
                ),
              ),
              DsStepper.onPanel(
                width: 44,
                height: 38,
                onLess: () =>
                    setState(() => _limit = (_limit - _step).clamp(0, 480)),
                onMore: () =>
                    setState(() => _limit = (_limit + _step).clamp(0, 480)),
              ),
            ],
          ),
          if (widget.app.usageAvailable) ...[
            const SizedBox(height: 16),
            DsProgressBar(
              progress: _progress,
              height: 7,
              trackColor: AppColors.trackAlt,
              color: _isOver ? AppColors.danger : AppColors.primary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _extraTimePanel(S s) {
    return DsSheetPanel(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
      radius: AppRadius.card,
      child: Column(
        children: [
          _SwitchRow(
            title: s.canBuyExtraTime,
            hint: _canRedeem ? null : s.canBuyExtraTimeHint,
            value: _canRedeem,
            onChanged: (value) => setState(() => _canRedeem = value),
          ),
          if (_canRedeem) ...[
            const DsDivider(),
            _StepperRow(
              title: s.priceLabel,
              value: s.coinsCount(_cost),
              onLess: () =>
                  setState(() => _cost = (_cost - _costStep).clamp(5, 5000)),
              onMore: () =>
                  setState(() => _cost = (_cost + _costStep).clamp(5, 5000)),
            ),
            const DsDivider(),
            _StepperRow(
              title: s.minutesPerPurchase,
              value: formatHm(s, _reward),
              onLess: () =>
                  setState(() => _reward = (_reward - 5).clamp(5, 240)),
              onMore: () =>
                  setState(() => _reward = (_reward + 5).clamp(5, 240)),
            ),
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.app, required this.hasLimit});

  final LimitsApp app;
  final bool hasLimit;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final used = app.usageAvailable
        ? s.usedTodayShort(formatHm(s, app.usedMinutes))
        : s.iosScreenTimeLocalUsageShort;

    return Row(
      children: [
        AppIconTile(
          emoji: app.emoji,
          iconUrl: app.iconUrl,
          size: 52,
          radius: AppRadius.icon,
          fontSize: 26,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(app.name, style: AppText.title4),
              const SizedBox(height: 2),
              Text(
                hasLimit ? used : '${s.noLimitLabel} · $used',
                style: AppText.meta.copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
    this.hint,
  });

  final String title;
  final String? hint;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppText.rowTitleLg),
                if (hint != null) ...[
                  const SizedBox(height: 2),
                  Text(hint!, style: AppText.caption),
                ],
              ],
            ),
          ),
          DsSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.title,
    required this.value,
    required this.onLess,
    required this.onMore,
  });

  final String title;
  final String value;
  final VoidCallback onLess;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppText.caption),
                const SizedBox(height: 2),
                Text(value, style: AppText.title4.nums),
              ],
            ),
          ),
          DsStepper.onPanel(
            width: 44,
            height: 38,
            onLess: onLess,
            onMore: onMore,
          ),
        ],
      ),
    );
  }
}
