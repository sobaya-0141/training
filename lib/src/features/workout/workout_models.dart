enum WorkoutKind { counter, interval, circuit }

class WorkoutItem {
  const WorkoutItem.counter({
    required this.name,
    required this.summary,
    required this.reps,
    required this.sets,
    this.sides = 1,
    this.countStep = 1,
  }) : kind = WorkoutKind.counter,
       workSeconds = 0,
       restSeconds = 0,
       rounds = 0,
       circuitExercises = const [];

  const WorkoutItem.interval({
    required this.name,
    required this.summary,
    required this.workSeconds,
    required this.restSeconds,
    required this.rounds,
  }) : kind = WorkoutKind.interval,
       reps = 0,
       sets = 0,
       sides = 1,
       countStep = 1,
       circuitExercises = const [];

  const WorkoutItem.circuit({
    required this.name,
    required this.summary,
    required this.workSeconds,
    required this.restSeconds,
    required this.rounds,
    required this.circuitExercises,
  }) : kind = WorkoutKind.circuit,
       reps = 0,
       sets = 0,
       sides = 1,
       countStep = 1;

  final String name;
  final String summary;
  final WorkoutKind kind;
  final int reps;
  final int sets;
  final int sides;
  final int countStep;
  final int workSeconds;
  final int restSeconds;
  final int rounds;
  final List<String> circuitExercises;

  int get totalSets => sets * sides;
}

class DailyWorkout {
  const DailyWorkout({
    required this.weekday,
    required this.label,
    required this.subtitle,
    required this.items,
  });

  final int weekday;
  final String label;
  final String subtitle;
  final List<WorkoutItem> items;
}
