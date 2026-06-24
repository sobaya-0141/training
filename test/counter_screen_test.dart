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

    await tester.tap(find.byKey(const ValueKey('increment_set_button')));
    await tester.pump();

    expect(find.text('セット 1 / 3'), findsOneWidget);
    expect(find.byKey(const ValueKey('rep_count_label')), findsNothing);
  });
}
