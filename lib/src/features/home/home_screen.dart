import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kintore/src/features/home/widgets/quick_timers.dart';
import 'package:kintore/src/features/home/widgets/today_header.dart';
import 'package:kintore/src/features/home/widgets/workout_card.dart';
import 'package:kintore/src/features/progress/workout_progress_cubit.dart';
import 'package:kintore/src/features/workout/workout_models.dart';
import 'package:kintore/src/features/workout/workout_schedule.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.now, this.progressCubit});

  final DateTime? now;
  final WorkoutProgressCubit? progressCubit;

  @override
  Widget build(BuildContext context) {
    final date = now ?? DateTime.now();
    final workout = workoutForDate(date);
    if (progressCubit == null) {
      return SafeArea(
        child: _HomeContent(date: date, workout: workout),
      );
    }
    return SafeArea(
      child: BlocBuilder<WorkoutProgressCubit, WorkoutProgressState>(
        bloc: progressCubit,
        builder: (context, _) => _HomeContent(
          date: date,
          workout: workout,
          progressCubit: progressCubit,
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.date,
    required this.workout,
    this.progressCubit,
  });

  final DateTime date;
  final DailyWorkout workout;
  final WorkoutProgressCubit? progressCubit;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          sliver: SliverToBoxAdapter(
            child: TodayHeader(date: date, workout: workout),
          ),
        ),
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 22),
          sliver: SliverToBoxAdapter(child: QuickTimers()),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(
            child: Text(
              workout.items.isEmpty ? '今日は休養日' : '今日のトレーニング',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        if (workout.items.isEmpty)
          const SliverPadding(
            padding: EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(child: RestDayCard()),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
            sliver: SliverList.separated(
              itemCount: workout.items.length,
              itemBuilder: (context, index) => WorkoutCard(
                key: ValueKey('workout_${index}_card'),
                item: workout.items[index],
                index: index,
                date: date,
                progressCubit: progressCubit,
              ),
              separatorBuilder: (_, _) => const SizedBox(height: 12),
            ),
          ),
      ],
    );
  }
}

class RestDayCard extends StatelessWidget {
  const RestDayCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Icon(
              Icons.self_improvement,
              size: 42,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            const Expanded(child: Text('よく休んで、次のトレーニングに備えましょう。')),
          ],
        ),
      ),
    );
  }
}
