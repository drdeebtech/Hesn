# Contract: Service Interfaces

All platform/plugin access is behind these abstract interfaces so the session engine and screens are
testable with fakes (no device). Concrete implementations wrap the locked dependencies.

## TtsService  (impl: `flutter_tts`)

```dart
abstract class TtsService {
  Future<void> init();                 // set language ar, rate, awaitSpeakCompletion(true)
  Future<void> speak(String text);     // completes when the utterance FINISHES playing
  Future<void> stop();                 // fully stops playback; completes when stopped
  Future<bool> hasArabicVoice();       // [driving] capability check for text-only fallback (FR-028)
  Future<void> dispose();
}
```
- Contract: `speak()` MUST NOT complete until audio playback has finished (or is stopped). This is
  what lets the engine guarantee Principle II.
- `hasArabicVoice()`: queries available languages (no network); when false the engine skips audio
  (announcements + reading) and the UI shows a one-time notice.

## CueService  (impl: built-in `SystemSound` / `HapticFeedback` — no new dependency)

```dart
abstract class CueService {
  Future<void> transition();           // [driving] short non-spoken cue between phrases
}
```
- Contract: uses only platform built-ins; no asset files, no audio dependency (Principle VI).

## VadService  (impl: `record`, amplitude mode)

```dart
abstract class VadService {
  Future<bool> hasPermission();
  Future<bool> requestPermission();    // via permission_handler
  /// Starts amplitude streaming. Emits a normalized 0..1 level per sample.
  /// MUST NOT write audio to disk. MUST NOT transcribe.
  Stream<double> start({required double sensitivity});
  Future<void> stop();                 // releases the mic
}
```
- Contract: no file I/O, no network, no STT. Mic released on `stop()`.

## StorageService  (impl: `shared_preferences`)

```dart
abstract class StorageService {
  Future<AppSettings> loadSettings();
  Future<void> saveSettings(AppSettings s);
  /// Returns today's progress; resets (false,false,today) if stored dateKey != today.
  Future<DailyProgress> loadProgress(String todayKey);
  Future<void> markListComplete(String listId, String todayKey);
}
```

## NotificationService  (impl: `flutter_local_notifications` + `timezone`)

```dart
abstract class NotificationService {
  Future<void> init({void Function(String listId)? onTapList}); // tz init, channel, tap handler
  Future<void> scheduleDaily(AppSettings s);             // morning + evening, daily repeat
  Future<void> cancelAll();
  Future<void> rescheduleFromSettings(AppSettings s);    // idempotent; called on launch + on reboot
}
```
- Contract: uses `zonedSchedule` with a daily time component; Android declares
  `RECEIVE_BOOT_COMPLETED` so reminders survive reboot; reconciled on app launch.
- [driving] Each scheduled notification carries a `payload` of its `listId`; tapping it invokes
  `onTapList(listId)` so the app routes straight into that session (FR-027) — no on-screen nav.

## PermissionService  (impl: `permission_handler`)

```dart
abstract class PermissionService {
  Future<bool> micGranted();
  Future<bool> requestMic();           // shown after the Arabic rationale
}
```

## Composition / DI

- `main()` builds the concrete services, runs `NotificationService.init()` +
  `rescheduleFromSettings()`, then injects services into screens/controller. Tests inject fakes.
- No service performs any network call. (Verified by the absence of `http`/`dio` in `pubspec.yaml`.)
