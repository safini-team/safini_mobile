import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/models/domain/models/installed_app.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart'
    show formatHm;

/// "Let Fini check" on a task (SAF-276): what `metadata.fini_check` holds.
/// A photo task is checked from the photo; any other names an app and the
/// minutes the child must spend in it.
class FiniCheck {
  const FiniCheck({
    this.on = false,
    this.packageName,
    this.appName,
    this.minutes = 10,
  });

  final bool on;
  final String? packageName;
  final String? appName;
  final int minutes;

  static const minMinutes = 5;
  static const maxMinutes = 120;

  /// What goes in `metadata.fini_check`, or null for no check. An app task
  /// without an app picked is no check yet.
  Map<String, dynamic>? toJson({required bool photo}) {
    if (!on) return null;
    if (photo) return {'photo': true};
    if (packageName == null) return null;
    return {
      'package_name': packageName,
      'app_name': appName ?? packageName,
      'minutes': minutes,
    };
  }

  factory FiniCheck.fromJson(Object? raw) {
    if (raw is! Map) return const FiniCheck();
    return FiniCheck(
      on: true,
      packageName: raw['package_name'] as String?,
      appName: raw['app_name'] as String?,
      minutes: (raw['minutes'] as num?)?.toInt() ?? 10,
    );
  }

  FiniCheck copyWith({
    bool? on,
    String? packageName,
    String? appName,
    int? minutes,
  }) => FiniCheck(
    on: on ?? this.on,
    packageName: packageName ?? this.packageName,
    appName: appName ?? this.appName,
    minutes: minutes ?? this.minutes,
  );
}

class FiniCheckPanel extends StatelessWidget {
  const FiniCheckPanel({
    super.key,
    required this.check,
    required this.photo,
    required this.loadApps,
    required this.onChanged,
  });

  final FiniCheck check;

  /// The task needs a photo: Fini checks the photo, not an app.
  final bool photo;

  /// The child's installed apps, for the picker.
  final Future<List<InstalledApp>> Function() loadApps;
  final ValueChanged<FiniCheck> onChanged;

  Future<void> _pick(BuildContext context) async {
    final s = S.of(context);
    final apps = await loadApps();
    if (!context.mounted) return;
    final picked = await showModalBottomSheet<InstalledApp>(
      context: context,
      backgroundColor: AppColors.bgParent,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.6,
          child: apps.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(s.taskFiniNoApps, style: AppText.meta),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    for (final app in apps)
                      DsRow(
                        key: ValueKey('fini-app-${app.packageName}'),
                        title: app.appName,
                        onTap: () => Navigator.of(context).pop(app),
                      ),
                  ],
                ),
        ),
      ),
    );
    if (picked == null) return;
    onChanged(
      check.copyWith(packageName: picked.packageName, appName: picked.appName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DsSheetPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
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
                  onChanged: (on) => onChanged(check.copyWith(on: on)),
                ),
              ],
            ),
          ),
          if (check.on && photo) ...[
            const DsDivider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(s.taskFiniPhotoHint, style: AppText.meta),
            ),
          ],
          if (check.on && !photo) ...[
            const DsDivider(),
            DsRow(
              key: const ValueKey('task-fini-app'),
              title: s.taskFiniApp,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    check.appName ?? s.taskFiniPickApp,
                    style: AppText.meta.copyWith(
                      color: check.appName == null
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AppIcons.chevronRight(),
                ],
              ),
              onTap: () => _pick(context),
            ),
            const DsDivider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(s.taskFiniMinutes, style: AppText.rowTitleLg),
                  ),
                  Text(
                    formatHm(s, check.minutes),
                    key: const ValueKey('task-fini-minutes'),
                    style: AppText.rowTitleLg,
                  ),
                  const SizedBox(width: 10),
                  DsStepper(
                    onLess: check.minutes <= FiniCheck.minMinutes
                        ? null
                        : () => onChanged(
                            check.copyWith(minutes: check.minutes - 5),
                          ),
                    onMore: check.minutes >= FiniCheck.maxMinutes
                        ? null
                        : () => onChanged(
                            check.copyWith(minutes: check.minutes + 5),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
