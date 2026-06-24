import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kintore/src/features/home/home_screen.dart';

void main() {
  testWidgets('火曜日のメニューとクイックタイマーを表示する', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(now: DateTime(2026, 6, 16))),
    );

    expect(find.text('6月16日・火曜日'), findsOneWidget);
    expect(find.text('ハイキック'), findsOneWidget);
    expect(find.byKey(const ValueKey('quick_timer_30_button')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('quick_timer_600_button')),
      findsOneWidget,
    );
  });
}
