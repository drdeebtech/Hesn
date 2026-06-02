# Design

Visual system for حصن (Hesn). Captured from the implemented Flutter theme
(`lib/theme/app_theme.dart`) and the design spec (`docs/ui-design.md`). Stack:
Flutter / Material 3, plain `setState`, no UI dependencies. Fully Arabic, RTL.
Direction: modern, bold, high-contrast, with a first-class dark mode for night
driving. `ThemeMode.system` selects light/dark automatically.

## Theme

- **Strategy:** committed — a saturated emerald primary carries CTAs, headers,
  and active states; gold is a sparing accent; surfaces stay near-neutral so the
  azkar text dominates.
- **Two modes, both shipped.** Light = warm off-white, low-glare day surface.
  Dark = near-black green-tinted, low-glare night-driving surface (AA+ text).
- Implemented as **explicit `ColorScheme`s** (not seed-generated) plus a
  `HesnColors` `ThemeExtension` for the two non-Material semantics
  (`success`, `warning`) and `skip`.

## Colors

Tokens are theme colors; widgets read `Theme.of(context).colorScheme.*` and
`Theme.of(context).extension<HesnColors>()!.*`. No hard-coded colors in widgets.

### Light
| Token | Hex | Role |
|---|---|---|
| scaffold background | `#F5F7F4` | app background (warm off-white) |
| surface | `#FFFFFF` | cards, sheets |
| surfaceContainerHighest | `#E6EDE8` | chips, inactive tracks |
| primary | `#0E7A63` | emerald — CTAs, active, headers |
| onPrimary | `#FFFFFF` | on primary |
| secondary (accent) | `#C9A227` | gold — repeat chip (filled), sparing |
| onSecondary | `#1F1A00` | dark text on gold |
| success / completed | `#1E9E5A` | done state, progress fill |
| skip (tertiary/error) | `#B4533A` | تجاوز |
| warning (timeout) | `#E08A00` | amber Done emphasis |
| onSurface (text) | `#10211C` | primary text + azkar |
| onSurfaceVariant | `#5A6B64` | secondary text |
| outline | `#C3D0CA` | borders, outline button |

### Dark (night-driving)
| Token | Hex | Role |
|---|---|---|
| scaffold background | `#0B1311` | near-black green-tinted |
| surface | `#13201C` | cards |
| surfaceContainerHighest | `#1E2F2A` | chips, tracks |
| primary | `#3FBF9E` | brightened emerald |
| onPrimary | `#03110D` | on primary |
| secondary | `#E3C35A` | gold (brightened) |
| onSecondary | `#1F1A00` | dark on gold |
| success | `#39C97A` | done / progress |
| skip | `#E07A5F` | تجاوز |
| warning | `#FFB23E` | amber timeout |
| onSurface (text) | `#ECF3EF` | azkar text (~15:1 on bg) |
| onSurfaceVariant | `#9DB0A8` | secondary text |
| outline | `#34453F` | borders |

Contrast: azkar ≈15–16:1; the gold repeat chip is **gold fill + dark on-gold
text** (not gold-on-light, which failed AA).

## Typography

Two families only: **Amiri** (Naskh, bundled, `weight 400/700`) for sacred azkar
text; **platform sans** (Roboto/SF) for all UI chrome. Arabic-Indic numerals
(٠–٩) in counters and the repeat chip.

| Role | Family | Size | Weight | height | Notes |
|---|---|---|---|---|---|
| Azkar display | Amiri | 40 | 700 | 1.85 | Session hero; `FittedBox` auto-fit, never truncates tashkīl |
| Azkar — Quran | Amiri | 34 | 400 | 2.0 | taller line; gold ref label `﴿ 2:255 ﴾` |
| Title (appbar/card) | sans | 22/20 | 700 | 1.2 | |
| Body | sans | 16 | 400 | 1.4 | |
| Secondary/caption | sans | 14 | 500 | 1.35 | onSurfaceVariant |
| Repeat chip `×٣` | sans | 18 | 700 | — | onSecondary on gold |
| Button label تم/تجاوز | sans | 22 | 700 | — | clamped text scale ≤1.3 |
| Progress `٤ / ١٢` | sans | 18 | 600 | — | Arabic-Indic |

## Spacing, Radius, Elevation

- **Spacing** (4/8 grid): 4, 8, 16, 24, 32, 48. Screen padding 16 (Session 24).
- **Radius:** 8 chips, 16 cards/buttons, 999 pills.
- **Elevation:** flat-first. Cards = elevation 0 + 1px outline border (no
  shadows). AppBar elevation 0. Separation comes from color, not shadow.

## Components

- **Primary button (تم):** `FilledButton`, full-width, 72 dp, radius 16.
  Timeout state → 88 dp, `warning` fill, slow opacity pulse (gated on
  reduce-motion). `Semantics(button, label)`.
- **Skip (تجاوز):** `OutlinedButton`, 72 dp, 1.5px `skip` stroke + `skip` text.
- **Repeat chip:** gold-filled pill, dark text, `×٣`.
- **Home card:** bordered container (full state border + soft success tint when
  completed — **no side-stripe rail**), 44 dp tinted icon disc (☀/🌙), title +
  count, status badge, "ابدأ" button.
- **Completion badge:** tinted pill — success "اكتمل اليوم" / neutral "لم يكتمل".
- **Progress bar:** 8 dp pill `LinearProgressIndicator`, `success` fill.
- **Settings:** grouped cards (Reminders / Operation), tonal time-pills
  (Arabic-Indic), `SwitchListTile` rows, sensitivity `Slider` with captions.

## Layout

- **Home:** two bold list cards (morning/evening) + a settings gear in the
  AppBar. Today's status is the headline.
- **Session (hero):** thin top strip (Arabic-Indic counter + 8 dp progress),
  gold repeat chip, the phrase owning ~55% of the viewport, a persistent
  bottom Skip/Done bar (Skip 40% / Done 60%, both ≥72 dp). No card chrome.
- **Settings:** two titled cards + a bottom privacy caption.

## Motion

Calm and minimal. Only one animation: the timeout Done-button opacity pulse
(1200 ms, gated on `MediaQuery.disableAnimations`). No bounce/elastic, nothing
spins. State color/size changes ease in over ~200 ms.

## Constraints

- The PLAY→STOP→LISTEN session engine is never touched by design changes.
- No new dependencies; stock Material 3 + `setState` only.
- Regenerate this doc after visual changes with `/impeccable document`.
