# Implementation Plan: Guided Azkar Session (أذكار الصباح والمساء)

**Branch**: `main` | **Date**: 2026-06-01 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-azkar-session/spec.md`

## Summary

Hesn is an offline, Arabic, RTL Flutter app that guides a user through the morning or evening
azkar phrase by phrase. The core is a session engine implementing a strict **PLAY → STOP → LISTEN**
state machine: it speaks each phrase via TTS, fully stops playback, then opens the microphone and
watches audio amplitude (VAD — no speech-to-text) to detect "spoke then fell silent," advancing one
phrase. Manual "تم"/"تجاوز" buttons and an 8–10s safety timeout guarantee a non-voice path. Azkar
content is loaded verbatim from a bundled `assets/azkar.json`. Daily completion and settings persist
locally via `shared_preferences` with automatic date-rollover reset, and two daily local
notifications are scheduled and re-established after reboot. No backend, network, login, or
state-management library; plain `setState`.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.44 (stable)

**Primary Dependencies**: `flutter_tts` (audio output), `record` (mic amplitude / VAD),
`flutter_local_notifications` + `timezone` (daily reminders), `shared_preferences` (local
persistence), `permission_handler` (mic permission), `intl` + `flutter_localizations` (Arabic/RTL).

**Storage**: On-device key/value via `shared_preferences` (settings + daily progress). Azkar content
is a read-only bundled asset (`assets/azkar.json`). No database.

**Testing**: `flutter_test` for unit + widget tests. Services that touch platform plugins
(TTS, record, notifications, prefs) are abstracted behind interfaces and faked in tests so the
session state machine is tested deterministically without devices.

**Target Platform**: Android first (minSdk 26 / Android 8), iOS later (iOS 13+). Mobile only.

**Project Type**: Single Flutter mobile app (Option: mobile).

**Performance Goals**: 60 fps UI; phrase transition (stop playback → mic live) under ~300 ms; app
cold start under ~2 s on mid-range Android.

**Constraints**: Fully offline (no network code paths); mic open only during a session; PLAY and
LISTEN never overlap; azkar text/counts byte-identical to source.

**Scale/Scope**: 2 azkar lists (~25 items each), 3 screens (Home, Session, Settings), 1 session
engine, 4 service abstractions. Single user, single device, no accounts.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| # | Principle | How this plan complies |
|---|-----------|------------------------|
| I | Sacred Text Integrity | Text lives in `assets/azkar.json`, loaded read-only; no normalization/transform anywhere. A test asserts the asset parses and that `quran` items carry a `ref` and are never mutated. Repeat counts are data, not logic. |
| II | PLAY → STOP → LISTEN | Modeled as an explicit `SessionPhase` enum (`playing → stopping → listening → advancing`). The engine cannot enter `listening` without a completed `stop`. A unit test fails if a mic-start is requested while phase is `playing`. |
| III | Privacy by Design | No `http`/network dependency in `pubspec`. `record` is used in amplitude-stream mode (no file written). No `speech_to_text`. Mic started on session entry, stopped on exit/interrupt. |
| IV | One Advance Per Phrase | Engine exposes a single `advance()`; voice-complete, Done, and Skip all call it once. Repeat count is display-only state. Test: a voice-complete event advances index by exactly 1. |
| V | Arabic-First & RTL | `MaterialApp` locale `ar`, `Directionality.rtl`, Arabic strings as literal constants. No i18n indirection that could machine-translate content. |
| VI | Radical Simplicity | Only the locked deps. Plain `setState` in screens; engine is a plain `ChangeNotifier`-free controller exposing callbacks/streams. Forbidden: `speech_to_text`, normalization, similarity, prayer-time calc. |
| VII | Manual Fallback Always Available | `DoneButton`/`SkipButton` always built in `SessionScreen`; safety-timeout timer (8–10s) raises a flag that emphasizes Done. Works with voice disabled. |

**Result**: PASS. No violations; Complexity Tracking not required.

## Project Structure

### Documentation (this feature)

```text
specs/001-azkar-session/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (service interface contracts + azkar JSON schema)
│   ├── session-engine.md
│   ├── services.md
│   └── azkar.schema.json
└── tasks.md             # Phase 2 output (/speckit-tasks — NOT created here)
```

### Source Code (repository root)

```text
lib/
├── main.dart                      # App entry: MaterialApp, ar locale, RTL, theme, routing
├── app.dart                       # Root widget + named routes
├── models/
│   ├── azkar.dart                 # AzkarList, AzkarItem, AzkarType enum
│   ├── daily_progress.dart        # morning/evening completed + date
│   └── app_settings.dart          # reminder times, vad enabled, sensitivity
├── data/
│   └── azkar_repository.dart      # Loads & parses assets/azkar.json (read-only)
├── services/
│   ├── tts_service.dart           # abstract + flutter_tts impl  (speak, stop, awaitCompletion)
│   ├── vad_service.dart           # abstract + record impl  (amplitude stream, start/stop)
│   ├── notification_service.dart  # abstract + flutter_local_notifications impl
│   ├── storage_service.dart       # abstract + shared_preferences impl
│   └── permission_service.dart    # mic permission request/status
├── session/
│   ├── session_phase.dart         # enum: idle, playing, stopping, listening, advancing, done
│   ├── session_controller.dart    # PLAY->STOP->LISTEN state machine (no UI, no plugins direct)
│   └── vad_detector.dart          # speech/silence logic (min-speech, silence-window, timeout)
├── screens/
│   ├── home_screen.dart           # pick morning/evening, today's status, settings entry
│   ├── session_screen.dart        # phrase text + repeat counter + Done/Skip + timeout surfacing
│   └── settings_screen.dart       # reminder times, vad enable/disable, sensitivity
├── widgets/
│   ├── azkar_text_view.dart       # renders voweled Arabic, scrollable, large RTL type
│   ├── repeat_counter.dart
│   └── progress_badge.dart
└── theme/
    └── app_theme.dart             # Arabic font, colors, RTL-aware styling

assets/
└── azkar.json                     # Hisn al-Muslim morning + evening, verbatim, voweled

test/
├── session/
│   ├── session_controller_test.dart   # PLAY->STOP->LISTEN ordering; one-advance-per-phrase
│   └── vad_detector_test.dart         # min-speech, silence-window, safety-timeout
├── data/
│   └── azkar_repository_test.dart      # asset parses; quran items immutable & have ref
├── models/
│   └── daily_progress_test.dart        # date-rollover reset logic
└── widget/
    └── session_screen_test.dart        # Done/Skip always present; works with VAD disabled

android/  ios/                          # generated by `flutter create .` (platform scaffolding)
```

**Structure Decision**: Single Flutter mobile app. The session engine (`lib/session/`) is pure Dart
with **no direct plugin or widget dependencies** — it talks to TTS/VAD via the injected service
interfaces from `lib/services/`. This keeps the two NON-NEGOTIABLE, test-critical behaviors
(Principle II ordering, Principle IV single-advance) unit-testable with fakes, no device required.

## Complexity Tracking

> Not applicable — Constitution Check passed with no violations.
