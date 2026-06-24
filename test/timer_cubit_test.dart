import 'package:flutter_test/flutter_test.dart';
import 'package:kintore/src/features/timer/timer_cubit.dart';

void main() {
  group('TrainingTimerCubit', () {
    test('運動の次に休憩へ進む', () {
      final cubit = TrainingTimerCubit(
        workSeconds: 20,
        restSeconds: 10,
        roundTitles: const ['種目1', '種目2'],
      );

      cubit.startOrPause();
      cubit.skip();
      cubit.skip();

      expect(cubit.state.phase, TimerPhase.rest);
      expect(cubit.state.remainingSeconds, 10);
      cubit.close();
    });

    test('休憩の次に次種目へ進む', () {
      final cubit = TrainingTimerCubit(
        workSeconds: 20,
        restSeconds: 10,
        roundTitles: const ['種目1', '種目2'],
      );

      cubit.startOrPause();
      cubit.skip();
      cubit.skip();
      cubit.skip();

      expect(cubit.state.phase, TimerPhase.work);
      expect(cubit.state.title, '種目2');
      expect(cubit.state.roundIndex, 1);
      cubit.close();
    });
  });
}
