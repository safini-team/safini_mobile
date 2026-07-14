import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/parent/presentation/cubit/home/home_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_cubit.dart';
import 'package:safini/features/parent/presentation/widgets/tiles/parent_app_limit_tile.dart';

class MonitorAppLimitsSection extends StatelessWidget {
  const MonitorAppLimitsSection({super.key, required this.appLimits});

  final List<Map<String, dynamic>> appLimits;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                s.appLimits,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),
            ),
            TextButton(
              onPressed: () =>
                  context.read<ParentHomeCubit>().selectTab(2),
              child: Text(
                s.manageAll,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...appLimits.map(
          (app) => ParentAppLimitTile(
            appName: app['name'],
            usedMinutes: app['used'],
            limitMinutes: app['limit'],
            iconPath: app['icon'],
            isEnabled: app['isEnabled'] ?? true,
            onToggle: (val) =>
                context.read<ParentMonitorCubit>().toggleAppLimit(
                      app['slug'] as String,
                      val,
                    ),
          ),
        ),
      ],
    );
  }
}
