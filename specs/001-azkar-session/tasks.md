# Tasks: Guided Azkar Session (أذكار الصباح والمساء)

**Feature**: `001-azkar-session` | **Plan**: [plan.md](./plan.md) | **Spec**: [spec.md](./spec.md)

Tests for the two NON-NEGOTIABLE behaviors are **required** by the constitution:
PLAY→STOP→LISTEN ordering (Principle II) and one-advance-per-phrase (Principle IV). Other tests are
included where they protect a constitutional guarantee (sacred-text integrity, date-rollover).

**Conventions**: `[P]` = parallelizable (different file, no incomplete deps). Story labels
`[US1]`..`[US5]` map to the spec's user stories. Run `source scripts/env.sh` before any
flutter/dart command.

---

## Phase 1: Setup

- [ ] T001 Scaffold platform folders without clobbering existing files: run `flutter create . --org com.hesn --project-name hesn --platforms android,ios` in repo root, then confirm `pubspec.yaml` still lists the locked deps and `lib/` is intact.
- [ ] T002 Reconcile `pubspec.yaml`: ensure `flutter_tts`, `record`, `flutter_local_notifications`, `timezone`, `shared_preferences`, `permission_handler`, `intl`, `flutter_localizations` are present; add the `assets/azkar.json` and `assets/fonts/` entries and the Naskh font (`Amiri`) declaration; run `flutter pub get`.
- [ ] T003 [P] Add a bundled Naskh Arabic font with tashkīl support to `assets/fonts/` (e.g. Amiri) and declare it in `pubspec.yaml`.
- [ ] T004 [P] Configure `analysis_options.yaml` with `flutter_lints`; verify `flutter analyze` runs clean on the empty scaffold.
- [ ] T005 [P] Android manifest prerequisites in `android/app/src/main/AndroidManifest.xml`: `RECORD_AUDIO` permission, `RECEIVE_BOOT_COMPLETED` permission + boot receiver for `flutter_local_notifications`, and `minSdkVersion 26` in `android/app/build.gradle`.
- [ ] T006 [P] iOS permission strings in `ios/Runner/Info.plist`: `NSMicrophoneUsageDescription` (Arabic + English) explaining mic is used only to detect recitation completion.

**Checkpoint**: `flutter analyze` clean; app scaffold builds (`flutter build apk --debug`).

---

## Phase 2: Foundational (blocking prerequisites for all stories)

- [ ] T007 [P] Create `AzkarType` and `SessionPhase` enums in `lib/session/session_phase.dart` and `lib/models/azkar.dart` per data-model.md.
- [ ] T008 [P] Implement `AzkarItem` and `AzkarList` models in `lib/models/azkar.dart` (immutable, `fromJson`, validation: `repeat>=1`, `quran ⇒ ref`).
- [ ] T009 [P] Implement `AppSettings` model in `lib/models/app_settings.dart` (`fromJson`/`toJson`, defaults from data-model.md).
- [ ] T010 [P] Implement `DailyProgress` model in `lib/models/daily_progress.dart` with the date-rollover rule (stale `dateKey` ⇒ fresh record).
- [ ] T011 [US-data] Create `assets/azkar.json` from the stakeholder-provided Hisn al-Muslim text — morning + evening, fully voweled, **verbatim**, with `type:"quran"` + `ref` on Ayat al-Kursi (2:255) and al-Ikhlas/al-Falaq/al-Nas; repeat counts exactly as given.
- [ ] T012 Validate `assets/azkar.json` against `specs/001-azkar-session/contracts/azkar.schema.json` (schema-check script or test); fix structural issues only — never edit the sacred text to satisfy the schema.
- [ ] T013 [P] Define service interfaces in `lib/services/` per contracts/services.md: `TtsService`, `VadService`, `StorageService`, `NotificationService`, `PermissionService` (abstract classes only).
- [ ] T014 [P] Implement `AzkarRepository` in `lib/data/azkar_repository.dart` to load+parse `assets/azkar.json` read-only.
- [ ] T015 [P] [TEST] `test/data/azkar_repository_test.dart`: asset parses; every `quran` item has a `ref`; loading does not trim/normalize text (byte-stable round-trip).
- [ ] T016 [P] [TEST] `test/models/daily_progress_test.dart`: date-rollover resets both flags; same-day load preserves flags.
- [ ] T017 [P] Arabic RTL theme + app shell: `lib/theme/app_theme.dart` and `lib/app.dart` (`MaterialApp`, `locale: ar`, `supportedLocales`, `localizationsDelegates`, `Directionality.rtl`, Naskh font) and `lib/main.dart` entry.
- [ ] T018 Build fakes for tests in `test/fakes/`: `FakeTtsService` (controllable "is speaking"/completion), `FakeVadService` (scriptable amplitude stream), in-memory `FakeStorageService`.

