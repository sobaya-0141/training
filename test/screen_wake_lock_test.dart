import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kintore/src/screen_wake_lock.dart';

void main() {
  testWidgets('foreground で画面を維持し background で解除する', (tester) async {
    final changes = <bool>[];

    Future<void> enable() async => changes.add(true);
    Future<void> disable() async => changes.add(false);

    await tester.pumpWidget(
      KeepScreenOn(
        enable: enable,
        disable: disable,
        child: const SizedBox.shrink(),
      ),
    );

    expect(changes, [true]);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    expect(changes, [true, false]);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect(changes, [true, false, true]);

    await tester.pumpWidget(const SizedBox.shrink());
    expect(changes, [true, false, true, false]);
  });
}
