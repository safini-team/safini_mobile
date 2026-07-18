import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';

class ParentNoChildEmptyState extends StatelessWidget {
  const ParentNoChildEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Icon(
            Icons.child_care_rounded,
            size: 72,
            color: context.colorScheme.primary.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 20),
          Text(
            s.noChildrenFoundYet,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await context.router.push<bool>(
                const NamedRoute('addChild'),
              );
              if (result == true && context.mounted) {
                context.read<ParentFamilyCubit>().loadCurrentFamily(
                  refresh: true,
                );
              }
            },
            icon: const Icon(Icons.add_rounded),
            label: Text(s.addChild),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
