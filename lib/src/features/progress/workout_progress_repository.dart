import 'package:flutter/foundation.dart';
import 'package:kintore/src/features/progress/workout_progress.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class WorkoutProgressRepository extends ChangeNotifier {
  Database? _database;
  final Map<String, WorkoutProgress> _cache = {};

  Future<void> initialize() async {
    final databasePath = await getDatabasesPath();
    _database = await openDatabase(
      p.join(databasePath, 'kintore.db'),
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE workout_progress (
          date_key TEXT NOT NULL,
          item_index INTEGER NOT NULL,
          status TEXT NOT NULL,
          reps INTEGER NOT NULL DEFAULT 0,
          completed_sets INTEGER NOT NULL DEFAULT 0,
          timer_phase TEXT,
          remaining_seconds INTEGER NOT NULL DEFAULT 0,
          round_index INTEGER NOT NULL DEFAULT 0,
          updated_at TEXT NOT NULL,
          PRIMARY KEY (date_key, item_index)
        )
      '''),
    );
    final rows = await _database!.query('workout_progress');
    for (final row in rows) {
      final progress = _fromRow(row);
      _cache[_key(progress.dateKey, progress.itemIndex)] = progress;
    }
  }

  WorkoutProgress? progressFor(DateTime date, int itemIndex) =>
      _cache[_key(workoutDateKey(date), itemIndex)];

  List<WorkoutProgress> progressForDate(DateTime date) {
    final dateKey = workoutDateKey(date);
    return _cache.values
        .where((progress) => progress.dateKey == dateKey)
        .toList();
  }

  Future<void> save(WorkoutProgress progress) async {
    _cache[_key(progress.dateKey, progress.itemIndex)] = progress;
    notifyListeners();
    await _database!.insert('workout_progress', {
      'date_key': progress.dateKey,
      'item_index': progress.itemIndex,
      'status': progress.status.name,
      'reps': progress.reps,
      'completed_sets': progress.completedSets,
      'timer_phase': progress.timerPhase,
      'remaining_seconds': progress.remainingSeconds,
      'round_index': progress.roundIndex,
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  WorkoutProgress _fromRow(Map<String, Object?> row) {
    return WorkoutProgress(
      dateKey: row['date_key']! as String,
      itemIndex: row['item_index']! as int,
      status: WorkoutProgressStatus.values.byName(row['status']! as String),
      reps: row['reps']! as int,
      completedSets: row['completed_sets']! as int,
      timerPhase: row['timer_phase'] as String?,
      remainingSeconds: row['remaining_seconds']! as int,
      roundIndex: row['round_index']! as int,
    );
  }

  String _key(String dateKey, int itemIndex) => '$dateKey:$itemIndex';

  @override
  void dispose() {
    _database?.close();
    super.dispose();
  }
}
