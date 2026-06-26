import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/parent/presentation/cubit/parent_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_state.dart';
import 'package:safini/features/parent/presentation/cubit/parent_state.dart';
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
                  return _AddChildCard();
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

class _AddChildCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(36),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: context.colorScheme.onPrimary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(36),
            border: Border.all(
              color: context.colorScheme.onPrimary.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                S.of(context).noChildrenFoundYet,
                style: context.textTheme.titleLarge?.copyWith(
                  color: context.colorScheme.onPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: context.colorScheme.onPrimary,
                  foregroundColor: context.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
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
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(
                  S.of(context).addChild,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
