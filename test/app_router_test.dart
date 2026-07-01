import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kintore/src/features/counter/counter_screen.dart';
import 'package:kintore/src/features/home/home_screen.dart';
import 'package:kintore/src/features/navigation/app_router.dart';
import 'package:kintore/src/features/navigation/app_routes.dart';
import 'package:kintore/src/features/progress/workout_progress_repository.dart';
import 'package:kintore/src/features/timer/timer_screen.dart';

void main() {
  Future<void> pumpRouter(WidgetTester tester, GoRouter router) async {
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('クイックタイマーボタンからタイマー画面へ遷移する', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = WorkoutProgressRepository();
    final router = createAppRouter(repository);
    addTearDown(router.dispose);
    addTearDown(repository.dispose);

    await pumpRouter(tester, router);

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('quick_timer_180_button')));
    await tester.pumpAndSettle();

    expect(find.byType(TimerScreen), findsOneWidget);
    expect(find.text('3分タイマー'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('有効なワークアウトURLでカウンター画面へ遷移する', (tester) async {
    final repository = WorkoutProgressRepository();
    final router = createAppRouter(repository);
    addTearDown(router.dispose);
    addTearDown(repository.dispose);

    router.go(AppRoutes.workout(DateTime(2026, 6, 16), 0));
    await pumpRouter(tester, router);

    expect(find.byType(CounterScreen), findsOneWidget);
    expect(find.text('軽めメイスハンマー'), findsOneWidget);
    expect(find.text('15 回'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('有効なワークアウトURLでタイマー画面へ遷移する', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = WorkoutProgressRepository();
    final router = createAppRouter(repository);
    addTearDown(router.dispose);
    addTearDown(repository.dispose);

    router.go(AppRoutes.workout(DateTime(2026, 6, 16), 3));
    await pumpRouter(tester, router);

    expect(find.byType(TimerScreen), findsOneWidget);
    expect(find.text('シャドー'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('不正なタイマーURLはエラー画面を表示する', (tester) async {
    final repository = WorkoutProgressRepository();
    final router = createAppRouter(repository);
    addTearDown(router.dispose);
    addTearDown(repository.dispose);

    router.go('/timer/simple/abc');
    await pumpRouter(tester, router);

    expect(find.text('タイマーが見つかりません'), findsOneWidget);
  });

  testWidgets('不正なワークアウトURLはエラー画面を表示する', (tester) async {
    final repository = WorkoutProgressRepository();
    final router = createAppRouter(repository);
    addTearDown(router.dispose);
    addTearDown(repository.dispose);

    router.go('/workout/invalid-date/not-a-number');
    await pumpRouter(tester, router);

    expect(find.text('メニューが見つかりません'), findsOneWidget);
  });

  testWidgets('未定義のパスはエラー画面を表示する', (tester) async {
    final repository = WorkoutProgressRepository();
    final router = createAppRouter(repository);
    addTearDown(router.dispose);
    addTearDown(repository.dispose);

    router.go('/unknown-path');
    await pumpRouter(tester, router);

    expect(find.text('ページが見つかりません'), findsOneWidget);
  });
}
