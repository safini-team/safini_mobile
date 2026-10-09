import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/models/domain/models/device_usage.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart'
    show formatHm;

/// A bar per day, the busiest one darker. Shared by the week card on Today and
/// the per-app week in the limit sheet.
class WeekBars extends StatelessWidget {
  const WeekBars({super.key, required this.days});

  /// Oldest first.
  final List<DayUsage> days;

  static const double _barHeight = 64;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final busiest = days.fold(0, (m, day) => day.minutes > m ? day.minutes : m);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final day in days)
          Expanded(
            child: Semantics(
              label:
                  '${DateFormat.EEEE(locale).format(day.date)}, '
                  '${formatHm(s, day.minutes)}',
              excludeSemantics: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 18,
                    height: busiest == 0
                        ? 4
                        : (day.minutes / busiest * _barHeight).clamp(
                            4,
                            _barHeight,
                          ),
                    decoration: BoxDecoration(
                      color: day.minutes == 0
                          ? AppColors.track
                          : day.minutes == busiest
                          ? AppColors.primary
                          : AppColors.primaryBar,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      DateFormat.E(locale).format(day.date),
                      maxLines: 1,
                      style: AppText.micro.copyWith(letterSpacing: 0.345),
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
