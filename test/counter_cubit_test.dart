import 'package:flutter_test/flutter_test.dart';
import 'package:kintore/src/features/counter/counter_cubit.dart';

void main() {
  group('CounterCubit', () {
    test('完了したセット数だけを増やす', () {
      final cubit = CounterCubit(repsPerSet: 15, totalSets: 3, step: 1);

      cubit.incrementSet();
      cubit.incrementSet();

      expect(cubit.state.reps, 0);
      expect(cubit.state.completedSets, 2);
      cubit.close();
    });

    test('セット数は上限を超えず、取り消せる', () {
      final cubit = CounterCubit(repsPerSet: 15, totalSets: 2, step: 1);

      cubit.incrementSet();
      cubit.incrementSet();
      cubit.incrementSet();
      cubit.decrementSet();

      expect(cubit.state.completedSets, 1);
      cubit.close();
    });
  });
}
