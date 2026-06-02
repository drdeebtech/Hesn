# حصن (Hesn) — UI Design System & Screen Specs

> **Direction:** Modern, bold, high-contrast. App-like, not ornamental. Arabic-first, fully RTL.
> **Constraints honored:** Stock Flutter Material 3 + `setState` only. No state-mgmt libs, no animation packages. Subtle cues only. Visual layer only — the audio engine (PLAY → STOP → LISTEN) is untouched.
> **Fonts:** Azkar text uses bundled **Amiri** (Naskh, family `"Amiri"`, Regular + Bold@700). UI labels/numbers use the **platform default sans** (Roboto on Android, SF on iOS — no extra asset). This keeps sacred text in Naskh and chrome clean/legible.

---

## 1. Design Principles (eyes-free + sacred content)

1. **One-second glance.** While driving, the user must parse "which phrase, how many reps left, am I done" in under a second. Exactly one element dominates each Session frame: the azkar phrase. Everything else is peripheral.
2. **Sacred text is never compromised.** Amiri Naskh, full tashkīl preserved, never truncated, never ellipsized, never shrunk below legibility. It auto-fits down only to a hard floor, then scrolls. No decorative overlay touches the glyphs.
3. **Two thumbs, no aiming.** Fallback controls (تم / تجاوز) are always-visible, full-width, ≥72dp tall, anchored to the bottom (thumb zone), separated so a blind tap can't hit the wrong one.
4. **Contrast over decoration.** Strong color blocks carry meaning (green = progress/done, amber = "act now" timeout, red-clay = skip). Dark mode is a first-class night-driving surface: near-black, low glare, AA+ text.
5. **Calm motion.** Transitions are ≤200ms cross-fades and a single slow pulse on timeout. Nothing spins, bounces, or distracts the driver.

---

## 2. Color Tokens

Brand seed stays in the family of `0xFF1B6B5A` but is evolved into a deeper, more saturated emerald for contrast punch.

### Light theme

| Token | Hex | Role |
|---|---|---|
| `background` | `#F5F7F4` | App scaffold (warm off-white, less glare than pure white) |
| `surface` | `#FFFFFF` | Cards, sheets |
| `surfaceVariant` | `#E6EDE8` | Chips, inactive tracks, list-card tint |
| `primary` | `#0E7A63` | Brand emerald — CTAs, headers, active states |
| `onPrimary` | `#FFFFFF` | Text/icons on primary |
| `secondary` (accent) | `#C9A227` | Gold accent — counters, highlights (use sparingly) |
| `success` / `completed` | `#1E9E5A` | Done state, completion badge, progress fill |
| `danger` / `skip` | `#B4533A` | تجاوز (skip) — muted terracotta, not alarm-red |
| `warning` (timeout) | `#E08A00` | Amber emphasis when safety timeout elapses |
| `textPrimary` | `#10211C` | Primary text (azkar in light mode) |
| `textSecondary` | `#5A6B64` | Labels, captions, secondary |
| `outline` | `#C3D0CA` | Borders, dividers, outline button stroke |

### Dark theme (night-driving optimized)

| Token | Hex | Role |
|---|---|---|
| `background` | `#0B1311` | Near-black green-tinted scaffold (low glare) |
| `surface` | `#13201C` | Cards, sheets |
| `surfaceVariant` | `#1E2F2A` | Chips, inactive tracks |
| `primary` | `#3FBF9E` | Brightened emerald (AA on dark) |
| `onPrimary` | `#03110D` | Text on primary |
| `secondary` (accent) | `#E3C35A` | Gold accent (brightened) |
| `success` / `completed` | `#39C97A` | Done state, progress fill |
| `danger` / `skip` | `#E07A5F` | تجاوز (skip), brightened terracotta |
| `warning` (timeout) | `#FFB23E` | Amber timeout emphasis |
| `textPrimary` | `#ECF3EF` | Azkar text in dark mode (AA+ ≥ 13:1 on bg) |
| `textSecondary` | `#9DB0A8` | Labels, captions |
| `outline` | `#34453F` | Borders, outline button stroke |

### Material 3 `ColorScheme` mapping

