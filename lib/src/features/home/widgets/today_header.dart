import 'package:flutter/material.dart';
import 'package:kintore/src/features/workout/workout_models.dart';

class TodayHeader extends StatelessWidget {
  const TodayHeader({required this.date, required this.workout, super.key});

  final DateTime date;
  final DailyWorkout workout;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, colors.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${date.month}月${date.day}日・${workout.label}',
            key: const ValueKey('today_label'),
            style: TextStyle(color: colors.onPrimary.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 10),
          Text(
            workout.items.isEmpty ? 'REST DAY' : 'TODAY’S WORKOUT',
            style: TextStyle(
              color: colors.onPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 26,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            workout.subtitle,
            style: TextStyle(
              color: colors.onPrimary.withValues(alpha: 0.9),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
