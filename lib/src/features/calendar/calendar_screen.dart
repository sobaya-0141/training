import 'package:flutter/material.dart';
import 'package:kintore/src/features/progress/workout_progress.dart';
import 'package:kintore/src/features/progress/workout_progress_repository.dart';
import 'package:kintore/src/features/workout/workout_schedule.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({required this.repository, super.key});

  final WorkoutProgressRepository repository;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _visibleMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: widget.repository,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Text(
              'トレーニング記録',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                IconButton(
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    '${_visibleMonth.year}年 ${_visibleMonth.month}月',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _changeMonth(1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                for (final label in ['月', '火', '水', '木', '金', '土', '日'])
                  Expanded(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _CalendarGrid(
              month: _visibleMonth,
              selectedDate: _selectedDate,
              repository: widget.repository,
              onSelected: (date) => setState(() => _selectedDate = date),
            ),
            const SizedBox(height: 18),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(color: Colors.orange, label: '途中'),
                SizedBox(width: 20),
                _LegendDot(color: Colors.green, label: '完了'),
              ],
            ),
            const SizedBox(height: 20),
            _DaySummary(date: _selectedDate, repository: widget.repository),
          ],
        ),
      ),
    );
  }

  void _changeMonth(int offset) {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + offset,
      );
      _selectedDate = _visibleMonth;
    });
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.month,
    required this.selectedDate,
    required this.repository,
    required this.onSelected,
  });

  final DateTime month;
  final DateTime selectedDate;
  final WorkoutProgressRepository repository;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month);
    final gridStart = firstDay.subtract(Duration(days: firstDay.weekday - 1));
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        final date = gridStart.add(Duration(days: index));
        final isCurrentMonth = date.month == month.month;
        final selected = workoutDateKey(date) == workoutDateKey(selectedDate);
        final status = _statusFor(date, repository);
        final color = switch (status) {
          WorkoutProgressStatus.completed => Colors.green,
          WorkoutProgressStatus.inProgress => Colors.orange,
          WorkoutProgressStatus.notStarted => null,
        };
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => onSelected(date),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color?.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
              border: selected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : null,
            ),
            child: Text(
              '${date.day}',
              style: TextStyle(
                color: isCurrentMonth ? color : Theme.of(context).disabledColor,
                fontWeight: color == null ? FontWeight.w500 : FontWeight.w900,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DaySummary extends StatelessWidget {
  const _DaySummary({required this.date, required this.repository});

  final DateTime date;
  final WorkoutProgressRepository repository;

  @override
  Widget build(BuildContext context) {
    final workout = workoutForDate(date);
    final progress = repository.progressForDate(date);
    final completed = progress
        .where((item) => item.status == WorkoutProgressStatus.completed)
        .length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Icon(Icons.event_available, size: 34),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${date.month}月${date.day}日・${workout.label}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    workout.items.isEmpty
                        ? '休養日'
                        : '$completed / ${workout.items.length} 種目完了',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}

WorkoutProgressStatus _statusFor(
  DateTime date,
  WorkoutProgressRepository repository,
) {
  final itemCount = workoutForDate(date).items.length;
  final progress = repository.progressForDate(date);
  if (itemCount > 0 &&
      progress
              .where((item) => item.status == WorkoutProgressStatus.completed)
              .length >=
          itemCount) {
    return WorkoutProgressStatus.completed;
  }
  if (progress.any((item) => item.hasStarted)) {
    return WorkoutProgressStatus.inProgress;
  }
  return WorkoutProgressStatus.notStarted;
}
