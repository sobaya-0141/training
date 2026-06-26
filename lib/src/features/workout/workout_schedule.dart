import 'package:kintore/src/features/workout/workout_models.dart';

const circuitExercises = [
  'ケトルベルスイング',
  'バーンマシン',
  'ジャンプランジ',
  'プッシュアップ',
  'メイススイング（左右）',
  '縄跳び',
];

const workoutSchedule = <int, DailyWorkout>{
  DateTime.monday: DailyWorkout(
    weekday: DateTime.monday,
    label: '月曜日',
    subtitle: '爆発力 & 打撃',
    items: [
      WorkoutItem.counter(
        name: 'ケトルベルスイング（重）',
        summary: '5回 × 5セット',
        reps: 5,
        sets: 5,
      ),
      WorkoutItem.counter(
        name: 'ジャンプスクワット',
        summary: '5回 × 5セット',
        reps: 5,
        sets: 5,
      ),
      WorkoutItem.counter(
        name: 'メディシンボール回旋投げ',
        summary: '5回 × 5セット',
        reps: 5,
        sets: 5,
      ),
      WorkoutItem.counter(
        name: 'メイスハンマー',
        summary: '10回 × 3セット',
        reps: 10,
        sets: 3,
      ),
      WorkoutItem.counter(
        name: 'ワンツー',
        summary: '10発 × 6セット',
        reps: 10,
        sets: 6,
      ),
      WorkoutItem.counter(
        name: 'ミドルキック',
        summary: '10本 × 6セット × 左右',
        reps: 10,
        sets: 6,
        sides: 2,
      ),
    ],
  ),
  DateTime.tuesday: DailyWorkout(
    weekday: DateTime.tuesday,
    label: '火曜日',
    subtitle: '軽負荷 & キック',
    items: [
      WorkoutItem.counter(
        name: '軽めメイスハンマー',
        summary: '15回 × 2セット',
        reps: 15,
        sets: 2,
      ),
      WorkoutItem.counter(
        name: 'ハイキック',
        summary: '10本 × 3セット × 左右',
        reps: 10,
        sets: 3,
        sides: 2,
      ),
      WorkoutItem.counter(
        name: 'ミドルキック',
        summary: '10本 × 3セット × 左右',
        reps: 10,
        sets: 3,
        sides: 2,
      ),
      WorkoutItem.interval(
        name: 'シャドー',
        summary: '2分 × 5R（休憩30秒）',
        workSeconds: 120,
        restSeconds: 30,
        rounds: 5,
      ),
    ],
  ),
  DateTime.wednesday: DailyWorkout(
    weekday: DateTime.wednesday,
    label: '水曜日',
    subtitle: 'パワー持久力',
    items: [
      WorkoutItem.counter(
        name: 'メディシンボール',
        summary: '8回 × 3セット',
        reps: 8,
        sets: 3,
      ),
      WorkoutItem.interval(
        name: 'バーンマシン',
        summary: '10秒 × 10セット（休憩50秒）',
        workSeconds: 10,
        restSeconds: 50,
        rounds: 10,
      ),
      WorkoutItem.interval(
        name: 'パンチ連打',
        summary: '10秒 × 8セット（休憩50秒）',
        workSeconds: 10,
        restSeconds: 50,
        rounds: 8,
      ),
      WorkoutItem.interval(
        name: 'シャドー',
        summary: '2分 × 5R（休憩30秒）',
        workSeconds: 120,
        restSeconds: 30,
        rounds: 5,
      ),
    ],
  ),
  DateTime.thursday: DailyWorkout(
    weekday: DateTime.thursday,
    label: '木曜日',
    subtitle: '全身サーキット',
    items: [
      WorkoutItem.circuit(
        name: 'サーキットトレーニング',
        summary: '20秒運動 / 10秒休憩・6種目 × 3セット',
        workSeconds: 20,
        restSeconds: 10,
        rounds: 3,
        circuitExercises: circuitExercises,
      ),
      WorkoutItem.interval(
        name: '30秒ラッシュ',
        summary: '30秒 × 8R（休憩30秒）',
        workSeconds: 30,
        restSeconds: 30,
        rounds: 8,
      ),
    ],
  ),
};

DailyWorkout workoutForDate(DateTime date) {
  return workoutSchedule[date.weekday] ??
      DailyWorkout(
        weekday: date.weekday,
        label: weekdayLabel(date.weekday),
        subtitle: 'リカバリー',
        items: const [],
      );
}

String weekdayLabel(int weekday) =>
    const ['月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日', '日曜日'][weekday - 1];
