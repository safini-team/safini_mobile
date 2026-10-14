import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/fini/presentation/cubit/fini_cubit.dart';
import 'package:safini/features/fini/presentation/widgets/goal_tile_grid.dart';

/// "Add a goal for Amir": one tap on a tile adds it with its defaults, and
/// the goal opens for tuning from the list. "Say it your way" arrives with
/// the goal-drafting call (SAF-274).
Future<void> showAddGoalSheet(
  BuildContext context, {
  required String childName,
}) {
  final cubit = context.read<FiniCubit>();
  return showDsSheet<void>(
    context: context,
    builder: (sheetContext) => BlocProvider.value(
      value: cubit,
      child: _AddGoalSheet(childName: childName),
    ),
  );
}

class _AddGoalSheet extends StatelessWidget {
  const _AddGoalSheet({required this.childName});

  final String childName;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final state = context.watch<FiniCubit>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(s.finiAddGoalFor(childName), style: AppText.title2),
        const SizedBox(height: 14),
        GoalTileGrid(
            tileColor: AppColors.fillAlt,
            added: state.addedIntents,
            onTap: (spec) async {
              final navigator = Navigator.of(context);
              final error = await context.read<FiniCubit>().addGoal(spec);
              if (!context.mounted) return;
              if (error != null) {
                AppSnackBar.error(
                  context,
                  error.isEmpty ? s.networkError : error,
                );
                return;
              }
              navigator.pop();
            },
        ),
      ],
    );
  }
}
