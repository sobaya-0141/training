import 'package:flutter/material.dart';
import 'package:kintore/src/features/navigation/main_shell.dart';
import 'package:kintore/src/features/progress/workout_progress_repository.dart';

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
    const seed = Color(0xFFE35B32);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kintore',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F4EF),
        useMaterial3: true,
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: FutureBuilder<void>(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return const Scaffold(body: Center(child: Text('データベースを開けませんでした')));
          }
          return MainShell(repository: _repository);
        },
      ),
    );
  }
}
