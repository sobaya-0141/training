import 'dart:async';

import 'package:kintore/src/features/progress/workout_progress.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class WorkoutProgressRepository {
  late final Database _database;
  Future<void>? _initialization;
  bool _initialized = false;
  bool _disposed = false;
  final Map<String, WorkoutProgress> _cache = {};

  // 複数回(並行含む)呼ばれても初期化が一度しか走らないよう、
  // 初回のFutureをメモ化して返す(TimerCuePlayerと同じパターン)。
  Future<void> initialize() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    if (_disposed) {
      return;
    }
    final databasePath = await getDatabasesPath();
    final database = await openDatabase(
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
    if (_disposed) {
      // DBを開いている間にdisposeされた場合、開いたDBはここで閉じる。
      await database.close();
      return;
    }
    final rows = await database.query('workout_progress');
    if (_disposed) {
      // キャッシュ読み込み中にdisposeされた場合も同様にここで閉じる。
      // _initializedを立てるのは読み込み完了後なので、dispose()側が
      // 進行中のqueryのDBを閉じてしまうことはない。
      await database.close();
      return;
    }
    _database = database;
    _initialized = true;
    for (final row in rows) {
      final progress = _fromRow(row);
      _cache[_key(progress.dateKey, progress.itemIndex)] = progress;
    }
  }

  Map<String, WorkoutProgress> snapshot() => Map.unmodifiable(_cache);

  Future<void> save(WorkoutProgress progress) async {
    _cache[_key(progress.dateKey, progress.itemIndex)] = progress;
    await _database.insert('workout_progress', {
      'date_key': progress.dateKey,
      'item_index': progress.itemIndex,
      'status': progress.status.name,
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
      completedSets: row['completed_sets']! as int,
      timerPhase: row['timer_phase'] as String?,
      remainingSeconds: row['remaining_seconds']! as int,
      roundIndex: row['round_index']! as int,
    );
  }

  String _key(String dateKey, int itemIndex) => '$dateKey:$itemIndex';

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    if (_initialized) {
      unawaited(_database.close());
    }
  }
}
