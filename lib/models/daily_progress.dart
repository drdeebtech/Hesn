import 'package:flutter/foundation.dart';

/// Per-day completion state. The [dateKey] is the local `yyyy-MM-dd` the flags
/// belong to; when the day changes the flags are considered reset
/// (Constitution-aligned date-rollover, FR-012).
@immutable
class DailyProgress {
  const DailyProgress({
    required this.dateKey,
    this.morningCompleted = false,
    this.eveningCompleted = false,
  });

  final String dateKey;
  final bool morningCompleted;
  final bool eveningCompleted;

  /// Returns this record if it belongs to [todayKey]; otherwise a fresh record
  /// for today with both flags reset.
  DailyProgress forToday(String todayKey) {
    if (dateKey == todayKey) return this;
    return DailyProgress(dateKey: todayKey);
  }

  bool isCompleted(String listId) =>
      listId == 'morning' ? morningCompleted : eveningCompleted;

  DailyProgress markCompleted(String listId) {
    return DailyProgress(
      dateKey: dateKey,
      morningCompleted: listId == 'morning' ? true : morningCompleted,
      eveningCompleted: listId == 'evening' ? true : eveningCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey,
        'morningCompleted': morningCompleted,
        'eveningCompleted': eveningCompleted,
      };

  factory DailyProgress.fromJson(Map<String, dynamic> json) {
    return DailyProgress(
      dateKey: json['dateKey'] as String,
      morningCompleted: json['morningCompleted'] as bool? ?? false,
      eveningCompleted: json['eveningCompleted'] as bool? ?? false,
    );
  }

  /// Local date key for a [DateTime] as `yyyy-MM-dd`.
  static String dateKeyFor(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
