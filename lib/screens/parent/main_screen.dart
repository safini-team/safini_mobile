import 'package:flutter/material.dart';
import 'package:safini/screens/child/tasks/home_tab.dart';
import 'package:safini/screens/child/tasks/tasks_tab.dart';
import 'package:safini/screens/child/tasks/profile_tab.dart';
import 'package:safini/screens/child/tasks/reward_store_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int _totalCoins = 250;
  String _userName = 'Explorer Leo';

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _updateCoins(int delta) {
    setState(() {
      _totalCoins += delta;
    });
  }

  void _updateName(String newName) {
    setState(() {
      _userName = newName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      HomeTab(
        totalCoins: _totalCoins,
        onCoinsChanged: _updateCoins,
      ),
      TasksTab(
        totalCoins: _totalCoins,
        onCoinsChanged: _updateCoins,
      ),
      // For the Store tab, we'll show the RewardStoreScreen content
      // We wrap it to handle the back button or just show it as a view
      RewardStoreScreen(initialCoins: _totalCoins),
      ProfileTab(
        totalCoins: _totalCoins,
        initialName: _userName,
        onNameChanged: _updateName,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF6B3FDB),
          unselectedItemColor: const Color(0xFFBBBBCC),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_box_outlined),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              label: 'Store',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
