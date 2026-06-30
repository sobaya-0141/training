import 'package:kintore/src/features/progress/workout_progress.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const calendar = '/calendar';

  static String simpleTimer(int seconds, {required String title}) {
    return '/timer/simple/$seconds?title=${Uri.encodeQueryComponent(title)}';
  }

  static String workout(DateTime date, int index) {
    return '/workout/${workoutDateKey(date)}/$index';
  }
}

DateTime parseWorkoutDate(String dateKey) {
  final parts = dateKey.split('-');
  return DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}
