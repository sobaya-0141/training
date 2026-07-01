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

DateTime? tryParseWorkoutDate(String dateKey) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(dateKey);
  if (match == null) {
    return null;
  }
  final year = int.tryParse(match.group(1)!);
  final month = int.tryParse(match.group(2)!);
  final day = int.tryParse(match.group(3)!);
  if (year == null || month == null || day == null) {
    return null;
  }
  if (month < 1 || month > 12 || day < 1 || day > 31) {
    return null;
  }
  final date = DateTime(year, month, day);
  if (date.year != year || date.month != month || date.day != day) {
    return null;
  }
  return date;
}
