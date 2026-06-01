# Tasks: Guided Azkar Session (أذكار الصباح والمساء)

**Feature**: `001-azkar-session` | **Plan**: [plan.md](./plan.md) | **Spec**: [spec.md](./spec.md)

**Status**: regenerated from design artifacts; completion re-applied.
**Progress**: 45 / 47 complete. Open: **T043** (on-device VAD tuning), **T045** (Arabic-speaker
review) — both require external resources (a physical device / a human reviewer).

Tests for the two NON-NEGOTIABLE behaviors are **required** by the constitution:
PLAY→STOP→LISTEN ordering (Principle II) and one-advance-per-phrase (Principle IV). Other tests are
included where they protect a constitutional guarantee (sacred-text integrity, date-rollover,
no-network).

**Conventions**: `[P]` = parallelizable (different file, no incomplete deps). Story labels
`[US1]`..`[US5]` map to the spec's user stories. Run `source scripts/env.sh` before any
flutter/dart command.

---

## Phase 1: Setup

- [x] T001 Scaffold platform folders: `flutter create . --org com.hesn --project-name hesn --platforms android,ios`; confirm `pubspec.yaml`/`lib/` preserved.
- [x] T002 Reconcile `pubspec.yaml` with locked deps (flutter_tts, record, flutter_local_notifications, timezone, flutter_timezone, shared_preferences, permission_handler, intl, flutter_localizations); declare `assets/azkar.json` + Amiri font; `flutter pub get`.
- [x] T003 [P] Bundle Naskh font with tashkīl support in `assets/fonts/` (Amiri) and declare in `pubspec.yaml`.
- [x] T004 [P] `analysis_options.yaml` with `flutter_lints`; verify `flutter analyze` runs clean.
- [x] T005 [P] Android manifest: `RECORD_AUDIO`, `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, notification boot receiver; `minSdk 26` in `android/app/build.gradle.kts`.
- [x] T006 [P] iOS `Info.plist`: `NSMicrophoneUsageDescription` (Arabic + English) — mic only detects recitation completion.

**Checkpoint**: `flutter analyze` clean; `flutter build apk --debug` succeeds. ✅

---

## Phase 2: Foundational (blocking prerequisites for all stories)

- [x] T007 [P] `AzkarType` + `SessionPhase` enums (`lib/models/azkar.dart`, `lib/session/session_phase.dart`).
- [x] T008 [P] `AzkarItem`/`AzkarList` models with `fromJson` + validation (`repeat>=1`, `quran ⇒ ref`) in `lib/models/azkar.dart`.
- [x] T009 [P] `AppSettings` model (`lib/models/app_settings.dart`).
- [x] T010 [P] `DailyProgress` model with date-rollover rule (`lib/models/daily_progress.dart`).
- [x] T011 Create `assets/azkar.json` from committed source `source/azkar-source.txt` — morning + evening, voweled, **verbatim**, quran items flagged with `ref`, repeat counts exact.
- [x] T012 Validate `assets/azkar.json` against `contracts/azkar.schema.json`; fix structure only, never the sacred text.
- [x] T013 [P] Service interfaces in `lib/services/` (TtsService, VadService, StorageService, NotificationService, PermissionService).
- [x] T014 [P] `AzkarRepository` (read-only asset load) in `lib/data/azkar_repository.dart`.
- [x] T015 [P] [TEST] `test/data/azkar_repository_test.dart`: parses; quran items have ref; byte-stable text.
- [x] T016 [P] [TEST] `test/models/daily_progress_test.dart`: date-rollover reset; same-day preserve.
- [x] T017 [P] Arabic RTL theme + app shell (`lib/theme/app_theme.dart`, `lib/app.dart`, `lib/main.dart`).
- [x] T018 Test fakes in `test/fakes/` (FakeTts/FakeVad/FakeStorage/FakePermission + call-order log).

**Checkpoint**: models + data load + theme; foundational tests green. ✅

---

## Phase 3: User Story 1 — Complete a session by voice (P1) 🎯 MVP

- [x] T019 [P] [US1] [TEST] `test/session/session_controller_test.dart`: INV-1/2 mic only after stop; INV-3 single advance; INV-4 list-complete once.
- [x] T020 [P] [US1] [TEST] `test/session/vad_detector_test.dart`: min-speech rejects blip; silence-window completes once; safety-timeout flag.
- [x] T021 [US1] `VadDetector` (`lib/session/vad_detector.dart`).
- [x] T022 [US1] `SessionController` state machine (`lib/session/session_controller.dart`).
- [x] T023 [US1] `FlutterTtsService` (`lib/services/tts_service.dart`) — awaitSpeakCompletion, ar.
- [x] T024 [US1] `RecordVadService` amplitude-only, no file/STT (`lib/services/vad_service.dart`).
- [x] T025 [US1] `SessionScreen` voice path (`lib/screens/session_screen.dart`).
- [x] T026 [P] [US1] `azkar_text_view.dart` + `repeat_counter.dart` widgets.

**Checkpoint**: list completable by voice; invariant tests pass. ✅ (MVP)

---

## Phase 4: User Story 2 — Manual Done/Skip + safety timeout (P1)

- [x] T027 [P] [US2] [TEST] `test/widget/session_screen_test.dart`: تم/تجاوز always present; manual-only with voice off.
- [x] T028 [US2] Done/Skip buttons wired to `advance()`/`skip()`, always visible.
- [x] T029 [US2] Honor `voiceDetectionEnabled=false` (skip listening, no VAD).
- [x] T030 [US2] Surface safety-timeout (emphasize Done).

**Checkpoint**: full list completable with zero voice. ✅

---

## Phase 5: User Story 3 — Today's progress & resume (P2)

- [x] T031 [US3] `SharedPrefsStorageService` with rollover reset + markListComplete (`lib/services/storage_service.dart`).
- [x] T032 [US3] Persist completion on `onListComplete`.
- [x] T033 [US3] `HomeScreen` with per-list status + entries (`lib/screens/home_screen.dart`).
- [x] T034 [P] [US3] `progress_badge.dart` widget.

**Checkpoint**: progress visible and resets across days. ✅

---

## Phase 6: User Story 4 — Daily reminders (P2)

- [x] T035 [US4] `LocalNotificationService`: tz init, zonedSchedule daily morning+evening, reschedule (`lib/services/notification_service.dart`).
- [x] T036 [US4] init + rescheduleFromSettings on launch (`lib/main.dart`).
- [x] T037 [US4] Android boot receiver re-registers reminders; OEM battery caveat documented.

**Checkpoint**: reminders fire daily and after reboot (code complete; live verify in T043 device pass). ✅

---

## Phase 7: User Story 5 — Settings & mic permission (P3)

- [x] T038 [US5] `PermissionHandlerService` (`lib/services/permission_service.dart`).
- [x] T039 [US5] Arabic mic-rationale dialog before first request; deny → manual-only.
- [x] T040 [US5] `SettingsScreen`: reminder times, voice toggle, sensitivity; persist + reschedule (`lib/screens/settings_screen.dart`).

**Checkpoint**: settings persist and take effect. ✅

---

## Phase 8: Polish & Cross-Cutting

- [x] T041 [P] Lifecycle teardown: stop TTS + VAD on background/pause (`WidgetsBindingObserver`).
- [x] T042 [P] In-app Arabic privacy notice (Settings).
- [ ] T043 [P] Tune timing defaults (silence window, min-speech, sensitivity) on a **real Android device**; record final values in `contracts/session-engine.md`. ⛔ needs hardware.
- [x] T044 Final gates: `flutter analyze` clean, `flutter test` green, debug APK builds.
- [ ] T045 Pre-release: **competent Arabic speaker** reviews `assets/azkar.json` vs source (Principle I) and records sign-off. ⛔ needs human reviewer.
- [x] T046 [P] [TEST] No-network guard `test/privacy/no_network_test.dart` (Principle III / FR-021).
- [x] T047 [P] [TEST] Sacred-text source-diff `test/data/azkar_source_diff_test.dart` (Principle I / SC-008); diffs azkar.json against `source/azkar-source.txt` + `source/azkar-evening-variants.txt`.

---

## Dependencies & Execution Order

Setup → Foundational block all stories. US1 (MVP) → US2 (same screen). US3/US4/US5 independent of
US1/US2 after Foundational; US5 settings feed US4 reschedule. Polish last.
Story order: US1 → US2 → US3 → US4 → US5.

## Parallel Opportunities

Setup T003–T006; Foundational T007–T010/T013–T017; US1 T019/T020/T026; tests across stories.

## Independent Test Criteria

- US1: speech→silence advances one phrase; mic never opens during playback; list completes.
- US2: voice off → finish via تم/تجاوز; timeout emphasizes Done.
- US3: completion shown on Home; resets on date change.
- US4: reminder fires at set time and after reboot.
- US5: settings persist across restart and change behavior.

## MVP

Phases 1 + 2 + 3 (US1) — hands-free session with the PLAY→STOP→LISTEN guarantee; add US2
immediately for the constitution-required manual fallback. **Delivered.**

## Remaining Work (2 tasks, both external)

| Task | Blocker | Needed to |
|------|---------|-----------|
| T043 | physical Android device | tune VAD silence/min-speech/sensitivity to real-world feel |
| T045 | competent Arabic speaker | sign off azkar text/counts before public release |
