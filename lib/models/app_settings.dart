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
    this.handsFreeMode = true,
  });

  /// `HH:mm`, 24h local time.
  final String morningReminderTime;
  final String eveningReminderTime;

  /// When false, sessions run manual-only (mic never opened).
  final bool voiceDetectionEnabled;

  /// 0..1; higher = more sensitive (lower amplitude threshold).
  final double sensitivity;

  /// Hands-free / driving mode (FR-024): spoken count + cues + start-from-
  /// reminder. Invariant (FR-030): implies [voiceDetectionEnabled].
  final bool handsFreeMode;

  /// Rebuilds with the FR-030 invariant enforced: enabling hands-free forces
  /// voice detection on; disabling voice detection forces hands-free off.
  AppSettings copyWith({
    String? morningReminderTime,
    String? eveningReminderTime,
    bool? voiceDetectionEnabled,
    double? sensitivity,
    bool? handsFreeMode,
  }) {
    var voice = voiceDetectionEnabled ?? this.voiceDetectionEnabled;
    var hands = handsFreeMode ?? this.handsFreeMode;
    if (voiceDetectionEnabled == false) hands = false; // explicit voice-off ⇒ HF off
    if (handsFreeMode == true) voice = true; //            explicit HF-on   ⇒ voice on
    if (hands && !voice) voice = true; //                  safety: HF ⇒ voice
    return AppSettings(
      morningReminderTime: morningReminderTime ?? this.morningReminderTime,
      eveningReminderTime: eveningReminderTime ?? this.eveningReminderTime,
      voiceDetectionEnabled: voice,
      sensitivity: sensitivity ?? this.sensitivity,
      handsFreeMode: hands,
    );
  }

  Map<String, dynamic> toJson() => {
        'morningReminderTime': morningReminderTime,
        'eveningReminderTime': eveningReminderTime,
        'voiceDetectionEnabled': voiceDetectionEnabled,
        'sensitivity': sensitivity,
        'handsFreeMode': handsFreeMode,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final voice = json['voiceDetectionEnabled'] as bool? ?? true;
    var hands = json['handsFreeMode'] as bool? ?? true;
    if (!voice) hands = false; // enforce invariant on load
    return AppSettings(
      morningReminderTime: json['morningReminderTime'] as String? ?? '06:30',
      eveningReminderTime: json['eveningReminderTime'] as String? ?? '16:30',
      voiceDetectionEnabled: voice,
      sensitivity: (json['sensitivity'] as num?)?.toDouble() ?? 0.5,
      handsFreeMode: hands,
    );
  }

  /// Parses an `HH:mm` string into (hour, minute).
  static (int hour, int minute) parseTime(String hhmm) {
    final parts = hhmm.split(':');
    return (int.parse(parts[0]), int.parse(parts[1]));
  }
}
