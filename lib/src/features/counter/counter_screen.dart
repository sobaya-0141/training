import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kintore/src/features/counter/counter_cubit.dart';
import 'package:kintore/src/features/progress/workout_progress.dart';
import 'package:kintore/src/features/progress/workout_progress_repository.dart';
import 'package:kintore/src/features/workout/workout_models.dart';

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
