import 'package:flutter_test/flutter_test.dart';
import 'package:kintore/src/features/timer/timer_cubit.dart';
import 'package:kintore/src/features/timer/timer_screen.dart';
import 'package:kintore/src/features/workout/workout_models.dart';
import 'package:kintore/src/features/workout/workout_schedule.dart';

void main() {
  group('circuitRoundTitles', () {
    test('セットごとに全種目を順番に並べる', () {
      const item = WorkoutItem.circuit(
        name: 'サーキット',
        summary: 'test',
        workSeconds: 20,
        restSeconds: 10,
        rounds: 3,
        circuitExercises: ['種目A', '種目B', '種目C'],
      );

      final titles = circuitRoundTitles(item);

      expect(titles, [
        '種目A　セット 1 / 3',
        '種目B　セット 1 / 3',
        '種目C　セット 1 / 3',
        '種目A　セット 2 / 3',
        '種目B　セット 2 / 3',
        '種目C　セット 2 / 3',
        '種目A　セット 3 / 3',
        '種目B　セット 3 / 3',
        '種目C　セット 3 / 3',
      ]);
    });

    test('木曜サーキットは1種目の休憩後に2種目へ進む', () {
      final item = workoutForDate(DateTime(2026, 6, 18)).items.first;
      final titles = circuitRoundTitles(item);

      expect(titles.first, 'ケトルベルスイング　セット 1 / 3');
      expect(titles[1], 'バーンマシン　セット 1 / 3');
    });
  });

  group('サーキットタイマーの種目進行', () {
    test('1種目の休憩後は2種目の1セット目へ進む', () {
      const item = WorkoutItem.circuit(
        name: 'サーキット',
        summary: 'test',
        workSeconds: 20,
        restSeconds: 10,
        rounds: 3,
        circuitExercises: ['種目A', '種目B', '種目C'],
      );
      final titles = circuitRoundTitles(item);
      final cubit = TrainingTimerCubit(
        workSeconds: item.workSeconds,
        restSeconds: item.restSeconds,
        roundTitles: titles,
      );

      cubit.startOrPause();
      cubit.skip();
      cubit.skip();
      cubit.skip();

      expect(cubit.state.phase, TimerPhase.work);
      expect(cubit.state.roundIndex, 1);
      expect(cubit.state.title, '種目B　セット 1 / 3');
      cubit.close();
    });
  });
}
