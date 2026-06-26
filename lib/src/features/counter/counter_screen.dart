import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kintore/src/features/counter/counter_cubit.dart';
import 'package:kintore/src/features/progress/workout_progress.dart';
import 'package:kintore/src/features/progress/workout_progress_repository.dart';
import 'package:kintore/src/features/workout/workout_models.dart';
import 'package:kintore/src/utils/format.dart';

class CounterScreen extends StatelessWidget {
  const CounterScreen({
    required this.item,
    this.date,
    this.itemIndex,
    this.repository,
    this.progress,
    super.key,
  });

  final WorkoutItem item;
  final DateTime? date;
  final int? itemIndex;
  final WorkoutProgressRepository? repository;
  final WorkoutProgress? progress;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounterCubit(
        repsPerSet: item.reps,
        totalSets: item.totalSets,
        step: item.countStep,
        initialState: CounterState(
          reps: progress?.reps ?? 0,
          completedSets: progress?.completedSets ?? 0,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(title: Text(item.name)),
        body: BlocListener<CounterCubit, CounterState>(
          listener: (_, state) {
            if (repository == null || date == null || itemIndex == null) return;
            final complete = state.completedSets >= item.totalSets;
            repository!.save(
              WorkoutProgress(
                dateKey: workoutDateKey(date!),
                itemIndex: itemIndex!,
                status: complete
                    ? WorkoutProgressStatus.completed
                    : WorkoutProgressStatus.inProgress,
                reps: state.reps,
                completedSets: state.completedSets,
              ),
            );
          },
          child: CounterBody(item: item),
        ),
      ),
    );
  }
}

class CounterBody extends StatelessWidget {
  const CounterBody({required this.item, super.key});

  final WorkoutItem item;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CounterCubit, CounterState>(
      builder: (context, state) {
        final cubit = context.read<CounterCubit>();
        final complete = state.completedSets >= item.totalSets;
        final side = item.sides == 2
            ? (state.completedSets < item.sets ? '右' : '左')
            : null;
        final displayedSets = complete
            ? item.sets
            : item.sides == 2
            ? state.completedSets % item.sets
            : state.completedSets;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  item.summary,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (side != null && !complete) Chip(label: Text('$side側')),
                Text(
                  complete ? '完了！' : '${item.reps} 回',
                  key: const ValueKey('target_reps_label'),
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  complete ? 'GOOD WORK' : '1セットの目標回数',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      key: const ValueKey('decrement_set_button'),
                      onPressed: state.completedSets > 0
                          ? cubit.decrementSet
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    const SizedBox(width: 18),
                    FilledButton(
                      key: const ValueKey('increment_set_button'),
                      onPressed: complete ? null : cubit.incrementSet,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(150, 64),
                      ),
                      child: const Text('1セット完了'),
                    ),
                  ],
                ),
                const Spacer(),
                const _SetCountdownTimers(),
                const SizedBox(height: 18),
                LinearProgressIndicator(
                  value: item.totalSets == 0
                      ? 0
                      : state.completedSets / item.totalSets,
                ),
                const SizedBox(height: 12),
                Text(
                  'セット $displayedSets / ${item.sets}',
                  key: const ValueKey('set_count_label'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SetCountdownTimers extends StatefulWidget {
  const _SetCountdownTimers();

  @override
  State<_SetCountdownTimers> createState() => _SetCountdownTimersState();
}

class _SetCountdownTimersState extends State<_SetCountdownTimers> {
  static const _timers = [('10秒', 10), ('30秒', 30), ('1分', 60)];

  Timer? _ticker;
  int? _remainingSeconds;

  bool get _isRunning => _ticker?.isActive ?? false;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _start(int seconds) {
    _ticker?.cancel();
    setState(() {
      _remainingSeconds = seconds;
    });
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final remaining = (_remainingSeconds ?? 0) - 1;
      if (remaining <= 0) {
        _ticker?.cancel();
      }
      setState(() {
        _remainingSeconds = remaining.clamp(0, seconds);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final remaining = _remainingSeconds;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            SizedBox(
              width: 62,
              child: Text(
                remaining == null ? '--:--' : formatSeconds(remaining),
                key: const ValueKey('set_timer_count_label'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(width: 8),
            for (final (index, timer) in _timers.indexed) ...[
              Expanded(
                child: OutlinedButton(
                  key: ValueKey('set_timer_${timer.$2}_button'),
                  onPressed: _isRunning ? null : () => _start(timer.$2),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(timer.$1),
                ),
              ),
              if (index != _timers.length - 1) const SizedBox(width: 6),
            ],
          ],
        ),
      ),
    );
  }
}
