import 'package:flutter/material.dart';
import 'package:safini/core/app_icons/app_icon_tile.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/parent/data/app_data.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart'
    show formatHm;

/// One app in "where the time went".
class AppTimeRow {
  const AppTimeRow({
    required this.name,
    required this.usedMinutes,
    this.iconUrl,
    this.isOver = false,
  });

  final String name;
  final String? iconUrl;
  final int usedMinutes;

  /// Past the parent's limit: the minutes and the bar turn red.
  final bool isOver;
}

/// Every app the child spent time in, most used first. The first [collapsed]
/// rows show; the rest sit behind "Show all N apps" so a long day does not
/// push everything else off the screen.
class AppTimeList extends StatefulWidget {
  const AppTimeList({super.key, required this.apps, this.collapsed = 5});

  final List<AppTimeRow> apps;
  final int collapsed;

  /// Bars share one scale so rows compare. The artboard's 90 minutes, or the
  /// busiest app when that went further, so the top bar is never clipped.
  static int scaleFor(List<AppTimeRow> apps) => apps.fold(
    90,
    (scale, app) => app.usedMinutes > scale ? app.usedMinutes : scale,
  );

  @override
  State<AppTimeList> createState() => _AppTimeListState();
}

class _AppTimeListState extends State<AppTimeList> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final apps = widget.apps;
    final hidden = apps.length - widget.collapsed;
    final shown = _expanded || hidden <= 0
        ? apps
        : apps.take(widget.collapsed).toList();
    final scale = AppTimeList.scaleFor(apps);

    return DsGroup(
      verticalPadding: 4,
      children: [
        for (final app in shown) _Row(app: app, scaleMinutes: scale),
        if (hidden > 0)
          Pressable.row(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _expanded
                          ? s.showFewerApps
                          : s.showAllAppsCount(apps.length),
                      style: AppText.rowTitleStrong.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? -0.25 : 0.25,
                    duration: const Duration(milliseconds: 200),
                    child: AppIcons.chevronRight(),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.app, required this.scaleMinutes});

  final AppTimeRow app;
  final int scaleMinutes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          AppIconTile(
            emoji: AppData.getEmojiForApp(app.name),
            iconUrl: app.iconUrl,
            fontSize: 17,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        app.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatHm(S.of(context), app.usedMinutes),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        color: app.isOver
                            ? AppColors.dangerDeep
                            : AppColors.textSecondary,
                        fontFeatures: AppText.tabular,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                DsProgressBar(
                  progress: app.usedMinutes / scaleMinutes,
                  color: app.isOver ? AppColors.danger : AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
