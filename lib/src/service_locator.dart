import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:kintore/src/features/navigation/app_router.dart';
import 'package:kintore/src/features/progress/workout_progress_cubit.dart';
import 'package:kintore/src/features/progress/workout_progress_repository.dart';

/// アプリ全体で共有するDIコンテナ。
final getIt = GetIt.instance;

/// 依存関係の登録をここにまとめる(composition root)。
///
/// 非同期の初期化を伴う依存はregisterSingletonAsyncで登録し、
/// 利用側は`getIt.allReady()`の完了を待ってから解決する。
/// 各登録のdisposeコールバックは`getIt.reset()`でまとめて実行される。
void configureDependencies() {
  getIt.registerSingletonAsync<WorkoutProgressRepository>(() async {
    final repository = WorkoutProgressRepository();
    await repository.initialize();
    return repository;
  }, dispose: (repository) => repository.dispose());

  // dependsOnにより、RepositoryのDB初期化が完了してからCubitが生成される。
  getIt.registerSingletonWithDependencies<WorkoutProgressCubit>(
    () => WorkoutProgressCubit(getIt<WorkoutProgressRepository>()),
    dependsOn: [WorkoutProgressRepository],
    dispose: (cubit) => cubit.close(),
  );

  // Routerは最初に参照されたタイミングで生成される。
  getIt.registerLazySingleton<GoRouter>(
    () => createAppRouter(getIt<WorkoutProgressCubit>()),
    dispose: (router) => router.dispose(),
  );
}
