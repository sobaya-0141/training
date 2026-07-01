import 'package:flutter_test/flutter_test.dart';
import 'package:kintore/src/features/navigation/app_routes.dart';

void main() {
  group('tryParseWorkoutDate', () {
    test('有効な日付キーをパースする', () {
      expect(
        tryParseWorkoutDate('2026-06-16'),
        DateTime(2026, 6, 16),
      );
    });

    test('不正な日付キーは null を返す', () {
      expect(tryParseWorkoutDate('invalid'), isNull);
      expect(tryParseWorkoutDate('2026-13-01'), isNull);
      expect(tryParseWorkoutDate('2026-06-1'), isNull);
    });
  });
}
