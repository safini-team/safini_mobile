import 'package:flutter/material.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/parent/presentation/screens/parent_monitor_screen.dart';
import 'package:safini/features/parent/presentation/screens/parent_tasks_screen.dart';
import 'package:safini/features/parent/presentation/screens/parent_apps_screen.dart';
import 'package:safini/features/parent/presentation/screens/parent_family_screen.dart';

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
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: context.colorScheme.primary,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Monitor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fact_check_outlined),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smartphone),
            label: 'Apps',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Family',
          ),
        ],
      ),
    );
  }
}
