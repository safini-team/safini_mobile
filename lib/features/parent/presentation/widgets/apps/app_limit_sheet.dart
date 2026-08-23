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

/// The per-app sheet from the artboard: icon + name, a daily-limit panel with
/// the stepper and usage bar, then the control toggle.
///
/// The artboard's "Block completely" switch and "Off after 21:00" row have no
/// API behind them. The switch here drives the one flag that does exist,
/// `is_enabled`, so the copy says what it actually does; the schedule row is
/// left out rather than faked.
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
  late bool _enabled = widget.app.isEnabled;

  static const int _step = 15;

  double get _progress =>
      _limit <= 0 ? 0 : (widget.app.usedMinutes / _limit).clamp(0.0, 1.0);

  bool get _isOver => widget.app.usedMinutes > _limit;

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    final messengerContext = context;

    if (_enabled != widget.app.isEnabled) {
      await widget.cubit.toggleApp(widget.app.slug, _enabled);
    }
    if (_limit != widget.app.limitMinutes) {
      await widget.cubit.updateLimit(widget.app.slug, _limit);
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
                          _enabled ? formatHm(s, _limit) : s.noLimitLabel,
                          style: AppText.title2.nums,
                        ),
                      ],
                    ),
                  ),
                  DsStepper.onPanel(
                    width: 44,
                    height: 38,
                    onLess: _enabled
                        ? () => setState(
                            () => _limit = (_limit - _step).clamp(15, 480),
                          )
                        : null,
                    onMore: _enabled
                        ? () => setState(
                            () => _limit = (_limit + _step).clamp(15, 480),
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DsProgressBar(
                progress: _enabled ? _progress : 0,
                height: 7,
                trackColor: AppColors.trackAlt,
                color: _isOver ? AppColors.danger : AppColors.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        DsSheetPanel(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
          radius: AppRadius.card,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(s.limitThisApp, style: AppText.rowTitleLg),
                      const SizedBox(height: 2),
                      Text(s.offMeansAlwaysAllowed, style: AppText.caption),
                    ],
                  ),
                ),
                DsSwitch(
                  value: _enabled,
                  onChanged: (value) => setState(() => _enabled = value),
                ),
              ],
            ),
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
