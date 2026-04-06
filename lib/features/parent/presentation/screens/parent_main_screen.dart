import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/parent/presentation/screens/parent_monitor_screen.dart';
import 'package:safini/features/parent/presentation/screens/parent_tasks_screen.dart';
import 'package:safini/features/parent/presentation/screens/parent_apps_screen.dart';
import 'package:safini/features/parent/presentation/screens/parent_family_screen.dart';
import 'package:safini/generated/l10n.dart';

class ParentMainScreen extends StatefulWidget {
  const ParentMainScreen({super.key});

  @override
  State<ParentMainScreen> createState() => _ParentMainScreenState();
}

class _ParentMainScreenState extends State<ParentMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ParentMonitorScreen(),
    const ParentTasksScreen(),
    const ParentAppsScreen(),
    const ParentFamilyScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return Localizations.override(
          context: context,
          locale: locale,
          child: Builder(
            builder: (context) {
              final s = S.of(context);
              return Scaffold(
                body: IndexedStack(index: _selectedIndex, children: _screens),
                bottomNavigationBar: BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: _onItemTapped,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: context.colorScheme.primary,
                  unselectedItemColor: Colors.grey,
                  selectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  unselectedLabelStyle: const TextStyle(fontSize: 12),
                  items: [
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.grid_view_rounded),
                      label: s.monitor,
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.fact_check_outlined),
                      label: s.tasks,
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.smartphone),
                      label: s.apps,
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.people_outline),
                      label: s.family,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
