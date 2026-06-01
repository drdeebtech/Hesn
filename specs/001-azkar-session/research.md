# Phase 0 Research: Guided Azkar Session

All Technical Context items were resolvable from the constitution, `plan.md`, and the locked stack;
there were no open `NEEDS CLARIFICATION` markers. This document records the key technical decisions
and the alternatives weighed.

## 1. TTS playback with a reliable "finished" signal (Principle II)

- **Decision**: Use `flutter_tts` with `awaitSpeakCompletion(true)` and an explicit completion
  handler. The session engine treats playback as finished only when the completion event fires (or
  an error/stop occurs), then transitions `playing → stopping → listening`.
- **Rationale**: Principle II requires that the mic never opens during playback. Awaiting completion
  (rather than estimating by text length) gives a deterministic boundary. A short fixed guard delay
  (~250 ms) after `stop()` covers audio-route teardown before the mic opens.
- **Alternatives considered**: Duration estimation from text length (rejected — drifts across
  voices/rates and risks overlap); playing then immediately listening without awaiting (rejected —
  directly violates Principle II).

## 2. Voice Activity Detection without speech-to-text (Principles III, VI)

- **Decision**: Use `record`'s amplitude stream (`onAmplitudeChanged` / periodic `getAmplitude`) at
  ~100–200 ms intervals. Convert dBFS amplitude to a 0..1 level; a level above a sensitivity-derived
  threshold counts as "speech." Detector logic: require a per-phrase **minimum cumulative speech
  duration**, then once speaking has occurred, a **silence window** of 1.5–2 s of sub-threshold
  level triggers advance.
- **Rationale**: Satisfies "detect that the user spoke and finished" with amplitude only — no
  recording to disk, no transcription, nothing leaves the device. `record` can stream amplitude
  without writing a file.
- **Alternatives considered**: `speech_to_text` (forbidden by Principle VI; also sends audio to OS/
  cloud recognizers on some platforms — violates Principle III); writing a WAV and analyzing
  (violates "no recording"); raw PCM stream + custom DSP (unnecessary complexity vs. amplitude).
- **Threshold/sensitivity mapping**: sensitivity setting 0..1 maps to a dBFS threshold (e.g.
  -45 dBFS at high sensitivity → -25 dBFS at low sensitivity). Tuned on real devices; defaults
  chosen mid-range. Minimum speech duration scales roughly with phrase length.

## 3. Microphone permission & privacy posture (Principles III, FR-020..022)

- **Decision**: Request mic permission via `permission_handler` at first session start, preceded by
  an in-app Arabic rationale screen/dialog. If denied, the session runs in manual-only mode
  (Done/Skip), never blocking. Mic is started on entering the listening phase and stopped on
  advance, session exit, pause, or app backgrounding (`WidgetsBindingObserver`).
- **Rationale**: Aligns with the privacy guarantee and the manual-fallback principle. The rationale
  string is also required for store submission (Android `RECORD_AUDIO`, iOS
  `NSMicrophoneUsageDescription`).
- **Alternatives considered**: Requesting at app launch (worse UX, no context); hard-gating the
  session on permission (violates Principle VII).

## 4. Daily local notifications surviving reboot (FR-014..016)

- **Decision**: `flutter_local_notifications` with `zonedSchedule` + `timezone`, using
  `DateTimeComponents.time` for daily repetition at the chosen morning/evening times. On Android,
  declare `RECEIVE_BOOT_COMPLETED` and use the plugin's boot handling so reminders re-register after
  reboot; on app launch also reconcile scheduled notifications against saved settings (idempotent
  reschedule).
- **Rationale**: `zonedSchedule` with a daily time component is the supported path for repeating
  local notifications; reconcile-on-launch is a robust backstop against OS clearing alarms.
- **Caveat (documented, not solvable in-app)**: Aggressive OEM battery optimization / Doze can delay
  or drop exact alarms. We schedule inexact-friendly daily reminders and document the limitation
  (matches spec Assumption). Exact-alarm permission is avoided to keep store review simple.
- **Alternatives considered**: `android_alarm_manager_plus` (extra dependency, against Principle VI);
  push/FCM (requires network + backend — forbidden).

## 5. Local persistence & date-rollover reset (FR-011..012, FR-019)

- **Decision**: `shared_preferences` holds a small JSON blob for settings and a daily-progress
  record `{morningCompleted, eveningCompleted, dateKey}` where `dateKey` is local `yyyy-MM-dd`. On
  every read, if stored `dateKey != today`, both completion flags are treated as `false` and the
  record is rewritten with today's key.
- **Rationale**: Smallest possible footprint; no DB needed for two booleans + a few settings.
  Reset-on-read avoids needing a midnight timer/background job.
- **Alternatives considered**: `sqflite`/Hive (overkill, against Principle VI); a midnight scheduler
  (unnecessary — lazy reset on read is simpler and correct).

## 6. Arabic / RTL rendering of voweled text (Principle V, FR-023)

- **Decision**: `MaterialApp` with `locale: Locale('ar')`, `localizationsDelegates`, and
  `supportedLocales: [Locale('ar')]`; wrap in `Directionality(textDirection: TextDirection.rtl)`.
  Bundle an Arabic font with strong tashkīl/diacritic support (e.g. a Naskh font such as Amiri or
  Scheherazade) to render fully-voweled text correctly and legibly at large sizes.
- **Rationale**: Default system fonts may misplace or clip diacritics; an explicit Naskh Quran-grade
  font ensures correct tashkīl rendering for both dhikr and Qur'an items.
- **Alternatives considered**: Relying on platform default Arabic font (inconsistent diacritic
  rendering across devices); `google_fonts` runtime fetch (needs network — forbidden; bundle the
  font file instead).

## 7. Session engine architecture & testability (Principles II, IV)

- **Decision**: A plain-Dart `SessionController` holds the `SessionPhase` state machine and the
  current list/index/repeat display. It depends only on the abstract `TtsService` and `VadService`
  interfaces (constructor-injected), exposing a listenable state and an `advance()` method. Screens
  use `setState` driven by the controller's change callbacks.
- **Rationale**: Keeps the two NON-NEGOTIABLE behaviors in pure Dart so they are unit-tested with
  fakes (no emulator). Honors Principle VI (no state-management library) — the controller is a small
  hand-rolled observable.
- **Alternatives considered**: Provider/Riverpod/Bloc (forbidden by Principle VI); putting the state
  machine inside the widget (untestable without a device).
