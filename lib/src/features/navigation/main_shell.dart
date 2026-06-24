import 'package:flutter/material.dart';
import 'package:kintore/src/features/calendar/calendar_screen.dart';
import 'package:kintore/src/features/home/home_screen.dart';
import 'package:kintore/src/features/progress/workout_progress_repository.dart';

class MainShell extends StatefulWidget {
  const MainShell({required this.repository, super.key});

  final WorkoutProgressRepository repository;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(repository: widget.repository),
          CalendarScreen(repository: widget.repository),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'トレーニング',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'カレンダー',
          ),
        ],
      ),
    );
  }
}
