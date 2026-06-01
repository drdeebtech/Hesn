<!--
SYNC IMPACT REPORT
==================
Version change: (none) → 1.0.0   [initial ratification]
Bump rationale: First adoption of the project constitution. MAJOR baseline.

Modified principles: n/a (initial creation)
Added sections:
  - Core Principles (7): Sacred Text Integrity; PLAY → STOP → LISTEN;
    Privacy by Design; One Advance Per Phrase; Arabic-First & RTL;
    Radical Simplicity; Manual Fallback Always Available
  - Technical Constraints & Platform Scope
  - Development Workflow & Quality Gates
  - Governance
Removed sections: none

Templates requiring updates:
  ✅ .specify/templates/plan-template.md      — Constitution Check gates align (generic; no edits needed)
  ✅ .specify/templates/spec-template.md      — scope/requirements align (generic; no edits needed)
  ✅ .specify/templates/tasks-template.md      — task categories align (generic; no edits needed)
  ⚠ specs/*/plan.md (future)                  — must run Constitution Check against v1.0.0

Follow-up TODOs: none. Ratification date supplied by stakeholder (2026-06-01).
-->

# حصن (Hesn) Constitution

Hesn is a Flutter mobile app for morning and evening azkar (أذكار الصباح والمساء). It reads
each phrase aloud, listens only to confirm the user finished reciting, and advances. This
constitution defines the non-negotiable rules that govern every specification, plan, task, and
line of code in the project. The source of product scope is `plan.md`; this document encodes its
locked decisions as enforceable principles.

## Core Principles

### I. Sacred Text Integrity (NON-NEGOTIABLE)

Azkar text and repeat counts MUST come from Hisn al-Muslim (حصن المسلم) verbatim, fully voweled
(with tashkīl). Text MUST NOT be altered, normalized, abbreviated, or improvised — not for
display, not for TTS, not for matching. Items flagged `type: "quran"` are immutable Qur'anic
verses and MUST be treated as read-only sacred content, never edited or reflowed. Repeat counts
are a religious ruling, not a UX parameter, and MUST NOT be changed by developers. The azkar data
file MUST be reviewed and signed off by a competent Arabic speaker before any public release.

Rationale: The app handles sacred text; an error here is a religious harm, not a bug. Integrity
outranks every engineering convenience.

### II. PLAY → STOP → LISTEN (NON-NEGOTIABLE)

The microphone MUST NEVER be open while TTS audio is playing. Each phrase follows a strict,
sequential lifecycle: play audio → fully stop playback → then open the mic. These stages MUST NOT
overlap. This invariant MUST be covered by automated tests that fail if listening can begin before
playback has stopped.

Rationale: If the mic is open during playback, the app hears its own voice and auto-advances
before the user recites — silently breaking the core interaction.

### III. Privacy by Design (NON-NEGOTIABLE)

The app MUST NOT record audio to storage, MUST NOT perform speech-to-text, and MUST NOT make any
network call. Nothing leaves the device. The microphone MUST be active only during an active dhikr
session and released immediately afterward. Voice detection MUST observe audio amplitude (VAD)
only — never content. No analytics, telemetry, or crash reporting that transmits off-device.

Rationale: Users recite worship in private. The privacy guarantee is a promise to the user and a
hard architectural boundary, not a feature toggle.

### IV. One Advance Per Phrase (NON-NEGOTIABLE)

Repeat counts are displayed for the user to follow; the user counts their own repetitions. The app
MUST advance exactly once per phrase and MUST NOT auto-advance once per repeat. Voice detection and
the Done button each advance the current phrase a single step.

Rationale: Counting repeats automatically would require judging recitation — out of scope and
error-prone. The user owns the count; the app owns the sequence.

### V. Arabic-First & RTL

The UI MUST be fully Arabic and laid out right-to-left. Arabic strings (labels and azkar text) are
literal product content and MUST NOT be treated as translatable instructions or machine-translated.
Layout, alignment, and iconography MUST respect RTL throughout.

Rationale: The audience and the content are Arabic; the language is the product, not a locale.

### VI. Radical Simplicity

No backend, no login, no AI, no cloud sync. Persistence MUST be local only (`shared_preferences`).
State management MUST be plain `setState` — no state-management libraries. The following are
FORBIDDEN as dependencies or features: `speech_to_text`, text normalization, similarity/matching
of recitation, and automatic prayer-time calculation. Any new dependency MUST be justified against
this principle in the plan's Complexity Tracking.

Rationale: Every removed moving part is a removed failure mode. Simplicity is what makes a
single-developer, offline, privacy-preserving app shippable and maintainable.

### VII. Manual Fallback Always Available

The "تم" (Done) and "تجاوز" (Skip) buttons MUST be present and usable at all times during a
session, alongside voice detection. If no speech is detected within an 8–10 second safety timeout,
the Done affordance MUST be clearly surfaced so the user is never stuck. Voice detection is an
assist, never the sole path forward.

Rationale: VAD is probabilistic (quiet recitation, noise, hardware variance). A guaranteed manual
path keeps the app usable for everyone, always.

## Technical Constraints & Platform Scope

- Platforms: mobile only — Android first, then iOS. Web and desktop are out of scope.
- Stack (locked, per `plan.md` §5): `flutter_tts`, `record`, `flutter_local_notifications`,
  `shared_preferences`, `permission_handler`, `intl`. Additions require Principle VI justification.
- Data model: azkar stored as structured JSON with `id`, `type` (`dhikr` | `quran`), `text`
  (voweled), `repeat`, `source`, and `ref` (surah:ayah) for Qur'anic items.
- Reminders: two local notifications per day at user-chosen times; must survive device reboot.
- Storage schema includes per-day completion flags that reset automatically when the date changes.

## Development Workflow & Quality Gates

- Every feature plan MUST include a Constitution Check that explicitly confirms compliance with
  Principles I–VII before tasks are generated.
- Principle II (PLAY → STOP → LISTEN) and Principle IV (One Advance Per Phrase) MUST have automated
  tests. A change that weakens or removes these tests MUST be rejected in review.
- Any code path that touches azkar text, repeat counts, or `type: "quran"` items MUST preserve them
  byte-for-byte; reviewers MUST diff the azkar data file against the reviewed source.
- No dependency may be added without a one-line justification tied to Principle VI.
- Build/test gates (run via `source scripts/env.sh` first): `flutter analyze` clean and
  `flutter test` green before any release build.

## Governance

This constitution supersedes other practices and conventions where they conflict. Amendments MUST
be made by editing this file, accompanied by a Sync Impact Report (prepended as an HTML comment),
a version bump per the policy below, and propagation to dependent templates.

Versioning policy (semantic):
- MAJOR: removal or backward-incompatible redefinition of a principle or governance rule.
- MINOR: a new principle/section or materially expanded guidance.
- PATCH: clarifications, wording, and non-semantic refinements.

Compliance: every plan and review MUST verify adherence to all seven principles. The four
NON-NEGOTIABLE principles (I, II, III, IV) admit no exceptions; a deviation is a release blocker,
not a tradeoff. Complexity that appears to violate Principle VI MUST be justified in writing or
removed.

**Version**: 1.0.0 | **Ratified**: 2026-06-01 | **Last Amended**: 2026-06-01
