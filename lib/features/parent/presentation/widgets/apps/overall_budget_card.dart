import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart'
    show formatHm, formatHmTight;

const int _defaultBudgetMinutes = 240;
const int _budgetStepMinutes = 30;
const int _maximumBudgetMinutes = 1440;

/// The compact Today presentation: progress first, then one clear status.
class OverallBudgetSummary extends StatelessWidget {
  const OverallBudgetSummary({
    super.key,
    required this.limitMinutes,
    required this.usedMinutes,
    required this.remainingMinutes,
    required this.usageAvailable,
    required this.kidName,
    required this.topApp,
    this.configurationAvailable = true,
    this.nextResetAt,
  });

  final int? limitMinutes;
  final int usedMinutes;
  final int? remainingMinutes;
  final bool usageAvailable;
  final bool configurationAvailable;
  final String kidName;
  final String topApp;
  final DateTime? nextResetAt;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    if (!configurationAvailable) {
      return Text(s.budgetUnavailable, style: AppText.meta);
    }

    final limit = limitMinutes ?? _defaultBudgetMinutes;
    final remaining = remainingMinutes ?? (limit - usedMinutes).clamp(0, limit);
    final progress = limit == 0 ? 1.0 : (usedMinutes / limit).clamp(0.0, 1.0);
    final reset = nextResetAt;
    final resetLabel = reset == null
        ? null
        : DateFormat.Hm(
            Localizations.localeOf(context).toLanguageTag(),
          ).format(reset.toLocal());

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        DsProgressRing(
          progress: progress,
          size: 112,
          radius: 46,
          strokeWidth: 11,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                usageAvailable ? formatHmTight(s, usedMinutes) : '—',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppColors.ink,
                  fontFeatures: AppText.tabular,
                ),
              ),
              const SizedBox(height: 2),
              Text(s.ofTotal(formatHmTight(s, limit)), style: AppText.micro),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(s.screenTime.toUpperCase(), style: AppText.overline),
              const SizedBox(height: 7),
              Text(
                !usageAvailable
                    ? s.budgetUsageUnknown
                    : remaining == 0
                    ? s.budgetNoFreeTime
                    : s.kidHasLeftToday(kidName, formatHm(s, remaining)),
                style: AppText.headline.copyWith(fontSize: 17, height: 1.28),
              ),
              const SizedBox(height: 5),
              if (topApp.isNotEmpty)
                Text(s.mostOfItIn(topApp), style: AppText.meta),
              if (remaining == 0 && resetLabel != null) ...[
                const SizedBox(height: 5),
                Text(s.budgetPausedUntil(resetLabel), style: AppText.meta),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// The Limits control follows the iOS card pattern: value, stepper, progress.
/// A missing legacy budget starts at four hours on the control; the first
/// adjustment persists the chosen value through the existing API.
class OverallBudgetCard extends StatefulWidget {
  const OverallBudgetCard({
    super.key,
    required this.limitMinutes,
    required this.usedMinutes,
    required this.remainingMinutes,
    required this.usageAvailable,
    required this.kidName,
    this.configurationAvailable = true,
    this.nextResetAt,
    this.onSave,
  });

  final int? limitMinutes;
  final int usedMinutes;
  final int? remainingMinutes;
  final bool usageAvailable;
  final bool configurationAvailable;
  final String kidName;
  final DateTime? nextResetAt;
  final Future<String?> Function(int?)? onSave;

  @override
  State<OverallBudgetCard> createState() => _OverallBudgetCardState();
}

class _OverallBudgetCardState extends State<OverallBudgetCard> {
  bool _saving = false;
  String? _error;
  late int _displayLimit;

  int get _limit => _displayLimit;

  @override
  void initState() {
    super.initState();
    _displayLimit = widget.limitMinutes ?? _defaultBudgetMinutes;
  }

  @override
  void didUpdateWidget(covariant OverallBudgetCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.limitMinutes != oldWidget.limitMinutes) {
      _displayLimit = widget.limitMinutes ?? _defaultBudgetMinutes;
    }
  }

  Future<void> _change(int delta) async {
    final save = widget.onSave;
    if (save == null || _saving) return;
    final next = (_limit + delta).clamp(0, _maximumBudgetMinutes);
    if (next == _limit && widget.limitMinutes != null) return;

    setState(() {
      _saving = true;
      _error = null;
    });
    final error = await save(next);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _error = error;
      if (error == null) _displayLimit = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    if (!widget.configurationAvailable) {
      return DsCard(child: Text(s.budgetUnavailable, style: AppText.meta));
    }

    final limit = _limit;
    final remaining =
        widget.remainingMinutes ?? (limit - widget.usedMinutes).clamp(0, limit);
    final progress = limit == 0
        ? 1.0
        : (widget.usedMinutes / limit).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DsCard.deep(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.dailyAllowanceFor(widget.kidName).toUpperCase(),
                          style: AppText.overline.copyWith(
                            color: const Color(0xA6FFFFFF),
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: Text(
                            formatHm(s, limit),
                            key: ValueKey(limit),
                            style: AppText.title2.copyWith(
                              fontSize: 34,
                              letterSpacing: -0.8,
                              color: AppColors.textOnPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Opacity(
                    opacity: _saving ? 0.55 : 1,
                    child: DsStepper.onDeep(
                      onLess: _saving || limit == 0
                          ? null
                          : () => _change(-_budgetStepMinutes),
                      onMore: _saving || limit == _maximumBudgetMinutes
                          ? null
                          : () => _change(_budgetStepMinutes),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (widget.usageAvailable) ...[
                DsProgressBar(
                  progress: progress,
                  height: 8,
                  trackColor: const Color(0x29FFFFFF),
                  color: AppColors.primaryPale,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        s.timeUsed(formatHm(s, widget.usedMinutes)),
                        style: AppText.meta.copyWith(
                          color: const Color(0xC7FFFFFF),
                        ),
                      ),
                    ),
                    Text(
                      s.timeLeft(formatHm(s, remaining)),
                      style: AppText.meta.copyWith(
                        color: const Color(0xC7FFFFFF),
                      ),
                    ),
                  ],
                ),
              ] else
                Text(
                  s.budgetUsageUnknown,
                  style: AppText.meta.copyWith(color: const Color(0xC7FFFFFF)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(s.budgetExplanation, style: AppText.meta),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              _error!,
              style: AppText.meta.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ],
    );
  }
}
