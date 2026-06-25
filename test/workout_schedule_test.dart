import 'package:flutter_test/flutter_test.dart';
import 'package:kintore/src/features/workout/workout_schedule.dart';

void main() {
  group('曜日別トレーニング', () {
    test('月曜日は6種目を返す', () {
      final workout = workoutForDate(DateTime(2026, 6, 15));

      expect(workout.label, '月曜日');
      expect(workout.items, hasLength(6));
      expect(workout.items.last.name, 'ミドルキック');
      expect(workout.items[4].reps, 10);
      expect(workout.items[4].sets, 6);
      expect(workout.items[5].reps, 10);
      expect(workout.items[5].sets, 6);
    });

    test('30回のキックは合計回数を変えず10回3セットに分割する', () {
      final workout = workoutForDate(DateTime(2026, 6, 16));
      final highKick = workout.items[1];

      expect(highKick.summary, '10本 × 3セット × 左右');
      expect(highKick.reps, 10);
      expect(highKick.sets, 3);
      expect(highKick.sides, 2);
      expect(highKick.reps * highKick.totalSets, 60);
    });

    test('バーンマシンはセット間に休憩を入れる', () {
      final workout = workoutForDate(DateTime(2026, 6, 17));
      final burnMachine = workout.items[1];

      expect(burnMachine.name, 'バーンマシン');
      expect(burnMachine.summary, '10秒 × 10セット（休憩50秒）');
      expect(burnMachine.workSeconds, 10);
      expect(burnMachine.restSeconds, 50);
      expect(burnMachine.rounds, 10);
    });

    test('木曜日はサーキットと30秒ラッシュを返す', () {
      final workout = workoutForDate(DateTime(2026, 6, 18));

      expect(workout.items, hasLength(2));
      expect(workout.items.first.circuitExercises, hasLength(6));
      expect(workout.items.last.rounds, 8);
    });

    test('金曜日は休養日を返す', () {
      final workout = workoutForDate(DateTime(2026, 6, 19));

      expect(workout.label, '金曜日');
      expect(workout.items, isEmpty);
    });
  });
}
