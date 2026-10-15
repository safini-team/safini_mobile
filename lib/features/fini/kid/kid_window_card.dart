import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/fini/kid/kid_fini.dart';

/// "Screens rest until 07:00" on the kid's Today while bedtime, school or
/// dinner is on (SAF-277). Templated: the child reads the family's rule.
class KidWindowCard extends StatelessWidget {
  const KidWindowCard({super.key, required this.window});

  final KidWindow window;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final title = switch (window.intent) {
      'school' => s.kidWindowSchool(window.until),
      'dinner' => s.kidWindowDinner(window.until),
      _ => s.kidWindowBedtime(window.until),
    };
    final icon = switch (window.intent) {
      'school' => Icons.school_rounded,
      'dinner' => Icons.restaurant_rounded,
      _ => Icons.bedtime_rounded,
    };
    return DsCard(
      key: const ValueKey('kid-window-card'),
      child: Row(
        children: [
          Icon(icon, size: 28, color: AppColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.rowTitleLg),
                const SizedBox(height: 4),
                Text(s.kidWindowSub, style: AppText.meta),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
