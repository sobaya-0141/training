import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kintore/src/features/navigation/main_shell.dart';
import 'package:kintore/src/features/progress/workout_progress_cubit.dart';
import 'package:kintore/src/features/progress/workout_progress_repository.dart';
import 'package:kintore/src/theme/app_theme.dart';

class KintoreApp extends StatefulWidget {
  const KintoreApp({super.key});

  @override
  State<KintoreApp> createState() => _KintoreAppState();
}

class _KintoreAppState extends State<KintoreApp> {
  final _repository = WorkoutProgressRepository();
  late final Future<void> _initialization = _repository.initialize();
  WorkoutProgressCubit? _progressCubit;

  @override
  void dispose() {
    _progressCubit?.close();
    _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
            return const Scaffold(body: Center(child: Text('データベースを開けませんでした')));
          }
          _progressCubit ??= WorkoutProgressCubit(_repository);
          return BlocProvider.value(
            value: _progressCubit!,
            child: MainShell(progressCubit: _progressCubit!),
          );
        },
      ),
    );
  }
}
