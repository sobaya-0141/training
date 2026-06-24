enum WorkoutProgressStatus { notStarted, inProgress, completed }

class WorkoutProgress {
  const WorkoutProgress({
    required this.dateKey,
    required this.itemIndex,
    required this.status,
    this.reps = 0,
    this.completedSets = 0,
    this.timerPhase,
    this.remainingSeconds = 0,
    this.roundIndex = 0,
  });

  final String dateKey;
  final int itemIndex;
  final WorkoutProgressStatus status;
  final int reps;
  final int completedSets;
  final String? timerPhase;
  final int remainingSeconds;
  final int roundIndex;

  bool get hasStarted => status != WorkoutProgressStatus.notStarted;
}

String workoutDateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';
