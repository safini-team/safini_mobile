import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_cubit.dart';
import 'package:safini/features/parent/presentation/screens/apps/parent_limits_view.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart'
    show formatHm;

/// The per-app sheet: icon + name, the daily limit, the coin price, and the
/// two switches that were one ambiguous switch until the server split them.
///
/// This is also the only place a parent can set the coin price. The steppers
/// were built long ago but lived in the add-app sheet, which no parent could
/// open because every catalog app was assigned automatically - so "you set
/// every number here", the whole pitch, was not true.
///
/// The artboard's "Off after 21:00" schedule row still has no API behind it
/// and is left out rather than faked.
Future<void> showAppLimitSheet(
  BuildContext context, {
  required ParentAppsCubit cubit,
  required LimitsApp app,
  required String childName,
}) {
  return showDsSheet<void>(
    context: context,
    builder: (context) =>
        _AppLimitSheet(cubit: cubit, app: app, childName: childName),
  );
}

class _AppLimitSheet extends StatefulWidget {
  const _AppLimitSheet({
    required this.cubit,
    required this.app,
    required this.childName,
  });

  final ParentAppsCubit cubit;
  final LimitsApp app;
  final String childName;

  @override
  State<_AppLimitSheet> createState() => _AppLimitSheetState();
}

class _AppLimitSheetState extends State<_AppLimitSheet> {
  late int _limit = widget.app.limitMinutes <= 0 ? 60 : widget.app.limitMinutes;
  late bool _isLimited = widget.app.isLimited;
  late bool _canRedeem = widget.app.canRedeem;
  late int _cost = widget.app.redeemCoinCost;
  late int _reward = widget.app.redeemRewardMinutes;

  static const int _step = 15;
  static const int _costStep = 10;

  double get _progress =>
      _limit <= 0 ? 0 : (widget.app.usedMinutes / _limit).clamp(0.0, 1.0);

  bool get _isOver => widget.app.usedMinutes > _limit;

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    final messengerContext = context;

    final unchanged =
        _isLimited == widget.app.isLimited &&
        _canRedeem == widget.app.canRedeem &&
        _limit == widget.app.limitMinutes &&
        _cost == widget.app.redeemCoinCost &&
        _reward == widget.app.redeemRewardMinutes;
    if (!unchanged) {
      // One PUT for the whole rule rather than one per field: the endpoint
      // replaces it wholesale anyway, and two calls could half-apply.
      await widget.cubit.updateRule(
        widget.app.slug,
        dailyLimitMinutes: _limit,
        isLimited: _isLimited,
        canRedeem: _canRedeem,
        redeemCoinCost: _cost,
        redeemRewardMinutes: _reward,
      );
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
    final s = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            DsEmojiTile(
              emoji: widget.app.emoji,
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
                  Text(widget.app.name, style: AppText.title4),
                  const SizedBox(height: 2),
                  Text(
                    s.usedTodayShort(formatHm(s, widget.app.usedMinutes)),
                    style: AppText.meta.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        DsSheetPanel(
          padding: const EdgeInsets.all(18),
          radius: AppRadius.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DsOverlineText(s.dailyLimit),
                        const SizedBox(height: 6),
                        Text(
                          // A limit of 0 means no free minutes, not "no
                          // limit" - the two used to render the same way.
                          !_isLimited
                              ? s.noLimitLabel
                              : (_limit <= 0
                                    ? s.noFreeTime
                                    : formatHm(s, _limit)),
                          style: AppText.title2.nums,
                        ),
                      ],
                    ),
                  ),
                  DsStepper.onPanel(
                    width: 44,
                    height: 38,
                    onLess: _isLimited
                        ? () => setState(
                            () => _limit = (_limit - _step).clamp(0, 480),
                          )
                        : null,
                    onMore: _isLimited
                        ? () => setState(
                            () => _limit = (_limit + _step).clamp(0, 480),
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DsProgressBar(
                progress: _isLimited ? _progress : 0,
                height: 7,
                trackColor: AppColors.trackAlt,
                color: _isOver ? AppColors.danger : AppColors.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        DsSheetPanel(
          padding: const EdgeInsets.all(18),
          radius: AppRadius.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DsOverlineText(s.priceLabel),
                        const SizedBox(height: 6),
                        Text(
                          s.priceUnit('$_cost', formatHm(s, _reward)),
                          style: AppText.title4.nums,
                        ),
                      ],
                    ),
                  ),
                  DsStepper.onPanel(
                    width: 44,
                    height: 38,
                    onLess: _canRedeem
                        ? () => setState(
                            () => _cost = (_cost - _costStep).clamp(5, 5000),
                          )
                        : null,
                    onMore: _canRedeem
                        ? () => setState(
                            () => _cost = (_cost + _costStep).clamp(5, 5000),
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(s.minutesPerPurchase, style: AppText.caption),
                  ),
                  DsStepper.onPanel(
                    width: 44,
                    height: 38,
                    onLess: _canRedeem
                        ? () => setState(
                            () => _reward = (_reward - 5).clamp(5, 240),
                          )
                        : null,
                    onMore: _canRedeem
                        ? () => setState(
                            () => _reward = (_reward + 5).clamp(5, 240),
                          )
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        DsSheetPanel(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
          radius: AppRadius.card,
          child: Column(
            children: [
              _ToggleRow(
                title: s.dailyLimitToggle,
                hint: s.dailyLimitToggleHint,
                value: _isLimited,
                onChanged: (value) => setState(() => _isLimited = value),
              ),
              const DsDivider(),
              _ToggleRow(
                title: s.canBuyExtraTime,
                hint: s.canBuyExtraTimeHint,
                value: _canRedeem,
                onChanged: (value) => setState(() => _canRedeem = value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        DsPrimaryButton(
          label: widget.childName.isEmpty
              ? s.save
              : s.saveForName(widget.childName),
          onTap: _save,
        ),
      ],
    );
  }
}


class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.hint,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String hint;
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
                const SizedBox(height: 2),
                Text(hint, style: AppText.caption),
              ],
            ),
          ),
          DsSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
