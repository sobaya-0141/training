import 'package:flutter/material.dart';
import 'package:kintore/src/features/navigation/main_shell.dart';
import 'package:kintore/src/features/progress/workout_progress_repository.dart';
import 'package:kintore/src/screen_wake_lock.dart';
import 'package:kintore/src/theme/app_theme.dart';

class KintoreApp extends StatefulWidget {
  const KintoreApp({super.key});

  @override
  State<KintoreApp> createState() => _KintoreAppState();
}

class _KintoreAppState extends State<KintoreApp> {
  final _repository = WorkoutProgressRepository();
  late final Future<void> _initialization = _repository.initialize();

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeepScreenOn(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Kintore',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: FutureBuilder<void>(
          future: _initialization,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return const Scaffold(
                body: Center(child: Text('データベースを開けませんでした')),
              );
            }
            return MainShell(repository: _repository);
          },
        ),
      ),
    );
  }
}
