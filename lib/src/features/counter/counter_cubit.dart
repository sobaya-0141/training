import 'package:flutter_bloc/flutter_bloc.dart';

class CounterState {
  const CounterState({this.reps = 0, this.completedSets = 0});

  final int reps;
  final int completedSets;

  CounterState copyWith({int? reps, int? completedSets}) {
    return CounterState(
      reps: reps ?? this.reps,
      completedSets: completedSets ?? this.completedSets,
    );
  }
}

class CounterCubit extends Cubit<CounterState> {
  CounterCubit({
    required this.repsPerSet,
    required this.totalSets,
    required this.step,
    CounterState? initialState,
  }) : super(initialState ?? const CounterState());

  final int repsPerSet;
  final int totalSets;
  final int step;

  void incrementSet() {
    if (state.completedSets >= totalSets) return;
    emit(CounterState(completedSets: state.completedSets + 1));
  }

  void decrementSet() {
    if (state.completedSets <= 0) return;
    emit(CounterState(completedSets: state.completedSets - 1));
  }
}