| ColorScheme slot | Light | Dark |
|---|---|---|
| `primary` | `#0E7A63` | `#3FBF9E` |
| `onPrimary` | `#FFFFFF` | `#03110D` |
| `primaryContainer` | `#B7E6D8` | `#0E5343` |
| `onPrimaryContainer` | `#00251C` | `#B7E6D8` |
| `secondary` | `#C9A227` | `#E3C35A` |
| `onSecondary` | `#1F1A00` | `#1F1A00` |
| `tertiary` (skip) | `#B4533A` | `#E07A5F` |
| `onTertiary` | `#FFFFFF` | `#2A0E06` |
| `error` | `#B4533A` | `#E07A5F` |
| `onError` | `#FFFFFF` | `#2A0E06` |
| `surface` | `#FFFFFF` | `#13201C` |
| `onSurface` | `#10211C` | `#ECF3EF` |
| `surfaceContainerHighest` (≈variant) | `#E6EDE8` | `#1E2F2A` |
| `onSurfaceVariant` | `#5A6B64` | `#9DB0A8` |
| `outline` | `#C3D0CA` | `#34453F` |
| `outlineVariant` | `#DCE6E0` | `#26352F` |

> **`completed`/`success` (`#1E9E5A` / `#39C97A`) and `warning` (`#E08A00` / `#FFB23E`) are NOT in M3's stock slots.** Carry them as `ThemeExtension` (`HesnColors`) — see §7 — so widgets read `Theme.of(context).extension<HesnColors>()!.success`.

---

## 3. Typography Scale

`fontFamily: 'Amiri'` for sacred text; UI uses `null` family (platform default sans). Heights are unitless multipliers (Flutter `height`). All Arabic is RTL via `Directionality.rtl` at the app root.

| Role | Family | Size (sp) | Weight | height | letterSpacing | Notes |
|---|---|---|---|---|---|---|
| **Azkar — display** | Amiri | **40** | 700 | 1.85 | 0 | Hero phrase on Session. Auto-fits 40→28 floor, then scrolls. Generous `height` so tashkīl marks above/below never clip. |
| **Azkar — Quran variant** | Amiri | **34** | 400 | 2.0 | 0 | Verses inside azkar; Regular weight + taller line so harakāt breathe. Optionally tinted with `secondary` (gold). |
| Screen title (AppBar) | sans | 22 | 700 | 1.2 | 0 | "حصن", "الإعدادات" |
| Card title | sans | 20 | 700 | 1.25 | 0 | "أذكار الصباح" / "أذكار المساء" |
| Body / settings label | sans | 16 | 400 | 1.4 | 0 | Switch/picker row labels |
| Secondary / caption | sans | 14 | 500 | 1.35 | 0.1 | Status text, privacy note, helper |
| **Repeat-count chip** | sans | 18 | 700 | 1.0 | 0.2 | "×٣" — use Arabic-Indic digits via `intl` |
| **Button label (تم / تجاوز)** | sans | 22 | 700 | 1.0 | 0.3 | Large for glanceability |
| **Progress counter "N / M"** | sans | 18 | 600 | 1.0 | 0.5 | Tabular feel; render as `٤ / ١٢` (Arabic-Indic, RTL reads counter then total) |

**RTL handling**
- Wrap azkar `Text` in `Directionality(textDirection: TextDirection.rtl)` and set `textAlign: TextAlign.center` for the hero, `TextAlign.right` for list/body.
- Numerals: convert with `NumberFormat('#', 'ar')` → Arabic-Indic (٠١٢…). The chip shows `'×' + arabicDigit(n)`.
- Never apply `overflow: ellipsis` to azkar — use `AutoSizeText`-style manual fit (or `FittedBox`/`LayoutBuilder` measuring down to the 28sp floor) then a scroll fallback. No truncation.

---

## 4. Spacing, Radius, Elevation

**Spacing (4/8 grid)** — tokens: `xs 4`, `sm 8`, `md 16`, `lg 24`, `xl 32`, `xxl 48`.
- Screen horizontal padding: `md` (16). Session uses `lg` (24) for breathing room.
- Vertical rhythm between blocks: `lg` (24). Inside cards: `md` (16).
- Gap between the two driving buttons: `md` (16) — wide enough to prevent mis-taps.

**Radius** — `sm 8` (chips), `md 16` (cards, buttons), `lg 24` (sheets, hero phrase container), `pill 999` (count chip, status badge).

