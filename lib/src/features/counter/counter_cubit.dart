import 'package:flutter_bloc/flutter_bloc.dart';

class CounterState {
  const CounterState({this.completedSets = 0});

  final int completedSets;
}

class CounterCubit extends Cubit<CounterState> {
  CounterCubit({required this.totalSets, CounterState? initialState})
    : super(initialState ?? const CounterState());

  final int totalSets;

  void incrementSet() {
    if (state.completedSets >= totalSets) return;
    emit(CounterState(completedSets: state.completedSets + 1));
  }

  void decrementSet() {
    if (state.completedSets <= 0) return;
    emit(CounterState(completedSets: state.completedSets - 1));
  }
}
