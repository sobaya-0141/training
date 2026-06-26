import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

enum TimerPhase { ready, preparing, work, rest, paused, completed }

enum TimerCue { countdown, start, stop }

class TrainingTimerState {
  const TrainingTimerState({
    required this.phase,
    required this.remainingSeconds,
    required this.roundIndex,
    required this.totalRounds,
    required this.title,
    this.previousPhase = TimerPhase.ready,
  });

  final TimerPhase phase;
  final TimerPhase previousPhase;
  final int remainingSeconds;
  final int roundIndex;
  final int totalRounds;
  final String title;

  bool get isRunning =>
      phase == TimerPhase.preparing ||
      phase == TimerPhase.work ||
      phase == TimerPhase.rest;
  bool get isComplete => phase == TimerPhase.completed;

  TrainingTimerState copyWith({
    TimerPhase? phase,
    TimerPhase? previousPhase,
    int? remainingSeconds,
    int? roundIndex,
    String? title,
  }) {
    return TrainingTimerState(
      phase: phase ?? this.phase,
      previousPhase: previousPhase ?? this.previousPhase,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      roundIndex: roundIndex ?? this.roundIndex,
      totalRounds: totalRounds,
      title: title ?? this.title,
    );
  }
}

class TrainingTimerCubit extends Cubit<TrainingTimerState> {
  static const int preparingSeconds = 5;

  TrainingTimerCubit({
    required this.workSeconds,
    required this.restSeconds,
    required this.roundTitles,
    this.onCue,
    TrainingTimerState? initialState,
  }) : super(
         initialState ??
             TrainingTimerState(
               phase: TimerPhase.ready,
               remainingSeconds: workSeconds,
               roundIndex: 0,
               totalRounds: roundTitles.length,
               title: roundTitles.first,
             ),
       );

  final int workSeconds;
  final int restSeconds;
  final List<String> roundTitles;
  final void Function(TimerCue cue)? onCue;
  Timer? _ticker;

  void startOrPause() {
    if (state.isComplete) {
      return;
    }
    if (state.isRunning) {
      _ticker?.cancel();
      emit(
        state.copyWith(phase: TimerPhase.paused, previousPhase: state.phase),
      );
      return;
    }
    final phase = state.phase == TimerPhase.paused
        ? state.previousPhase
        : TimerPhase.preparing;
    emit(
      state.copyWith(
        phase: phase,
        remainingSeconds: state.phase == TimerPhase.ready
            ? preparingSeconds
            : state.remainingSeconds,
      ),
    );
    _startTicker();
  }

  void skip() {
    _ticker?.cancel();
    _advance();
  }

  void reset() {
    _ticker?.cancel();
    emit(
      TrainingTimerState(
        phase: TimerPhase.ready,
        remainingSeconds: workSeconds,
        roundIndex: 0,
        totalRounds: roundTitles.length,
        title: roundTitles.first,
      ),
    );
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds <= 1) {
        _ticker?.cancel();
        _advance();
      } else {
        final remaining = state.remainingSeconds - 1;
        emit(state.copyWith(remainingSeconds: remaining));
        if (state.phase == TimerPhase.preparing && remaining <= 3) {
          onCue?.call(TimerCue.countdown);
        }
      }
    });
  }

  void _advance() {
    if (state.phase == TimerPhase.preparing) {
      onCue?.call(TimerCue.start);
      emit(
        state.copyWith(phase: TimerPhase.work, remainingSeconds: workSeconds),
      );
      _startTicker();
      return;
    }
    if (state.phase == TimerPhase.work && restSeconds > 0) {
      onCue?.call(TimerCue.stop);
      emit(
        state.copyWith(phase: TimerPhase.rest, remainingSeconds: restSeconds),
      );
      _startTicker();
      return;
    }
    final nextRound = state.roundIndex + 1;
    if (nextRound >= roundTitles.length) {
      onCue?.call(TimerCue.stop);
      emit(state.copyWith(phase: TimerPhase.completed, remainingSeconds: 0));
      return;
    }
    emit(
      state.copyWith(
        phase: TimerPhase.work,
        remainingSeconds: workSeconds,
        roundIndex: nextRound,
        title: roundTitles[nextRound],
      ),
    );
    onCue?.call(TimerCue.start);
    _startTicker();
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
