import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_state.dart';
import 'package:safini/features/parent/presentation/widgets/tiles/parent_task_tile.dart';

class ParentTasksScreen extends StatelessWidget {
  const ParentTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<ParentTasksCubit>()..loadTasks(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "Tasks & Rewards",
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF43008F), Color(0xFF8100D1)],
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18),
                label: const Text("New"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<ParentTasksCubit, ParentTasksState>(
          builder: (context, state) {
            if (state is ParentTasksLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ParentTasksLoaded) {
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (state.pendingApproval.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Pending Approval",
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            state.pendingApproval.length.toString(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...state.pendingApproval.map((task) => ParentTaskTile(
                      title: task.title,
                      category: "Educational", // Placeholder category
                      rewardCoins: 50, // Placeholder reward
                      isPending: true,
                      onApprove: () => context.read<ParentTasksCubit>().approveTask(task.id),
                    )),
                    const SizedBox(height: 24),
                  ],
                  
                  Row(
                    children: [
                      const Icon(Icons.circle, color: Color(0xFF8100D1), size: 12),
                      const SizedBox(width: 8),
                      Text(
                        "Active Tasks",
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        state.activeTasks.length.toString(),
                        style: context.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...state.activeTasks.map((task) => ParentTaskTile(
                    title: task.title,
                    category: "Daily Chore",
                    rewardCoins: 30,
                    onDelete: () {},
                  )),
                  
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Completed",
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...state.completedTasks.map((task) => ParentTaskTile(
                    title: task.title,
                    category: "Educational",
                    rewardCoins: 40,
                    isCompleted: true,
                  )),
                  const SizedBox(height: 100),
                ],
              );
            }
            
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
