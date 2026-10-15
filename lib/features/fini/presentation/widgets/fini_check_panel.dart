import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';

/// "Let Fini check" on a task (SAF-276): on, Fini reads the task with the
/// day's app time and the photo, if there is one, and approves when the
/// evidence is clear. Saved as `metadata.fini_check`.
class FiniCheck {
  const FiniCheck({this.on = false});

  final bool on;

  Map<String, dynamic>? toJson() => on ? const {'auto': true} : null;

  /// Any saved check is on, the older "app and minutes" form included.
  factory FiniCheck.fromJson(Object? raw) => FiniCheck(on: raw is Map);
}

class FiniCheckPanel extends StatelessWidget {
  const FiniCheckPanel({
    super.key,
    required this.check,
    required this.onChanged,
  });

  final FiniCheck check;
  final ValueChanged<FiniCheck> onChanged;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DsSheetPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.taskFiniCheck, style: AppText.rowTitleLg),
                  const SizedBox(height: 2),
                  Text(s.taskFiniCheckSub, style: AppText.metaSm),
                ],
              ),
            ),
            const SizedBox(width: 12),
            DsSwitch(
              key: const ValueKey('task-fini-check'),
              value: check.on,
              onChanged: (on) => onChanged(FiniCheck(on: on)),
            ),
          ],
        ),
      ),
    );
  }
}
