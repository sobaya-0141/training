import 'package:flutter_test/flutter_test.dart';
import 'package:kintore/src/features/counter/counter_cubit.dart';

void main() {
  group('CounterCubit', () {
    test('完了したセット数だけを増やす', () {
      final cubit = CounterCubit(totalSets: 3);

      cubit.incrementSet();
      cubit.incrementSet();

      expect(cubit.state.completedSets, 2);
      cubit.close();
    });

    test('セット数は上限を超えず、取り消せる', () {
      final cubit = CounterCubit(totalSets: 2);

      cubit.incrementSet();
      cubit.incrementSet();
      cubit.incrementSet();
      cubit.decrementSet();

      expect(cubit.state.completedSets, 1);
      cubit.close();
    });
  });
}
