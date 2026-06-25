import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kintore/src/features/timer/timer_screen.dart';

void main() {
  testWidgets('開始前はタイマーのプログレスが回らない', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: TimerScreen.simple(title: 'テスト', seconds: 30)),
    );

    final progress = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    expect(progress.value, 0);

    expect(
      find.byKey(const ValueKey('start_pause_timer_button')),
      findsOneWidget,
    );
  });
}
