import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/fini/domain/fini_models.dart';

/// Fini's Sunday report (SAF-278): the week's dates and up to three bullets,
/// on the Fini home through the week and on top of Activity.
class FiniReportCard extends StatelessWidget {
  const FiniReportCard({
    super.key,
    required this.report,
    required this.childName,
  });

  final FiniReport report;
  final String childName;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final day = DateFormat.MMMd(Localizations.localeOf(context).toString());
    return DsCard(
      key: ValueKey('fini-report-${report.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: DsOverlineText(s.finiReportOverline)),
              Text(
                '${day.format(report.weekStart)} - ${day.format(report.weekEnd)}',
                style: AppText.metaSm,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(s.finiReportTitle(childName), style: AppText.rowTitleLg),
          for (final bullet in report.bullets) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 8, right: 10),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(child: Text(bullet, style: AppText.body)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
