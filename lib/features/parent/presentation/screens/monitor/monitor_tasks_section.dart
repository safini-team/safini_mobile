import 'package:flutter/material.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/parent/presentation/widgets/tiles/parent_task_tile.dart';

class MonitorTasksSection extends StatelessWidget {
  const MonitorTasksSection({super.key});

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
                s.realWorldTasks,
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
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 20),
              label: Text(
                s.newTask,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colorScheme.primary,
                foregroundColor: context.colorScheme.onPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ParentTaskTile(
          title: s.cleanTheRoom,
          category: s.dailyChore,
          rewardCoins: 30,
        ),
        ParentTaskTile(
          title: s.readFor20Mins,
          category: s.educational,
          rewardCoins: 50,
          isPending: true,
        ),
        ParentTaskTile(
          title: s.doHomework,
          category: s.educational,
          rewardCoins: 40,
          isCompleted: true,
        ),
      ],
    );
  }
}
