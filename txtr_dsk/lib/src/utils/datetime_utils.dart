import 'package:intl/intl.dart';

final DateFormat msgDateFmt = DateFormat('EEE MMM dd, yyyy');
final DateFormat msgTimeFmt = DateFormat.jm();
final DateFormat msgDayFmt = DateFormat('EEEE');
const Duration yesterdayDuration = Duration(days: 2);
const Duration weekDuration = Duration(days: 7);

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

class DateTimeUtils {
  static String prettyDate(final DateTime msgDateTime) {
    final DateTime now = DateTime.now();
    if (now.isSameDate(msgDateTime)) {
      return 'Today ${msgTimeFmt.format(msgDateTime)}';
    }
    final diff = now.difference(msgDateTime);
    if (diff < yesterdayDuration) {
      return 'Yesterday ${msgTimeFmt.format(msgDateTime)}';
    }
    if (diff < weekDuration) {
      return '${msgDayFmt.format(msgDateTime)} ${msgTimeFmt.format(msgDateTime)}';
    }
    return '${msgDateFmt.format(msgDateTime)} ${msgTimeFmt.format(msgDateTime)}';
  }
}
