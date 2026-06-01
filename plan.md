# Azkar App — Final Simplified Plan (v2)

> A simple app for morning and evening azkar: it reads the phrase aloud, listens to confirm you finished reciting it, then moves to the next one.

> **Note for implementation:** Arabic strings (UI labels and azkar text) are kept in Arabic on purpose — they are literal app content. Everything else is instructions. The app UI is fully Arabic and right-to-left (RTL).

---

## 1. Final Decisions (Locked)

| Decision | Choice |
|---|---|
| Product type | Mobile app |
| Technology | Flutter (Android + iOS) |
| Content | Morning and evening azkar only |
| Language | Full Arabic, RTL layout |
| Audio output | TTS first (real recordings later) |
| Recitation detection | Voice Activity Detection (VAD) only |
| Pronunciation correctness check | **None** — only detect that the user spoke and finished |
| Repeat counting | Shown on screen; advance **once per phrase** (user counts repeats themselves) |
| Manual "Done" button | Always present alongside voice detection |
| Backend / AI / login | None |
| Storage | Local on device only |
| State management | Simple `setState` |
| Religious source | Hisn al-Muslim (حصن المسلم) |

---

## 2. Features (MVP only)

- Full Arabic UI + RTL.
- Morning azkar and evening azkar.
- Morning reminder and evening reminder (manual time chosen by the user).
- Read each phrase aloud.
- Listen to detect the user recited and finished → auto-advance.
- **"تم" (Done)** button for manual advance.
- **"تجاوز" (Skip)** button.
- Save today's progress (completed / not completed).
- Simple settings (reminder times + enable/disable voice detection).

---

## 3. Session Logic

```text
Show the phrase
   → Read it aloud (TTS)
   → Fully stop playback
   → Open the mic and watch the audio level
        • Speech, then 1.5–2s of silence?  → advance to next phrase
        • User tapped "تم" (Done)?          → advance
        • User tapped "تجاوز" (Skip)?       → advance
Repeat until the list ends → mark the session complete for today
```

**Critical rule:** Never listen while audio is playing. Strict sequence: **PLAY → STOP → LISTEN**. (Otherwise the mic hears the app's own voice and auto-advances before the user speaks.)

---

## 4. Voice Detection Mechanic (VAD)

We only watch the mic audio level — **no** speech-to-text and **no** comparison.

Rules to make it reliable:

- **Minimum speech duration** (roughly proportional to phrase length) before counting it as finished — prevents noise/coughs from advancing early.
- **Safety timeout:** if no speech is detected within 8–10 seconds, clearly surface the "تم" (Done) button so the user is never stuck.
- **Quiet recitation:** always keep the "تم" button visible, and add a simple sensitivity setting.
- **Silence duration to finish:** 1.5–2 seconds, tunable during testing on real devices.

---

## 5. Stack

```text
flutter_tts                 → read the phrase aloud
record                      → monitor audio level (VAD)
flutter_local_notifications → morning & evening reminders
shared_preferences          → settings + today's progress
permission_handler          → mic permission
intl                        → UI strings
```

> Permanently removed: `speech_to_text`, text normalization, similarity matching.

---

## 6. Azkar Data Model

```json
[
  {
    "id": "morning",
    "title": "أذكار الصباح",
    "items": [
      {
        "id": "m_001",
        "type": "dhikr",
        "text": "أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ",
        "repeat": 1,
        "source": "حصن المسلم"
      },
      {
        "id": "m_ayat_kursi",
        "type": "quran",
        "ref": "2:255",
        "text": "اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ...",
        "repeat": 1,
        "source": "حصن المسلم"
      }
    ]
  },
  {
    "id": "evening",
    "title": "أذكار المساء",
    "items": []
  }
]
```

- `type`: `dhikr` or `quran` — so Qur'anic verses are handled with care and never treated as editable text.
- `ref`: surah:ayah number for Qur'anic items.
- All text is **fully voweled (with tashkīl)** and must not be altered.

---

## 7. Progress Storage (Local)

```json
{
  "morningReminderTime": "06:30",
  "eveningReminderTime": "16:30",
  "morningCompletedToday": true,
  "eveningCompletedToday": false,
  "lastCompletedDate": "2026-06-01",
  "voiceDetectionEnabled": true
}
```

When the date changes, today's completion state resets automatically.

---

## 8. Notifications

- Two local notifications per day (morning and evening), times chosen by the user.
- Android caution: battery optimization / Doze can kill scheduled notifications → test on a real device, and reschedule after device reboot.

---

## 9. Privacy

- We do not record audio.
- We do not convert it to text.
- Nothing leaves the device.
- The mic is active only during a dhikr session.

**In-app text (Arabic):**
> نستمع فقط لنعرف أنك أنهيت الذكر، لا نسجّل صوتك ولا نحوّله إلى نص ولا يخرج من جهازك.

(English: "We only listen to know you finished the dhikr. We do not record your voice, do not convert it to text, and nothing leaves your device.")

**For store submission:** mic permission usage string (Arabic + English) + a hosted privacy-policy URL.

---

## 10. Religious Content

- Text and repeat counts taken from **Hisn al-Muslim** exactly (the repeat count is a religious ruling — do not improvise it).
- Text fully voweled and unaltered.
- `type: "quran"` flag on verses (Ayat al-Kursi, al-Ikhlas, al-Falaq, al-Nas, last verses of al-Baqarah).
- File reviewed by a competent Arabic speaker before release.

---

## 11. Implementation Steps

1. Create the Flutter project + set up RTL and Arabic.
2. Prepare the azkar JSON file (Hisn al-Muslim, with tashkīl, with Qur'an flags).
3. Build the home screen (morning / evening / settings + today's status).
4. Build the session screen (phrase text + counter + buttons: Done / Skip).
5. Add TTS to read the phrase.
6. Implement the **PLAY → STOP → LISTEN** sequence.
7. Add voice detection (`record` + speech/silence logic).
8. Add local notifications.
9. Add settings + progress saving.
10. Test on real Android and iOS devices (especially tuning silence duration and noise handling).
11. Prepare the privacy policy and permission strings.
12. Release: Android first, then iOS.

---

## 12. Out of Scope (Not in this version)

Login, backend, AI, cloud sync, automatic prayer-time calculation, azkar interpretation/tafsir, community/sharing, subscriptions, complex statistics.

---

## 13. Top 3 Things Before Coding

1. **Repeat counting:** one advance per phrase; the user counts repeats themselves.
2. **PLAY → STOP → LISTEN sequence** to stop TTS echo from triggering auto-advance.
3. **Lock the Hisn al-Muslim data** (text + counts + tashkīl + Qur'an flags) and have it reviewed.
