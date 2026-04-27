import 'package:flutter/material.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/parent/presentation/widgets/cards/parent_stat_card.dart';

class MonitorStatsRow extends StatelessWidget {
  const MonitorStatsRow({
    super.key,
    required this.stepsToday,
    required this.lessonsToday,
  });

  final int stepsToday;
  final String lessonsToday;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Row(
      children: [
        Expanded(
          child: ParentStatCard(
            value: stepsToday.toString(),
            label: s.stepsToday,
            change: s.stepsChangeText,
            icon: Icons.trending_up,
            iconBackgroundColor: context.colorScheme.primary.withValues(alpha: 0.1),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ParentStatCard(
            value: lessonsToday,
            label: s.lessons,
            change: s.lessonsChangeText,
            icon: Icons.book_outlined,
            iconBackgroundColor: context.successColor.withValues(alpha: 0.1),
            iconColor: context.successColor,
          ),
        ),
      ],
    );
  }
}
