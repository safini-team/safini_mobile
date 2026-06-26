import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/parent/presentation/cubit/parent_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_state.dart';
import 'package:safini/features/parent/presentation/cubit/parent_state.dart';
import 'package:safini/features/parent/presentation/widgets/cards/parent_add_child_card.dart';
import 'package:safini/features/parent/presentation/widgets/cards/parent_progress_card.dart';

String getTimeBasedGreeting(S s) {
  final hour = DateTime.now().hour;
  if (hour >= 5 && hour < 12) return s.goodMorning;
  if (hour >= 12 && hour < 17) return s.goodAfternoon;
  if (hour >= 17 && hour < 21) return s.goodEvening;
  return s.goodNight;
}

class MonitorGreetingTitle extends StatelessWidget {
  const MonitorGreetingTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          getTimeBasedGreeting(s),
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onPrimary.withValues(alpha: 0.7),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        BlocBuilder<ParentCubit, ParentState>(
          builder: (context, state) {
            final name = state.user?.displayName?.trim().isNotEmpty == true
                ? state.user!.displayName!
                : state.user?.email?.split('@').first ?? s.parentName;
            return Text(
              name,
              style: context.textTheme.displaySmall?.copyWith(
                color: context.colorScheme.onPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            );
          },
        ),
      ],
    );
  }
}

class MonitorFlexBackground extends StatelessWidget {
  const MonitorFlexBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Reserve space for the toolbar area
          SizedBox(height: topPadding + 80),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
            child: BlocBuilder<ParentMonitorCubit, ParentMonitorState>(
              builder: (context, state) {
                if (state is ParentMonitorLoaded) {
                  return ParentProgressCard(
                    name: state.monitorModel.childName,
                    level: state.monitorModel.level,
                    coins: state.monitorModel.timeCoins,
                  );
                }
                if (state is ParentMonitorNoChild) {
                  return const ParentAddChildCard();
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
