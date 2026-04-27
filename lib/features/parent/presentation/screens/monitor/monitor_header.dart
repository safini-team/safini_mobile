import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/parent/presentation/cubit/parent_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_state.dart';
import 'package:safini/features/parent/presentation/cubit/parent_state.dart';
import 'package:safini/features/parent/presentation/widgets/cards/parent_progress_card.dart';

class MonitorHeader extends StatelessWidget {
  const MonitorHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colorScheme.primary.withValues(alpha: 0.8),
            context.colorScheme.primary,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.goodMorning,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onPrimary.withValues(alpha: 0.7),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        BlocBuilder<ParentCubit, ParentState>(
                          builder: (context, state) {
                            return Text(
                              state.user?.displayName ?? s.parentName,
                              style: context.textTheme.displaySmall?.copyWith(
                                color: context.colorScheme.onPrimary,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: context.colorScheme.onPrimary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.settings_outlined,
                      color: context.colorScheme.onPrimary,
                      size: 26,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              BlocBuilder<ParentMonitorCubit, ParentMonitorState>(
                builder: (context, state) {
                  if (state is ParentMonitorLoaded) {
                    return ParentProgressCard(
                      name: state.childName,
                      level: state.level,
                      coins: state.timeCoins,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
