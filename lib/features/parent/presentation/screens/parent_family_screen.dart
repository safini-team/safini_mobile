import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_state.dart';
import 'package:safini/features/parent/presentation/widgets/cards/parent_child_card.dart';

class ParentFamilyScreen extends StatelessWidget {
  const ParentFamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ParentFamilyCubit>()..loadFamilyData(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "Family",
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () {},
            ),
          ],
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF43008F), Color(0xFF8100D1)],
              ),
            ),
          ),
        ),
        body: BlocBuilder<ParentFamilyCubit, ParentFamilyState>(
          builder: (context, state) {
            if (state is ParentFamilyLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ParentFamilyLoaded) {
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    "YOUR CHILDREN",
                    style: context.textTheme.labelMedium?.copyWith(
                      color: Colors.grey[600],
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...state.children.map((child) => ParentChildCard(
                    name: child.name,
                    age: 10, // Placeholder
                    gender: "Boy", // Placeholder
                    coins: 150,
                    quests: 1,
                    streak: 5,
                    onViewAsKid: () {},
                    onEdit: () {},
                  )),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0E6FF),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.add, color: Color(0xFF8100D1)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Add Another Child",
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Set up a new profile",
                                style: context.textTheme.bodySmall?.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "PARENT ACCOUNT",
                    style: context.textTheme.labelMedium?.copyWith(
                      color: Colors.grey[600],
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          child: Icon(Icons.person),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.parent.name,
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Family Admin",
                                style: context.textTheme.bodySmall?.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0E6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "Admin",
                            style: TextStyle(color: Color(0xFF8100D1), fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildTipsSection(context),
                  const SizedBox(height: 24),
                  const _LogoutButton(),
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

  Widget _buildTipsSection(BuildContext context) {
    final tips = [
      "Set meaningful tasks that teach responsibility",
      "Balance screen time rewards with outdoor activities",
      "Celebrate achievements with your child",
      "Adjust coin values to match effort levels",
    ];
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F9),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.red.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("🌟", style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(
                "Tips for Parents",
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.circle, size: 6, color: Color(0xFF8100D1)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tip,
                    style: context.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F9),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.logout, color: Colors.red),
          const SizedBox(width: 12),
          Text(
            "Switch to Kid Mode / Logout",
            style: context.textTheme.titleMedium?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