**Elevation** — flat-first, bold blocks over shadows.
- Cards: elevation `0`, 1px `outline` border (light) / filled `surface` (dark). Optional `0.5` tonal lift on Home cards.
- Session phrase container: elevation `0`, fills its block with `surface`.
- Bottom button bar: elevation `0`, sits on `background`; separation comes from button color, not shadow.
- Sheets/dialogs: elevation `3`.

---

## 5. Component Specs

### Primary button — تم (Done)
Full-width `FilledButton`, height **72dp**, radius `md`, label style "Button label". Fill `primary`, text `onPrimary`. Pressed: 8% darken overlay. Disabled: `surfaceVariant` fill / `textSecondary`.

```
┌──────────────────────────────────────┐
│                  تم                   │   72dp tall, full width
└──────────────────────────────────────┘   fill = primary
```

**Emphasized timeout state** (safety timer elapsed): the SAME button grows to height **88dp**, fill switches to `warning` (amber), and a single slow opacity pulse (1.0→0.7→1.0 over 1200ms, `AnimatedOpacity`/`TweenAnimationBuilder` loop) draws the eye. A small "▸ تابع" hint label may appear above. No layout shift to other elements.

```
┌══════════════════════════════════════┐
║                  تم                   ║   88dp, fill = warning (amber)
└══════════════════════════════════════┘   slow 1.2s opacity pulse
```

### Secondary / outline button — تجاوز (Skip)
Full-width `OutlinedButton`, height **72dp**, radius `md`. Transparent fill, 1.5px `danger` stroke, `danger` text. Pressed: 8% `danger` tint fill. Stays calm so Done always wins visual weight.

```
╭──────────────────────────────────────╮
│                تجاوز                  │   72dp, stroke = danger, text = danger
╰──────────────────────────────────────╯
```

### Repeat-count chip
Pill, `surfaceVariant` fill, `secondary`(gold) text, "Repeat-count chip" style. Shows remaining reps as `×٣`. Height 32dp, horizontal padding `sm`.

```
( ×٣ )   pill, gold text on surfaceVariant
```

### Home list card (أذكار الصباح / المساء)
Full-width tappable `Card` (`InkWell`), radius `md`, padding `md`, min-height 96dp. RTL: leading icon sits on the RIGHT, title + status to its right-of-content reading order. Completed cards show a `completed` left accent bar (4dp) and the status badge.

```
┌────────────────────────────────────────────┐
│  ◗ الصباح               أذكار الصباح    ☀ │   title right, icon far right
│                          ✓ اكتمل اليوم      │   status badge under title
└────────────────────────────────────────────┘
```

### Completion status badge
Pill, `pill` radius. Done: `completed` fill (12% tint) + `completed` text + check glyph → "✓ اكتمل اليوم". Not done: `surfaceVariant` fill + `textSecondary` → "لم يكتمل".

```
( ✓ اكتمل اليوم )    tinted-green pill
( لم يكتمل )         neutral pill
```

### Linear progress bar
`LinearProgressIndicator`, height **8dp**, radius `pill`, track `surfaceVariant`, fill `success`. Sits directly under the AppBar/counter on Session. Pair with the "N / M" counter on its trailing (RTL: leading) side.

```
٤ / ١٢   ▓▓▓▓▓▓░░░░░░░░░░░░░░   8dp pill, fill = success
```

### Sensitivity slider (Settings)
`Slider`, active `primary`, inactive `surfaceVariant`, thumb `primary` 12dp. Discrete-ish feel with a value label. Endpoint captions "منخفضة / عالية" in caption style.

```
الحساسية
منخفضة ─────●────────── عالية
```

### Time-picker row (Settings)
`ListTile`-style row, RTL: label on the right, current time as a tappable `FilledButton.tonal` pill on the left. Tapping opens `showTimePicker`.

```
┌────────────────────────────────────────────┐
│  [ ٦:٣٠ ص ]            تذكير الصباح    🔔  │
└────────────────────────────────────────────┘
```

### Switch row (Settings)
`SwitchListTile`, RTL: title + optional subtitle on the right, `Switch` on the left. Active track `primary`. Min height 56dp.

```
┌────────────────────────────────────────────┐
│            ●━━○        كشف الصوت            │
│            وصف موجز اختياري                 │
└────────────────────────────────────────────┘
```

