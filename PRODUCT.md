# Product

## Register

product

## Users

Arabic-speaking Muslims performing the daily morning/evening azkar (أذكار) of
Hisn al-Muslim. Their defining context: **using the app while driving** —
eyes-free, hands-free, one-second glances, no precise taps. Audio carries the
experience; the screen is a glanceable fallback. Secondary context: at home,
on a phone, before/after sleep.

## Product Purpose

Guide the user phrase-by-phrase through morning and evening azkar: read each
phrase aloud, listen (audio-level VAD only — no recording, no speech-to-text) to
confirm they finished, then advance. Daily reminders, local progress, fully
offline. Success = a person completes a full azkar list with their eyes on the
road and hands on the wheel, and trusts that nothing they say leaves the device.

## Brand Personality

Reverent, calm, trustworthy. Three words: **serene, sturdy, sincere**. The
interface should feel like a quiet companion for worship — never playful,
gamified, or attention-seeking. Sacred text is treated with care: Amiri Naskh,
full tashkīl, never altered.

## Anti-references

- Gamified habit/streak apps (confetti, badges, dopamine loops).
- Busy "Islamic app" clichés: heavy gold filigree, mosque-photo backgrounds,
  ornate arabesque borders crowding the text.
- SaaS-dashboard tells: hero-metric cards, identical card grids, tiny tracked
  eyebrows, gradient text, glassmorphism, side-stripe accent rails.
- Anything that requires reading small text or aiming a tap while driving.

## Design Principles

1. **One-second glance.** Each screen answers "which phrase, how many reps, am I
   done" instantly. Exactly one element dominates the Session frame: the phrase.
2. **Sacred text is never compromised.** Verbatim, fully voweled, never
   truncated or shrunk below legibility; no decoration touches the glyphs.
3. **Contrast carries meaning, not decoration.** Strong color blocks (green =
   progress, amber = act-now, terracotta = skip); dark mode is a first-class
   night-driving surface.
4. **Two thumbs, no aiming.** Fallback controls are always-visible, full-width,
   ≥72 dp, bottom-anchored, well-separated.
5. **The app earns trust by doing less.** Offline, no accounts, no tracking;
   privacy is a visible promise, not fine print.

## Accessibility & Inclusion

- WCAG AA minimum; azkar text targets AAA (~15:1). Verify all body/secondary
  text ≥4.5:1, large/bold ≥3:1.
- Reduced-motion respected (the timeout pulse is gated on
  `MediaQuery.disableAnimations`).
- Large touch targets (≥72 dp for driving controls); text-scale clamped on the
  button bar so labels never overflow.
- Full RTL; Arabic-Indic numerals. Screen-reader labels on primary controls.
