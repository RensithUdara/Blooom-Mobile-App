import 'package:intl/intl.dart';

class BloomDateUtils {
  const BloomDateUtils._();

  static final _dayMonth = DateFormat('d MMM');
  static final _full = DateFormat('d MMMM, y');
  static final _monthYear = DateFormat('MMMM y');

  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static String dayMonth(DateTime value) => _dayMonth.format(value);

  static String full(DateTime value) => _full.format(value);

  static String monthYear(DateTime value) => _monthYear.format(value);

  static int inclusiveDays(DateTime start, DateTime end) {
    return dateOnly(end).difference(dateOnly(start)).inDays + 1;
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isBetween(DateTime day, DateTime start, DateTime end) {
    final cleanDay = dateOnly(day);
    return !cleanDay.isBefore(dateOnly(start)) &&
        !cleanDay.isAfter(dateOnly(end));
  }
}
