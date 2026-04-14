import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_state.dart';
import 'package:safini/features/parent/presentation/widgets/cards/parent_progress_card.dart';
import 'package:safini/features/parent/presentation/widgets/cards/parent_stat_card.dart';
import 'package:safini/features/parent/presentation/widgets/charts/parent_screen_time_chart.dart';
import 'package:safini/features/parent/presentation/widgets/tiles/parent_app_limit_tile.dart';
import 'package:safini/features/parent/presentation/widgets/tiles/parent_task_tile.dart';
import 'package:safini/generated/l10n.dart';

class ParentMonitorScreen extends StatelessWidget {
  const ParentMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ParentMonitorCubit>()..loadMonitorData(),
      child: const _ParentMonitorView(),
    );
  }
}

class _ParentMonitorView extends StatelessWidget {
  const _ParentMonitorView();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF43008F),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            backgroundColor: context.colorScheme.primary.withValues(alpha: 0.9),
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _buildHeader(context, s),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                ),
              ),
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

                    if (state is ParentMonitorLoaded) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ParentStatCard(
                                  value: state.stepsToday.toString(),
                                  label: s.stepsToday,
                                  change: s.stepsChangeText,
                                  icon: Icons.trending_up,
                                  iconBackgroundColor: context.colorScheme.primary.withValues(alpha: 0.1),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ParentStatCard(
                                  value: state.lessonsToday,
                                  label: s.lessons,
                                  change: s.lessonsChangeText,
                                  icon: Icons.book_outlined,
                                  iconBackgroundColor: context.successColor.withValues(alpha: 0.1),
                                  iconColor: context.successColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          ParentScreenTimeChart(weeklyUsage: state.weeklyUsage),
                          const SizedBox(height: 40),
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
                                onPressed: () {},
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
                          ...state.appLimits.map(
                            (app) => ParentAppLimitTile(
                              appName: app['name'],
                              usedMinutes: app['used'],
                              limitMinutes: app['limit'],
                              iconPath: app['icon'],
                            ),
                          ),
                          const SizedBox(height: 40),
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

  Widget _buildHeader(BuildContext context, S s) {
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
                        Text(
                          s.parentName,
                          style: context.textTheme.displaySmall?.copyWith(
                            color: context.colorScheme.onPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: context.colorScheme.onPrimary.withOpacity(0.15),
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