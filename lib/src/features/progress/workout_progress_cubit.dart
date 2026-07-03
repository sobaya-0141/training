import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kintore/src/features/progress/workout_progress.dart';
import 'package:kintore/src/features/progress/workout_progress_repository.dart';

class WorkoutProgressState {
  WorkoutProgressState(this._progressByKey)
    : _progressByDate = _groupByDate(_progressByKey);

  final Map<String, WorkoutProgress> _progressByKey;

  // カレンダー画面が日付単位でまとめて参照するため、生成時に
  // 日付キーで索引しておく(セルごとの全件走査を避ける)。
  final Map<String, List<WorkoutProgress>> _progressByDate;

  static Map<String, List<WorkoutProgress>> _groupByDate(
    Map<String, WorkoutProgress> progressByKey,
  ) {
    final grouped = <String, List<WorkoutProgress>>{};
    for (final progress in progressByKey.values) {
      grouped.putIfAbsent(progress.dateKey, () => []).add(progress);
    }
    return grouped;
  }

  WorkoutProgress? progressFor(DateTime date, int itemIndex) =>
      _progressByKey['${workoutDateKey(date)}:$itemIndex'];

  List<WorkoutProgress> progressForDate(DateTime date) =>
      _progressByDate[workoutDateKey(date)] ?? const [];
}

class WorkoutProgressCubit extends Cubit<WorkoutProgressState> {
  WorkoutProgressCubit(this._repository)
    : super(WorkoutProgressState(_repository.snapshot()));

  final WorkoutProgressRepository _repository;

  Future<void> save(WorkoutProgress progress) async {
    final saveFuture = _repository.save(progress);
    emit(WorkoutProgressState(_repository.snapshot()));
    await saveFuture;
  }
}
