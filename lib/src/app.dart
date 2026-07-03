import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kintore/src/features/navigation/app_router.dart';
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
  late final Future<void> _initialization;
  WorkoutProgressCubit? _progressCubit;
  GoRouter? _router;

  @override
  void initState() {
    super.initState();
    // buildは何度でも呼ばれうるため、初期化はinitStateから開始し、
    // buildには副作用を持たせない。
    _initialization = _initialize();
  }

  Future<void> _initialize() async {
    await _repository.initialize();
    if (!mounted) {
      // 初期化完了前にdisposeされた場合は何も生成しない。
      // 開いたDBの後始末はRepository側(dispose済みフラグ)が行う。
      return;
    }
    // ここから先は同期処理なので、途中でdisposeが割り込むことはない。
    final progressCubit = WorkoutProgressCubit(_repository);
    try {
      final router = createAppRouter(progressCubit);
      // フィールドへの代入は全体が成功してからまとめて行う。
      _progressCubit = progressCubit;
      _router = router;
    } catch (_) {
      // Router生成に失敗した場合、Cubitはどこからも参照されないまま
      // 残ってしまうため、ここで確実にcloseする。
      await progressCubit.close();
      rethrow;
    }
  }

  @override
  void dispose() {
    _router?.dispose();
    _progressCubit?.close();
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
            home: const Scaffold(body: Center(child: Text('アプリを起動できませんでした'))),
          );
        }
        return BlocProvider.value(
          value: _progressCubit!,
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Kintore',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            routerConfig: _router!,
          ),
        );
      },
    );
  }
}
