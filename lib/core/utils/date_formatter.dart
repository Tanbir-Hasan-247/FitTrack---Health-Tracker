import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _displayDateFormat = DateFormat('MMM d, yyyy');
  static final DateFormat _shortDateFormat = DateFormat('EEE, d MMM');
  static final DateFormat _dayOfWeekFormat = DateFormat('EEE');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _chartDateFormat = DateFormat('MM/dd');

  /// Returns today's date in 'yyyy-MM-dd' format for database keys
  static String todayKey() {
    return _dateFormat.format(DateTime.now());
  }

  /// Formats DateTime to 'yyyy-MM-dd'
  static String toDbDate(DateTime date) {
    return _dateFormat.format(date);
  }

  static String formatDate(DateTime date) => toDbDate(date);

  static String formatShortDay(DateTime date) => _dayOfWeekFormat.format(date);

  /// Parses 'yyyy-MM-dd' into DateTime
  static DateTime fromDbDate(String dateStr) {
    try {
      return _dateFormat.parse(dateStr);
    } catch (_) {
      return DateTime.now();
    }
  }

  /// Formats for human display, e.g., 'Oct 31, 2026'
  static String toDisplayDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Today';
    try {
      final dt = _dateFormat.parse(dateStr);
      final today = DateTime.now();
      if (dt.year == today.year &&
          dt.month == today.month &&
          dt.day == today.day) {
        return 'Today';
      }
      final yesterday = today.subtract(const Duration(days: 1));
      if (dt.year == yesterday.year &&
          dt.month == yesterday.month &&
          dt.day == yesterday.day) {
        return 'Yesterday';
      }
      return _displayDateFormat.format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  /// Formats short date e.g. 'Sat, 31 Oct'
  static String toShortDate(DateTime date) {
    return _shortDateFormat.format(date);
  }

  /// Formats time e.g. '05:30 PM'
  static String toDisplayTime(DateTime date) {
    return _timeFormat.format(date);
  }

  /// Formats chart date label
  static String toChartDate(DateTime date) {
    return _chartDateFormat.format(date);
  }

  /// Formats seconds into MM:SS or HH:MM:SS
  static String formatSeconds(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
