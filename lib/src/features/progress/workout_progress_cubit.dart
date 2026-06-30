import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kintore/src/features/progress/workout_progress.dart';
import 'package:kintore/src/features/progress/workout_progress_repository.dart';

class WorkoutProgressState {
  const WorkoutProgressState({this.revision = 0});

  final int revision;
}

class WorkoutProgressCubit extends Cubit<WorkoutProgressState> {
  WorkoutProgressCubit(this._repository) : super(const WorkoutProgressState());

  final WorkoutProgressRepository _repository;

  WorkoutProgress? progressFor(DateTime date, int itemIndex) =>
      _repository.progressFor(date, itemIndex);

  List<WorkoutProgress> progressForDate(DateTime date) =>
      _repository.progressForDate(date);

  Future<void> save(WorkoutProgress progress) async {
    await _repository.save(progress);
    emit(WorkoutProgressState(revision: state.revision + 1));
  }
}
