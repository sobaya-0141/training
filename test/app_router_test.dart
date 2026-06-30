import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kintore/src/features/home/home_screen.dart';
import 'package:kintore/src/features/navigation/app_router.dart';
import 'package:kintore/src/features/progress/workout_progress_repository.dart';
import 'package:kintore/src/features/timer/timer_screen.dart';

void main() {
  testWidgets('クイックタイマーボタンからタイマー画面へ遷移する', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = WorkoutProgressRepository();
    final router = createAppRouter(repository);
    addTearDown(router.dispose);
    addTearDown(repository.dispose);

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('quick_timer_180_button')));
    await tester.pumpAndSettle();

    expect(find.byType(TimerScreen), findsOneWidget);
    expect(find.text('3分タイマー'), findsOneWidget);
  });

  testWidgets('不正なタイマーURLはエラー画面を表示する', (tester) async {
    final repository = WorkoutProgressRepository();
    final router = createAppRouter(repository);
    addTearDown(router.dispose);
    addTearDown(repository.dispose);

    router.go('/timer/simple/abc');
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router),
    );
    await tester.pumpAndSettle();

    expect(find.text('タイマーが見つかりません'), findsOneWidget);
  });

  testWidgets('不正なワークアウトURLはエラー画面を表示する', (tester) async {
    final repository = WorkoutProgressRepository();
    final router = createAppRouter(repository);
    addTearDown(router.dispose);
    addTearDown(repository.dispose);

    router.go('/workout/invalid-date/not-a-number');
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router),
    );
    await tester.pumpAndSettle();

    expect(find.text('メニューが見つかりません'), findsOneWidget);
  });
}