---

## 6. Screen-by-Screen Redesign (RTL — content right-aligned)

### 6.1 Home

```
┌──────────────────────────────────────────────┐
│  ⚙                                    حصن    │  AppBar: title right, settings left
├──────────────────────────────────────────────┤
│                                                │
│  ┌──────────────────────────────────────────┐ │
│  │  ◗                    أذكار الصباح    ☀  │ │  Card 1
│  │                        ✓ اكتمل اليوم      │ │
│  └──────────────────────────────────────────┘ │
│                                                │
│  ┌──────────────────────────────────────────┐ │
│  │  ◗                    أذكار المساء    🌙 │ │  Card 2
│  │                        لم يكتمل           │ │
│  └──────────────────────────────────────────┘ │
│                                                │
└──────────────────────────────────────────────┘
```
**vs basic Material:** Two bold, oversized cards instead of a plain `ListTile` list — each card is a color-anchored target with its own time-of-day icon and an at-a-glance completion badge. Settings is a single gear in the AppBar, not a tab. Today's status is the headline, not buried.

### 6.2 Session — the hero (light)

```
┌──────────────────────────────────────────────┐
│  ←                                  الصباح    │  minimal AppBar: back + set name
│  ٤ / ١٢   ▓▓▓▓▓░░░░░░░░░░░░░░░░               │  counter + 8dp progress
│                                                │
│                                        ( ×٣ )  │  repeat chip, top-right
│                                                │
│                                                │
│        أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ        │  AZKAR DISPLAY
│         مِنْ شَرِّ مَا خَلَقَ (ثلاث مرات)          │  Amiri 40sp/700, centered
│                                                │  fills the middle block
│                                                │
│                                                │
├──────────────────────────────────────────────┤
│  ╭───────────────╮   ┌──────────────────────┐ │
│  │     تجاوز      │   │          تم          │ │  bottom bar, thumb zone
│  ╰───────────────╯   └──────────────────────┘ │  Skip 40% / Done 60% width, both ≥72dp
└──────────────────────────────────────────────┘
```

### 6.2b Session — timeout emphasized (dark, night driving)

```
┌──────────────────────────────────────────────┐   bg #0B1311
│  ←                                  الصباح    │
│  ٤ / ١٢   ▓▓▓▓▓░░░░░░░░░░░░░░░░               │  fill #39C97A
│                                        ( ×٣ )  │  gold #E3C35A on #1E2F2A
│                                                │
│        أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ        │  text #ECF3EF (AA+ on near-black)
│         مِنْ شَرِّ مَا خَلَقَ (ثلاث مرات)          │  Amiri 40sp/700
│                                                │
│                              ▸ تابع            │  faint hint appears
├──────────────────────────────────────────────┤
│  ╭──────────╮   ┌════════════════════════════┐ │
│  │  تجاوز   │   ║            تم              ║ │  Done → 88dp, fill warning #FFB23E
│  ╰──────────╯   └════════════════════════════┘ │  slow 1.2s pulse, Skip shrinks
└──────────────────────────────────────────────┘
```
**vs basic Material:** The phrase owns ~55% of the viewport in Amiri display — no card chrome, no list around it. All meta (counter, progress, chip) is condensed into a thin top strip so the eye lands on text instantly. Two persistent giant buttons replace any swipe/next affordance. The timeout doesn't pop a dialog (dangerous while driving) — it just grows + ambers + slow-pulses the existing Done button in place.

### 6.3 Settings

