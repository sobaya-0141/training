import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kintore/src/features/progress/workout_progress.dart';
import 'package:kintore/src/features/progress/workout_progress_repository.dart';
import 'package:kintore/src/features/timer/timer_cubit.dart';
import 'package:kintore/src/features/timer/timer_cue_player.dart';
import 'package:kintore/src/features/workout/workout_models.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen._({
    required this.title,
    required this.workSeconds,
    required this.restSeconds,
    required this.roundTitles,
    this.date,
    this.itemIndex,
    this.repository,
    this.progress,
  });

  factory TimerScreen.simple({required String title, required int seconds}) {
    return TimerScreen._(
      title: '$titleタイマー',
      workSeconds: seconds,
      restSeconds: 0,
      roundTitles: const ['タイマー'],
    );
  }

  factory TimerScreen.interval({
    required WorkoutItem item,
    DateTime? date,
    int? itemIndex,
    WorkoutProgressRepository? repository,
    WorkoutProgress? progress,
  }) {
    return TimerScreen._(
      title: item.name,
      workSeconds: item.workSeconds,
      restSeconds: item.restSeconds,
      roundTitles: [
        for (var round = 1; round <= item.rounds; round++)
          '${item.name} $round / ${item.rounds}',
      ],
      date: date,
      itemIndex: itemIndex,
      repository: repository,
      progress: progress,
    );
  }

  factory TimerScreen.circuit({
    required WorkoutItem item,
    DateTime? date,
    int? itemIndex,
    WorkoutProgressRepository? repository,
    WorkoutProgress? progress,
  }) {
    return TimerScreen._(
      title: item.name,
      workSeconds: item.workSeconds,
      restSeconds: item.restSeconds,
      roundTitles: [
        for (var set = 1; set <= item.rounds; set++)
          for (final exercise in item.circuitExercises)
            '$exercise　セット $set / ${item.rounds}',
      ],
      date: date,
      itemIndex: itemIndex,
      repository: repository,
      progress: progress,
    );
  }

  final String title;
  final int workSeconds;
  final int restSeconds;
  final List<String> roundTitles;
  final DateTime? date;
  final int? itemIndex;
  final WorkoutProgressRepository? repository;
  final WorkoutProgress? progress;

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final _cuePlayer = TimerCuePlayer();

  @override
  void initState() {
    super.initState();
    _cuePlayer.initialize();
  }

  @override
  void dispose() {
    _cuePlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restoredPhase = widget.progress?.timerPhase == null
        ? null
        : TimerPhase.values.byName(widget.progress!.timerPhase!);
    final restoredRound = (widget.progress?.roundIndex ?? 0).clamp(
      0,
      widget.roundTitles.length - 1,
    );
    final initialState = widget.progress == null
        ? null
        : TrainingTimerState(
            phase: restoredPhase == TimerPhase.completed
                ? TimerPhase.completed
                : TimerPhase.paused,
            previousPhase:
                restoredPhase == null ||
                    restoredPhase == TimerPhase.ready ||
                    restoredPhase == TimerPhase.paused
                ? TimerPhase.work
                : restoredPhase,
            remainingSeconds: widget.progress!.remainingSeconds,
            roundIndex: restoredRound,
            totalRounds: widget.roundTitles.length,
            title: widget.roundTitles[restoredRound],
          );
    return BlocProvider(
      create: (_) => TrainingTimerCubit(
        workSeconds: widget.workSeconds,
        restSeconds: widget.restSeconds,
        roundTitles: widget.roundTitles,
        initialState: initialState,
        onCue: _cuePlayer.play,
      ),
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: BlocListener<TrainingTimerCubit, TrainingTimerState>(
          listener: (_, state) {
            if (widget.repository == null ||
                widget.date == null ||
                widget.itemIndex == null) {
              return;
            }
            if (state.phase == TimerPhase.ready) return;
            widget.repository!.save(
              WorkoutProgress(
                dateKey: workoutDateKey(widget.date!),
                itemIndex: widget.itemIndex!,
                status: state.isComplete
                    ? WorkoutProgressStatus.completed
                    : WorkoutProgressStatus.inProgress,
                timerPhase: state.phase == TimerPhase.paused
                    ? state.previousPhase.name
                    : state.phase.name,
                remainingSeconds: state.remainingSeconds,
                roundIndex: state.roundIndex,
              ),
            );
          },
          child: const TimerBody(),
        ),
      ),
    );
  }
}

class TimerBody extends StatelessWidget {
  const TimerBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrainingTimerCubit, TrainingTimerState>(
      builder: (context, state) {
        final cubit = context.read<TrainingTimerCubit>();
        final colors = Theme.of(context).colorScheme;
        final phaseColor = switch (state.phase) {
          TimerPhase.rest => colors.tertiary,
          TimerPhase.preparing => Colors.orange,
          TimerPhase.completed => Colors.green,
          _ => colors.primary,
        };
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  _phaseLabel(state.phase),
                  key: const ValueKey('timer_phase_label'),
                  style: TextStyle(
                    color: phaseColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  state.title,
                  key: const ValueKey('current_exercise_label'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: switch (state.phase) {
                          TimerPhase.ready => 0.0,
                          TimerPhase.completed => 1.0,
                          _ => null,
                        },
                        strokeWidth: 18,
                        color: phaseColor,
                        backgroundColor: phaseColor.withValues(alpha: 0.15),
                      ),
                      Center(
                        child: Text(
                          _formatSeconds(state.remainingSeconds),
                          key: const ValueKey('timer_count_label'),
                          style: const TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.w900,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  'ラウンド ${state.roundIndex + 1} / ${state.totalRounds}',
                  key: const ValueKey('round_count_label'),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        key: const ValueKey('start_pause_timer_button'),
                        onPressed: state.isComplete ? null : cubit.startOrPause,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                        ),
                        icon: Icon(
                          state.isRunning ? Icons.pause : Icons.play_arrow,
                        ),
                        label: Text(
                          state.isRunning
                              ? '一時停止'
                              : state.phase == TimerPhase.paused
                              ? '再開'
                              : 'スタート',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        key: const ValueKey('skip_timer_button'),
                        onPressed: state.isComplete ? null : cubit.skip,
                        child: const Text('次へ'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

String _phaseLabel(TimerPhase phase) => switch (phase) {
  TimerPhase.ready => 'READY',
  TimerPhase.preparing => 'GET READY',
  TimerPhase.work => 'WORK',
  TimerPhase.rest => 'REST',
  TimerPhase.paused => 'PAUSE',
  TimerPhase.completed => 'COMPLETE',
};

String _formatSeconds(int seconds) {
  final minutes = seconds ~/ 60;
  final remaining = seconds % 60;
  return '$minutes:${remaining.toString().padLeft(2, '0')}';
}
