# Hesn (حصن) — Product

**Register:** product (app UI — design serves the task, not the brand).

**What it is:** An offline Flutter mobile app for the morning and evening azkar
(أذكار) of Hisn al-Muslim. It reads each phrase aloud, listens (audio-level VAD
only — no recording, no speech-to-text), and advances when the user finishes.

**Primary context (this drives every UI decision):** used **while driving** —
**eyes-free, hands-free, one-second glance, no precise taps.** Audio carries the
experience; the screen is a glanceable fallback.

**Audience:** Arabic-speaking Muslims performing a daily worship habit. Calm,
reverent, trustworthy.

**Platforms:** Android first, iOS next. Fully Arabic, right-to-left.

**Non-negotiables (from `.specify/memory/constitution.md`):**
- Sacred text (Amiri Naskh, full tashkīl) is verbatim and never altered/truncated.
- PLAY → STOP → LISTEN engine is untouched by design work.
- Privacy: no network, no recording, no STT. Local storage only.
- Plain Material 3 + `setState`; no new dependencies.

**Visual direction:** modern, bold, high-contrast; light + automatic dark mode
(dark = night-driving surface). Green emerald primary, gold accent, terracotta
skip, amber timeout.
