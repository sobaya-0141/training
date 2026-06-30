import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kintore/src/features/calendar/calendar_screen.dart';
import 'package:kintore/src/features/counter/counter_screen.dart';
import 'package:kintore/src/features/home/home_screen.dart';
import 'package:kintore/src/features/navigation/app_routes.dart';
import 'package:kintore/src/features/navigation/main_shell.dart';
import 'package:kintore/src/features/progress/workout_progress_repository.dart';
import 'package:kintore/src/features/timer/timer_screen.dart';
import 'package:kintore/src/features/workout/workout_models.dart';
import 'package:kintore/src/features/workout/workout_schedule.dart';

GoRouter createAppRouter(WorkoutProgressRepository repository) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home,
    errorBuilder: (context, state) =>
        _notFoundScreen('ページが見つかりません'),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) =>
                    HomeScreen(repository: repository),
                routes: [
                  GoRoute(
                    path: 'timer/simple/:seconds',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final seconds = int.tryParse(
                        state.pathParameters['seconds'] ?? '',
                      );
                      if (seconds == null || seconds <= 0) {
                        return _notFoundScreen('タイマーが見つかりません');
                      }
                      final title = state.uri.queryParameters['title'] ?? '';
                      return TimerScreen.simple(
                        title: title,
                        seconds: seconds,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'workout/:date/:index',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final date = tryParseWorkoutDate(
                        state.pathParameters['date'] ?? '',
                      );
                      final index = int.tryParse(
                        state.pathParameters['index'] ?? '',
                      );
                      if (date == null || index == null) {
                        return _notFoundScreen('メニューが見つかりません');
                      }
                      return _workoutScreen(repository, date, index);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.calendar,
                builder: (context, state) =>
                    CalendarScreen(repository: repository),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

Widget _notFoundScreen(String message) {
  return Scaffold(
    body: SafeArea(child: Center(child: Text(message))),
  );
}

Widget _workoutScreen(
  WorkoutProgressRepository repository,
  DateTime date,
  int index,
) {
  final workout = workoutForDate(date);
  if (index < 0 || index >= workout.items.length) {
    return _notFoundScreen('メニューが見つかりません');
  }
  final item = workout.items[index];
  final progress = repository.progressFor(date, index);
  return switch (item.kind) {
    WorkoutKind.counter => CounterScreen(
      item: item,
      date: date,
      itemIndex: index,
      repository: repository,
      progress: progress,
    ),
    WorkoutKind.interval => TimerScreen.interval(
      item: item,
      date: date,
      itemIndex: index,
      repository: repository,
      progress: progress,
    ),
    WorkoutKind.circuit => TimerScreen.circuit(
      item: item,
      date: date,
      itemIndex: index,
      repository: repository,
      progress: progress,
    ),
  };
}
