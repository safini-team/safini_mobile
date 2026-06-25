import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_state.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_cubit.dart';
import 'package:safini/features/parent/presentation/widgets/charts/parent_screen_time_chart.dart';
import 'package:safini/features/parent/presentation/screens/monitor/monitor_header.dart';
import 'package:safini/features/parent/presentation/screens/monitor/monitor_stats_row.dart';
import 'package:safini/features/parent/presentation/screens/monitor/monitor_app_limits_section.dart';
import 'package:safini/features/parent/presentation/screens/monitor/monitor_tasks_section.dart';

class ParentMonitorScreen extends StatelessWidget {
  const ParentMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<ParentMonitorCubit>()..loadMonitorData(),
        ),
        BlocProvider(
          create: (context) => getIt<ParentTasksCubit>()..loadTasks(),
        ),
      ],
      child: const _ParentMonitorView(),
    );
  }
}

class _ParentMonitorView extends StatelessWidget {
  const _ParentMonitorView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.primary,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            // toolbarHeight covers greeting text + name (no overflow)
            toolbarHeight: 80,
            expandedHeight: 320,
            backgroundColor: context.colorScheme.primary,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            centerTitle: false,
            titleSpacing: 0,
            title: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: MonitorGreetingTitle(),
            ),
            flexibleSpace: const FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: MonitorFlexBackground(),
            ),
            // This bottom widget is part of the pinned SliverAppBar — it is
            // always visible, keeping the rounded-corner transition in place
            // even when the progress card has scrolled away.
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(36),
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: context.colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: context.colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: BlocBuilder<ParentMonitorCubit, ParentMonitorState>(
                  builder: (context, state) {
                    if (state is ParentMonitorLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(48),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (state is ParentMonitorNoChild) {
                      return _NoChildEmptyState();
                    }

                    if (state is ParentMonitorLoaded) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MonitorStatsRow(
                            stepsToday: state.stepsToday,
                            lessonsToday: state.lessonsToday,
                          ),
                          const SizedBox(height: 24),
                          ParentScreenTimeChart(weeklyUsage: state.weeklyUsage),
                          const SizedBox(height: 40),
                          MonitorAppLimitsSection(appLimits: state.appLimits),
                          const SizedBox(height: 40),
                          const MonitorTasksSection(),
                          const SizedBox(height: 100),
                        ],
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoChildEmptyState extends StatelessWidget {
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
