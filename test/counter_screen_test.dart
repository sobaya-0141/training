import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kintore/src/features/counter/counter_screen.dart';
import 'package:kintore/src/features/workout/workout_models.dart';

void main() {
  testWidgets('目標回数を固定表示し、セット数だけを操作する', (tester) async {
    const item = WorkoutItem.counter(
      name: 'テスト種目',
      summary: '15回 × 3セット',
      reps: 15,
      sets: 3,
    );

    await tester.pumpWidget(const MaterialApp(home: CounterScreen(item: item)));

    expect(find.text('15 回'), findsOneWidget);
    expect(find.text('セット 0 / 3'), findsOneWidget);
    expect(find.byKey(const ValueKey('increment_set_button')), findsOneWidget);
    expect(find.byKey(const ValueKey('decrement_set_button')), findsOneWidget);
    expect(find.byKey(const ValueKey('set_timer_10_button')), findsOneWidget);
    expect(find.byKey(const ValueKey('set_timer_30_button')), findsOneWidget);
    expect(find.byKey(const ValueKey('set_timer_60_button')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('increment_set_button')));
    await tester.pump();

    expect(find.text('セット 1 / 3'), findsOneWidget);
    expect(find.byKey(const ValueKey('rep_count_label')), findsNothing);
  });

  testWidgets('セット用タイマーは準備時間なしで指定秒数から開始する', (tester) async {
    const item = WorkoutItem.counter(
      name: 'テスト種目',
      summary: '15回 × 3セット',
      reps: 15,
      sets: 3,
    );

    await tester.pumpWidget(const MaterialApp(home: CounterScreen(item: item)));

    await tester.tap(find.byKey(const ValueKey('set_timer_10_button')));
    await tester.pump();

    expect(find.text('0:10'), findsOneWidget);
    expect(find.text('0:05'), findsNothing);

    await tester.pump(const Duration(seconds: 1));

    expect(find.text('0:09'), findsOneWidget);
  });

  testWidgets('セット用タイマーは残り2秒までカウントダウンする', (tester) async {
    const item = WorkoutItem.counter(
      name: 'テスト種目',
      summary: '15回 × 3セット',
      reps: 15,
      sets: 3,
    );

    await tester.pumpWidget(const MaterialApp(home: CounterScreen(item: item)));

    await tester.tap(find.byKey(const ValueKey('set_timer_10_button')));
    await tester.pump();

    expect(find.text('0:10'), findsOneWidget);

    await tester.pump(const Duration(seconds: 8));

    expect(find.text('0:02'), findsOneWidget);
  });
}