**Checkpoint**: models + data load + theme exist; foundational tests green. No story UI yet.

---

## Phase 3: User Story 1 — Complete a session by voice (P1) 🎯 MVP

**Goal**: Hands-free phrase-by-phrase progression via PLAY→STOP→LISTEN.
**Independent test**: With fakes, drive speech-then-silence and confirm single-step advance and list-complete; on device, recite a list hands-free.

- [ ] T019 [P] [US1] [TEST] `test/session/session_controller_test.dart`: **INV-1/INV-2** mic never starts while TTS speaking; `listening` only after `stopping` resolved. **INV-3** voice-complete advances index by exactly 1. **INV-4** list-complete fires once.
- [ ] T020 [P] [US1] [TEST] `test/session/vad_detector_test.dart`: min-speech rejects a short blip (cough); silence-window after speech triggers complete; safety-timeout flag set after 8–10 s of no speech.
- [ ] T021 [US1] Implement `VadDetector` in `lib/session/vad_detector.dart`: consume 0..1 amplitude samples, apply sensitivity threshold, min-speech accumulation, silence-window, safety-timeout. (makes T020 pass)
- [ ] T022 [US1] Implement `SessionController` in `lib/session/session_controller.dart`: the state machine + `start/advance/skip/pause/dispose`, hand-rolled listeners, `onListComplete`. Depends on `TtsService`/`VadService` interfaces only. (makes T019 pass)
- [ ] T023 [US1] Implement `TtsService` concrete (`flutter_tts`) in `lib/services/tts_service.dart`: `awaitSpeakCompletion(true)`, ar language; `speak` resolves on completion; `stop` fully stops.
- [ ] T024 [US1] Implement `VadService` concrete (`record`, amplitude mode) in `lib/services/vad_service.dart`: amplitude stream normalized to 0..1, no file/no STT, `stop` releases mic.
- [ ] T025 [US1] Build `SessionScreen` (`lib/screens/session_screen.dart`) voice path: render phrase via `azkar_text_view.dart`, repeat counter, drive controller, `setState` on controller changes; auto-advance on voice-complete.
- [ ] T026 [P] [US1] Widgets `lib/widgets/azkar_text_view.dart` (large scrollable voweled RTL text) and `lib/widgets/repeat_counter.dart`.

**Checkpoint**: A list can be completed by voice; the two invariant tests pass. This is the MVP.

---

## Phase 4: User Story 2 — Manual Done/Skip + safety timeout (P1)

**Goal**: Always-available manual control; works with voice off.
**Independent test**: Disable voice; finish a list with تم/تجاوز only.

- [ ] T027 [P] [US2] [TEST] `test/widget/session_screen_test.dart`: تم and تجاوز always present and each advances once; with voice disabled the session runs manual-only; after safety-timeout the Done button is emphasized.
- [ ] T028 [US2] Add `DoneButton`/`SkipButton` to `SessionScreen` wired to `controller.advance()` / `controller.skip()` (single step), always visible.
- [ ] T029 [US2] Honor `voiceDetectionEnabled=false`: `SessionController` skips the listening phase (PLAY→STOP→[manual]) and never starts VAD.
- [ ] T030 [US2] Surface the safety-timeout in `SessionScreen`: when `safetyTimeoutElapsed`, visually emphasize Done.

**Checkpoint**: Full list completable with zero voice; timeout UX verified.

---

## Phase 5: User Story 3 — Today's progress & resume (P2)

**Goal**: Home shows per-list completion; resets on date change.
**Independent test**: Complete morning, see it marked; simulate date change → both reset.

