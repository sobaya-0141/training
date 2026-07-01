import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kintore/src/features/progress/workout_progress.dart';
import 'package:kintore/src/features/progress/workout_progress_repository.dart';

class WorkoutProgressState {
  const WorkoutProgressState(this._progressByKey);

  final Map<String, WorkoutProgress> _progressByKey;

  WorkoutProgress? progressFor(DateTime date, int itemIndex) =>
      _progressByKey['${workoutDateKey(date)}:$itemIndex'];

  List<WorkoutProgress> progressForDate(DateTime date) {
    final dateKey = workoutDateKey(date);
    return [
      for (final progress in _progressByKey.values)
        if (progress.dateKey == dateKey) progress,
    ];
  }
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
