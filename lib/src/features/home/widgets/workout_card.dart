import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kintore/src/features/navigation/app_routes.dart';
import 'package:kintore/src/features/progress/workout_progress.dart';
import 'package:kintore/src/features/progress/workout_progress_cubit.dart';
import 'package:kintore/src/features/workout/workout_models.dart';

class WorkoutCard extends StatelessWidget {
  const WorkoutCard({
    required this.item,
    required this.index,
    required this.date,
    this.progressCubit,
    super.key,
  });

  final WorkoutItem item;
  final int index;
  final DateTime date;
  final WorkoutProgressCubit? progressCubit;

  @override
  Widget build(BuildContext context) {
    final progress = progressCubit?.progressFor(date, index);
    final status = progress?.status ?? WorkoutProgressStatus.notStarted;
    final statusColor = switch (status) {
      WorkoutProgressStatus.completed => Colors.green,
      WorkoutProgressStatus.inProgress => Colors.orange,
      WorkoutProgressStatus.notStarted => null,
    };
    return Card(
      color: statusColor?.withValues(alpha: 0.12),
      shape: statusColor == null
          ? null
          : RoundedRectangleBorder(
              side: BorderSide(color: statusColor.withValues(alpha: 0.6)),
              borderRadius: BorderRadius.circular(12),
            ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('workout_${index}_button'),
        onTap: () => context.push(AppRoutes.workout(date, index)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(_iconFor(item.kind)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.summary,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (statusColor != null)
                Icon(
                  status == WorkoutProgressStatus.completed
                      ? Icons.check_circle
                      : Icons.pause_circle,
                  color: statusColor,
                )
              else
                const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(WorkoutKind kind) => switch (kind) {
    WorkoutKind.counter => Icons.fitness_center,
    WorkoutKind.interval => Icons.timer_outlined,
    WorkoutKind.circuit => Icons.loop,
  };
}