- [ ] T031 [US3] Implement `StorageService` concrete (`shared_preferences`) in `lib/services/storage_service.dart`: load/save settings, `loadProgress(todayKey)` with rollover reset, `markListComplete`.
- [ ] T032 [US3] On `onListComplete`, persist completion via `StorageService.markListComplete` for the active list.
- [ ] T033 [US3] Build `HomeScreen` (`lib/screens/home_screen.dart`): two cards (صباح/مساء) with `progress_badge.dart` status, start buttons, settings entry; reads today's progress.
- [ ] T034 [P] [US3] Widget `lib/widgets/progress_badge.dart` (completed / not-completed status, RTL).

**Checkpoint**: Progress visible and resets across days.

---

## Phase 6: User Story 4 — Daily reminders (P2)

**Goal**: Two daily local notifications; survive reboot.
**Independent test**: Set a near-future time → notification fires; reboot → still fires.

- [ ] T035 [US4] Implement `NotificationService` concrete in `lib/services/notification_service.dart`: tz `init`, `zonedSchedule` daily morning+evening, `cancelAll`, idempotent `rescheduleFromSettings`.
- [ ] T036 [US4] Call `NotificationService.init()` + `rescheduleFromSettings(settings)` on app launch in `lib/main.dart` (reconcile-on-launch backstop for reboot).
- [ ] T037 [US4] Verify Android boot receiver (from T005) re-registers reminders; document the OEM battery-optimization caveat in code comment + quickstart.

**Checkpoint**: Reminders fire daily and after reboot.

---

## Phase 7: User Story 5 — Settings & mic permission (P3)

**Goal**: Configure reminders, voice on/off, sensitivity; mic rationale.
**Independent test**: Change each setting, restart, confirm retained and effective.

- [ ] T038 [US5] Implement `PermissionService` concrete (`permission_handler`) in `lib/services/permission_service.dart`.
- [ ] T039 [US5] Arabic mic-rationale dialog shown before first permission request; on denial, session falls back to manual-only (never blocks). Wire into session entry.
- [ ] T040 [US5] Build `SettingsScreen` (`lib/screens/settings_screen.dart`): morning/evening time pickers, voice-detection switch, sensitivity slider; persist via `StorageService`; on save call `NotificationService.rescheduleFromSettings`.

**Checkpoint**: Settings persist and take effect; permission flow respects Principle VII.

---

## Phase 8: Polish & Cross-Cutting

- [ ] T041 [P] Lifecycle safety: `WidgetsBindingObserver` stops TTS + VAD on background/pause/exit (Principle III/INV-5).
- [ ] T042 [P] Add the privacy notice (Arabic) text from plan/spec to the app (Settings/about), matching the stated wording.
- [ ] T043 [P] Tune timing defaults (silence window, min-speech, sensitivity mapping) on a real Android device; record final values in `contracts/session-engine.md`.
- [ ] T044 Final gates: `flutter analyze` clean and `flutter test` green; build a debug APK.
- [ ] T045 Pre-release: have a competent Arabic speaker review `assets/azkar.json` against the source (constitution Principle I) and record sign-off.

---

## Dependencies & Execution Order

- **Setup (P1)** → **Foundational (P2)** block everything.
- **US1 (Phase 3)** is the MVP and depends only on Foundational. **US2** depends on US1 (same screen/controller).
- **US3, US4, US5** depend on Foundational; US3/US4 are independent of each other; US5's settings feed US4's reschedule.
- **Polish (Phase 8)** last.

Story completion order: US1 → US2 → US3 → US4 → US5.

## Parallel Opportunities

- Setup: T003, T004, T005, T006 in parallel.
- Foundational: T007–T010, T013–T017 are mostly `[P]` (distinct files); T011→T012 sequential; T018 after interfaces (T013).
- US1: T019, T020, T026 `[P]`; T021→T022 then T023/T024, then T025.
- Across stories after Foundational: US3 widgets (T034) and US4 (T035) can proceed in parallel with US1/US2 if staffed.

## Independent Test Criteria (per story)

- **US1**: speech-then-silence advances one phrase; mic never opens during playback; list completes.
- **US2**: voice off → finish via تم/تجاوز; timeout emphasizes Done.
- **US3**: completion shown on Home; resets on date change.
- **US4**: reminder fires at set time and after reboot.
- **US5**: settings persist across restart and change behavior.

## Suggested MVP

**Phase 1 + Phase 2 + Phase 3 (US1)** — a user can complete a morning/evening list hands-free with
the PLAY→STOP→LISTEN guarantee. Add US2 immediately after (co-P1) for the manual fallback the
constitution requires before any real-world use.
