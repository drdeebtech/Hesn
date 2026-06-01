# Phase 1 Data Model: Guided Azkar Session

All types are plain Dart value objects. No database; azkar are a read-only bundled asset, and
progress/settings are small JSON blobs in `shared_preferences`.

## Enums

### AzkarType
- `dhikr` — a regular remembrance phrase.
- `quran` — a Qur'anic verse. **Immutable**; must carry `ref`; never edited or reflowed.

### SessionPhase
Linear state machine (see contracts/session-engine.md):
`idle → announcing → playing → stopping → listening → advancing → (announcing | done)`
- `announcing` (driving mode): speaks the repeat count (if `repeat > 1`) before the phrase is read.
  For `repeat == 1` it is a no-op pass-through. The mic stays closed.
- The mic may only be live in `listening`. Transition into `listening` requires a completed
  `stopping`. This ordering encodes Constitution Principle II.

## Entities

### AzkarItem
Single phrase shown and recited.

| Field    | Type        | Rules |
|----------|-------------|-------|
| `id`     | String      | Required, unique within its list (e.g. `m_001`, `m_kursi`). |
| `type`   | AzkarType   | Required. |
| `text`   | String      | Required. Fully voweled Arabic, verbatim from source. Never altered. |
| `repeat` | int         | Required, ≥ 1. Display-only; does not drive auto-advance (Principle IV). |
| `countPhrase` | String? | Canonical Arabic count wording for the spoken announcement (e.g. `ثلاث مرات`, `مائة مرة`). Present when `repeat > 1`; null/omitted for `repeat == 1`. |
| `source` | String      | Required, attribution (e.g. `حصن المسلم`). |
| `ref`    | String?     | Required **iff** `type == quran` (e.g. `2:255`); null for dhikr. |

Validation (enforced at load by `AzkarRepository`, asserted in tests):
- `repeat >= 1`.
- `type == quran` ⇒ `ref` non-empty.
- `text` non-empty; loaded byte-for-byte from the asset (no trimming/normalization).

### AzkarList
Ordered collection for one period.

| Field    | Type            | Rules |
|----------|-----------------|-------|
| `id`     | String          | `morning` or `evening`. |
| `title`  | String          | Arabic title (`أذكار الصباح` / `أذكار المساء`). |
| `items`  | List<AzkarItem> | Non-empty; preserves source order. |

### DailyProgress
Per-day completion. Persisted as JSON in `shared_preferences` under key `daily_progress`.

| Field               | Type    | Rules |
|---------------------|---------|-------|
| `morningCompleted`  | bool    | Default `false`. |
| `eveningCompleted`  | bool    | Default `false`. |
| `dateKey`           | String  | Local `yyyy-MM-dd` the flags belong to. |

Behavior:
- On read, if `dateKey != today`, return a fresh record (`false,false,today`) and persist it
  (date-rollover reset, FR-012).
- Completing a list sets the matching flag `true` for today (FR-010, FR-011).

### AppSettings
User preferences. Persisted as JSON in `shared_preferences` under key `app_settings`.

| Field                   | Type   | Default  | Rules |
|-------------------------|--------|----------|-------|
| `morningReminderTime`   | String | `06:30`  | `HH:mm` 24h local. |
| `eveningReminderTime`   | String | `16:30`  | `HH:mm` 24h local. |
| `voiceDetectionEnabled` | bool   | `true`   | When false, sessions run manual-only. |
| `sensitivity`           | double | `0.5`    | 0..1; maps to VAD amplitude threshold. |
| `handsFreeMode`         | bool   | `true`   | Hands-free/driving mode: when on, spoken count + cues + start-from-reminder are active. **Invariant:** `handsFreeMode ⇒ voiceDetectionEnabled`; setting `voiceDetectionEnabled=false` forces `handsFreeMode=false` (FR-030). |

## Relationships

```
AzkarList 1───* AzkarItem
SessionController ──reads──> AzkarList (one active list + current index)
SessionController ──uses──> AppSettings.voiceDetectionEnabled, .sensitivity
DailyProgress ──keyed by──> AzkarList.id (morning/evening)
NotificationService ──reads──> AppSettings.{morning,evening}ReminderTime
```

## Derived / display state (not persisted)

Held transiently by `SessionController`:
- `currentList: AzkarList`
- `index: int` (0-based position in `items`)
- `phase: SessionPhase`
- `currentItem => currentList.items[index]`
- `repeatDisplay => currentItem.repeat` (shown to user; never auto-counted)
- `safetyTimeoutElapsed: bool` (true after 8–10 s with no detected speech → emphasize Done)
