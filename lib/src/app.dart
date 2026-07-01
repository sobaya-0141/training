import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kintore/src/features/navigation/app_router.dart';
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
  GoRouter? _router;

  @override
  void dispose() {
    _router?.dispose();
    _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Kintore',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Kintore',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            home: const Scaffold(
              body: Center(child: Text('データベースを開けませんでした')),
            ),
          );
        }
        final router = _router ?? createAppRouter(_repository);
        _router = router;
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Kintore',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          routerConfig: router,
        );
      },
    );
  }
}
