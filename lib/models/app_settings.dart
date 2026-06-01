import 'package:flutter/foundation.dart';

/// User preferences, persisted locally. Defaults make the app usable without
/// ever opening settings.
@immutable
class AppSettings {
  const AppSettings({
    this.morningReminderTime = '06:30',
    this.eveningReminderTime = '16:30',
    this.voiceDetectionEnabled = true,
    this.sensitivity = 0.5,
  });

  /// `HH:mm`, 24h local time.
  final String morningReminderTime;
  final String eveningReminderTime;

  /// When false, sessions run manual-only (mic never opened).
  final bool voiceDetectionEnabled;

  /// 0..1; higher = more sensitive (lower amplitude threshold).
  final double sensitivity;

  AppSettings copyWith({
    String? morningReminderTime,
    String? eveningReminderTime,
    bool? voiceDetectionEnabled,
    double? sensitivity,
  }) {
    return AppSettings(
      morningReminderTime: morningReminderTime ?? this.morningReminderTime,
      eveningReminderTime: eveningReminderTime ?? this.eveningReminderTime,
      voiceDetectionEnabled:
          voiceDetectionEnabled ?? this.voiceDetectionEnabled,
      sensitivity: sensitivity ?? this.sensitivity,
    );
  }

  Map<String, dynamic> toJson() => {
        'morningReminderTime': morningReminderTime,
        'eveningReminderTime': eveningReminderTime,
        'voiceDetectionEnabled': voiceDetectionEnabled,
        'sensitivity': sensitivity,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      morningReminderTime:
          json['morningReminderTime'] as String? ?? '06:30',
      eveningReminderTime:
          json['eveningReminderTime'] as String? ?? '16:30',
      voiceDetectionEnabled:
          json['voiceDetectionEnabled'] as bool? ?? true,
      sensitivity: (json['sensitivity'] as num?)?.toDouble() ?? 0.5,
    );
  }

  /// Parses an `HH:mm` string into (hour, minute).
  static (int hour, int minute) parseTime(String hhmm) {
    final parts = hhmm.split(':');
    return (int.parse(parts[0]), int.parse(parts[1]));
  }
}
