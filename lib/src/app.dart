import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kintore/src/features/progress/workout_progress_cubit.dart';
import 'package:kintore/src/service_locator.dart';
import 'package:kintore/src/theme/app_theme.dart';

class KintoreApp extends StatefulWidget {
  const KintoreApp({super.key});

  @override
  State<KintoreApp> createState() => _KintoreAppState();
}

class _KintoreAppState extends State<KintoreApp> {
  late final Future<void> _dependenciesReady;

  @override
  void initState() {
    super.initState();
    // buildは何度でも呼ばれうるため、待ち合わせの開始はinitStateで行う。
    _dependenciesReady = getIt.allReady();
  }

  @override
  void dispose() {
    // 登録時のdisposeコールバック(Cubitのclose、RepositoryのDBクローズ、
    // Routerのdispose)をまとめて実行する。
    unawaited(getIt.reset());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _dependenciesReady,
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
          value: getIt<WorkoutProgressCubit>(),
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Kintore',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            routerConfig: getIt<GoRouter>(),
          ),
        );
      },
    );
  }
}
