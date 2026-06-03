import 'package:flutter/material.dart';

/// One-shot first-run card. Explains the hands-free / driving idea, the
/// listen-only (no recording) microphone use, and that an Arabic TTS voice is
/// needed for the spoken parts. Shown once, then never again (storage flag set
/// by the caller on dismissal). Fully Arabic, RTL.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key, required this.onDone});

  /// Called when the user dismisses the card ("ابدأ"). The caller persists the
  /// seen-flag and pops/replaces this route.
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.directions_car_filled_rounded,
                      size: 48, color: cs.primary),
                ),
              ),
              const SizedBox(height: 24),
              Text('حصن — بدون لمس',
                  textAlign: TextAlign.center, style: text.titleLarge),
              const SizedBox(height: 8),
              Text(
                'مصمَّم لتقرأ أذكارك وأنت تقود: يقرأ الذكر، يستمع ليعرف أنك أنهيته، ثم ينتقل تلقائياً.',
                textAlign: TextAlign.center,
                style: text.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 28),
              _point(
                context,
                icon: Icons.volume_up_rounded,
                title: 'يقرأ ويُعلن العدد',
                body:
                    'يُسمعك كل ذكر وعدد مرّاته — يتطلّب صوتاً عربياً على الجهاز. '
                    'إن لم يتوفّر، يظهر النص فقط.',
              ),
              const SizedBox(height: 16),
              _point(
                context,
                icon: Icons.mic_none_rounded,
                title: 'يستمع فقط — لا يسجّل',
                body:
                    'نستمع لمستوى الصوت لنعرف أنك أنهيت، لا نسجّل صوتك ولا نحوّله '
                    'إلى نص ولا يخرج من جهازك.',
              ),
              const SizedBox(height: 16),
              _point(
                context,
                icon: Icons.touch_app_outlined,
                title: 'أزرار يدوية دائماً',
                body: 'زرّا «تم» و«تجاوز» ظاهران دائماً للتحكّم اليدوي.',
              ),
              const Spacer(flex: 3),
              FilledButton(
                onPressed: onDone,
                child: const Text('ابدأ'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _point(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String body,
  }) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 22, color: cs.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: text.titleMedium),
              const SizedBox(height: 2),
              Text(body,
                  style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}
