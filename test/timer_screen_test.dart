import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kintore/src/features/timer/timer_cubit.dart';
import 'package:kintore/src/features/timer/timer_screen.dart';

void main() {
  testWidgets('開始前はタイマーのプログレスが回らない', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final cubit = TrainingTimerCubit(
      workSeconds: 30,
      restSeconds: 0,
      roundTitles: const ['タイマー'],
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(value: cubit, child: const TimerBody()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final progress = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    expect(progress.value, 0.0);

    expect(
      find.byKey(const ValueKey('start_pause_timer_button')),
      findsOneWidget,
    );
  });

  testWidgets('一時停止中はタイマーのプログレスが回らない', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final cubit = TrainingTimerCubit(
      workSeconds: 30,
      restSeconds: 0,
      roundTitles: const ['タイマー'],
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(value: cubit, child: const TimerBody()),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('start_pause_timer_button')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('start_pause_timer_button')));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final progress = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    expect(progress.value, 0.0);
  });

  testWidgets('サーキットは開始前に全ての種目を表示する', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final cubit = TrainingTimerCubit(
      workSeconds: 20,
      restSeconds: 10,
      roundTitles: const ['種目1 セット 1 / 1', '種目2 セット 1 / 1'],
    );
    addTearDown(() async {
      if (!cubit.isClosed) {
        await cubit.close();
      }
    });

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: const TimerBody(previewExercises: ['種目1', '種目2']),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('exercise_preview_list')), findsOneWidget);
    expect(find.text('1. 種目1'), findsOneWidget);
    expect(find.text('2. 種目2'), findsOneWidget);
  });

  testWidgets('サーキットの種目一覧は開始後に非表示になる', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final cubit = TrainingTimerCubit(
      workSeconds: 20,
      restSeconds: 10,
      roundTitles: const ['種目1 セット 1 / 1', '種目2 セット 1 / 1'],
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: const TimerBody(previewExercises: ['種目1', '種目2']),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('start_pause_timer_button')));
    await tester.pump();

    expect(find.byKey(const ValueKey('exercise_preview_list')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('start_pause_timer_button')));
    await tester.pump();
  });

  testWidgets('休憩中は次の種目名を表示する', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final cubit = TrainingTimerCubit(
      workSeconds: 20,
      restSeconds: 10,
      roundTitles: const ['種目1 セット 1 / 1', '種目2 セット 1 / 1'],
      initialState: const TrainingTimerState(
        phase: TimerPhase.rest,
        remainingSeconds: 10,
        roundIndex: 0,
        totalRounds: 2,
        title: '種目1 セット 1 / 1',
      ),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: const TimerBody(),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('種目2 セット 1 / 1'), findsOneWidget);
    expect(find.text('種目1 セット 1 / 1'), findsNothing);
  });
}