```
┌──────────────────────────────────────────────┐
│  ←                              الإعدادات     │
├──────────────────────────────────────────────┤
│                                  التذكيرات    │  section header (textSecondary)
│  ┌──────────────────────────────────────────┐ │
│  │  [ ٦:٣٠ ص ]        تذكير الصباح     🔔   │ │  time-picker row
│  │  [ ٦:٤٥ م ]        تذكير المساء     🔔   │ │
│  └──────────────────────────────────────────┘ │
│                                                │
│                                   التشغيل      │  section header
│  ┌──────────────────────────────────────────┐ │
│  │     ●━━○          كشف الصوت               │ │  switch row
│  │     ●━━○          وضع القيادة             │ │  hands-free / driving switch
│  │                                            │ │
│  │  الحساسية                                  │ │
│  │  منخفضة ─────●────────── عالية            │ │  sensitivity slider
│  └──────────────────────────────────────────┘ │
│                                                │
│  ◌ تتم المعالجة على الجهاز ولا تُسجَّل الأصوات. │  privacy note (caption)
└──────────────────────────────────────────────┘
```
**vs basic Material:** Settings grouped into two titled cards (Reminders, Operation) instead of a flat list. Times are tappable tonal pills (clear they're editable) rather than trailing gray text. Privacy note is a calm caption with a leading dot icon, anchored at the bottom.

---

## 7. Flutter Implementation Guide

### Strategy
Use **explicit `ColorScheme`s** (not just `colorSchemeSeed`) so the bold, evolved palette is exact. Carry the two non-M3 semantic colors (`success`, `warning`) via a `ThemeExtension`. Drive light/dark with `ThemeMode.system`.

```dart
// --- Theme extension for non-M3 semantics ---
@immutable
class HesnColors extends ThemeExtension<HesnColors> {
  final Color success;   // completed
  final Color warning;   // timeout emphasis
  final Color skip;      // = colorScheme.error, kept explicit for clarity
  const HesnColors({required this.success, required this.warning, required this.skip});

  @override
  HesnColors copyWith({Color? success, Color? warning, Color? skip}) => HesnColors(
        success: success ?? this.success,
        warning: warning ?? this.warning,
        skip: skip ?? this.skip,
      );
  @override
  HesnColors lerp(ThemeExtension<HesnColors>? o, double t) {
    if (o is! HesnColors) return this;
    return HesnColors(
      success: Color.lerp(success, o.success, t)!,
      warning: Color.lerp(warning, o.warning, t)!,
      skip: Color.lerp(skip, o.skip, t)!,
    );
  }
}

const _hesnLight = HesnColors(success: Color(0xFF1E9E5A), warning: Color(0xFFE08A00), skip: Color(0xFFB4533A));
const _hesnDark  = HesnColors(success: Color(0xFF39C97A), warning: Color(0xFFFFB23E), skip: Color(0xFFE07A5F));
```

### ColorSchemes (explicit)

```dart
const _lightScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF0E7A63), onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFB7E6D8), onPrimaryContainer: Color(0xFF00251C),
  secondary: Color(0xFFC9A227), onSecondary: Color(0xFF1F1A00),
  tertiary: Color(0xFFB4533A), onTertiary: Color(0xFFFFFFFF),
  error: Color(0xFFB4533A), onError: Color(0xFFFFFFFF),
  surface: Color(0xFFFFFFFF), onSurface: Color(0xFF10211C),
  surfaceContainerHighest: Color(0xFFE6EDE8), onSurfaceVariant: Color(0xFF5A6B64),
  outline: Color(0xFFC3D0CA), outlineVariant: Color(0xFFDCE6E0),
);

const _darkScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF3FBF9E), onPrimary: Color(0xFF03110D),
  primaryContainer: Color(0xFF0E5343), onPrimaryContainer: Color(0xFFB7E6D8),
  secondary: Color(0xFFE3C35A), onSecondary: Color(0xFF1F1A00),
  tertiary: Color(0xFFE07A5F), onTertiary: Color(0xFF2A0E06),
  error: Color(0xFFE07A5F), onError: Color(0xFF2A0E06),
  surface: Color(0xFF13201C), onSurface: Color(0xFFECF3EF),
  surfaceContainerHighest: Color(0xFF1E2F2A), onSurfaceVariant: Color(0xFF9DB0A8),
  outline: Color(0xFF34453F), outlineVariant: Color(0xFF26352F),
);
```
> Scaffold background: set `scaffoldBackgroundColor: Color(0xFFF5F7F4)` (light) / `Color(0xFF0B1311)` (dark) — these differ slightly from `surface` for the warm-off-white / near-black feel.

### TextTheme override
Keep UI roles on the default sans (pass `fontFamily: null`); reserve Amiri for azkar styles you reference directly in the Session widget.

```dart
TextTheme _text(ColorScheme cs) => TextTheme(
  titleLarge:  TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.2,  color: cs.onSurface), // AppBar/card title
  titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.25, color: cs.onSurface),
  bodyLarge:   TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.4,  color: cs.onSurface),
  bodyMedium:  TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.35, letterSpacing: .1, color: cs.onSurfaceVariant),
  labelLarge:  TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.0,  letterSpacing: .3), // button labels
);

// Azkar styles — referenced directly in Session, NOT in textTheme:
const azkarDisplay = TextStyle(fontFamily: 'Amiri', fontSize: 40, fontWeight: FontWeight.w700, height: 1.85);
const azkarQuran   = TextStyle(fontFamily: 'Amiri', fontSize: 34, fontWeight: FontWeight.w400, height: 2.0);
const repeatChip   = TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.0, letterSpacing: .2);
const progressText = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.0, letterSpacing: .5);
```

### Component themes

```dart
ThemeData _build(ColorScheme cs, Color scaffold, HesnColors hesn) => ThemeData(
  useMaterial3: true,
  colorScheme: cs,
  scaffoldBackgroundColor: scaffold,
  textTheme: _text(cs),
  extensions: [hesn],
  appBarTheme: AppBarTheme(
    backgroundColor: scaffold, foregroundColor: cs.onSurface, elevation: 0, centerTitle: false,
    titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: cs.onSurface),
  ),
  cardTheme: CardThemeData(
    elevation: 0, color: cs.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: cs.outline, width: 1),
    ),
    margin: const EdgeInsets.symmetric(vertical: 8),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(72),
      textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: .3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(72),
      foregroundColor: hesn.skip,
      side: BorderSide(color: hesn.skip, width: 1.5),
      textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: .3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: hesn.success, linearTrackColor: cs.surfaceContainerHighest, linearMinHeight: 8,
  ),
  sliderTheme: SliderThemeData(
    activeTrackColor: cs.primary, inactiveTrackColor: cs.surfaceContainerHighest,
    thumbColor: cs.primary, trackHeight: 6,
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((s) =>
      s.contains(WidgetState.selected) ? cs.onPrimary : cs.outline),
    trackColor: WidgetStateProperty.resolveWith((s) =>
      s.contains(WidgetState.selected) ? cs.primary : cs.surfaceContainerHighest),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: cs.surfaceContainerHighest,
    labelStyle: TextStyle(color: cs.secondary, fontSize: 18, fontWeight: FontWeight.w700),
    shape: const StadiumBorder(),
  ),
);

final hesnLightTheme = _build(_lightScheme, const Color(0xFFF5F7F4), _hesnLight);
final hesnDarkTheme  = _build(_darkScheme,  const Color(0xFF0B1311), _hesnDark);
```

### MaterialApp wiring

```dart
MaterialApp(
  theme: hesnLightTheme,
  darkTheme: hesnDarkTheme,
  themeMode: ThemeMode.system,          // dark auto-applies at night
  locale: const Locale('ar'),
  supportedLocales: const [Locale('ar')],
  localizationsDelegates: const [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  builder: (ctx, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
);
```

### Timeout emphasis (no new deps)
In the Session `State`, keep a `bool _timedOut` toggled by the existing safety timer. Wrap the Done `FilledButton` so that when `_timedOut`:
- `minimumSize` → `Size.fromHeight(88)`,
- `backgroundColor` → `hesn.warning`,
- wrap in a repeating `TweenAnimationBuilder<double>` (or an `AnimationController` already in scope) animating opacity 1.0↔0.7 over 1200ms.
Use `AnimatedContainer`/`AnimatedDefaultTextStyle` (duration 200ms) for the size/color so it eases in. No dialog, no route change — keeps the driver's context intact.

### Accessibility checklist
- All driving targets ≥72dp (≥56dp hard floor) — already enforced via button themes.
- Respect `MediaQuery.textScaler`: azkar uses manual auto-fit; UI text uses `TextScaler` normally. Cap scaler at ~1.6 on the Session bottom bar so buttons never overflow (`MediaQuery.withClampedTextScaling`).
- Verify AA+: dark azkar `#ECF3EF` on `#0B1311` ≈ 15:1; light azkar `#10211C` on `#FFFFFF` ≈ 16:1; both buttons' on-color pairs ≥ 4.5:1.
- Add `Semantics(button: true, label: 'تم'/'تجاوز')` and announce progress changes politely (`SemanticsService.announce`) when a phrase advances.
```
