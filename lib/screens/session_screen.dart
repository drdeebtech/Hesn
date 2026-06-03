import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../models/azkar.dart';
import '../models/daily_progress.dart';
import '../services/cue_service.dart';
import '../services/permission_service.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';
import '../services/vad_service.dart';
import '../session/session_controller.dart';
import '../session/session_phase.dart';
import '../theme/app_theme.dart';
import '../util/arabic_numbers.dart';
import '../widgets/azkar_text_view.dart';
import '../widgets/repeat_counter.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({
    super.key,
    required this.list,
    required this.settings,
    required this.tts,
    required this.vad,
    required this.permissions,
    required this.storage,
    this.cue = const PlatformCueService(),
    this.stopGuard = const Duration(milliseconds: 250),
  });

  final AzkarList list;
  final AppSettings settings;
  final TtsService tts;
  final VadService vad;
  final PermissionService permissions;
  final StorageService storage;
  final CueService cue;

  /// Delay between stopping playback and opening the mic; 0 in tests.
  final Duration stopGuard;

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late SessionController _controller;
  late final AnimationController _pulse;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _controller = SessionController(
      tts: widget.tts,
      vad: widget.vad,
      voiceEnabled: widget.settings.voiceDetectionEnabled,
      sensitivity: widget.settings.sensitivity,
      handsFree: widget.settings.handsFreeMode,
      cue: widget.cue,
      stopGuard: widget.stopGuard,
    )
      ..addListener(_onChange)
      ..onListComplete = _onListComplete;
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Ask for mic only when voice is enabled; never block (Principle VII).
    if (widget.settings.voiceDetectionEnabled &&
        !await widget.permissions.micGranted()) {
      final ok = await _showMicRationale();
      if (ok) await widget.permissions.requestMic();
    }
    await _controller.start(widget.list);
    // One-time text-only notice when no Arabic TTS voice is available (FR-028).
    if (mounted && !_controller.audioAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text('لا يتوفر صوت عربي على الجهاز — سيظهر النص بدون قراءة صوتية.'),
        duration: Duration(seconds: 5),
      ));
    }
  }

  Future<bool> _showMicRationale() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إذن الميكروفون'),
        content: const Text(
          'نستمع فقط لنعرف أنك أنهيت الذكر، لا نسجّل صوتك ولا نحوّله إلى نص ولا يخرج من جهازك.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('لاحقاً'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('السماح'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _onChange() {
    if (!mounted) return;
    // Run the Done-button pulse only while the safety timeout is surfaced, and
    // never when the user has reduced-motion enabled (accessibility/driving).
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final emphasize = _controller.safetyTimeoutElapsed && !_completed;
    if (emphasize && !reduceMotion && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if ((!emphasize || reduceMotion) && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 0;
    }
    setState(() {});
  }

  Future<void> _onListComplete(String listId) async {
    _completed = true;
    final todayKey = DailyProgress.dateKeyFor(DateTime.now());
    await widget.storage.markListComplete(listId, todayKey);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      // Stop TTS + mic when leaving the foreground (Principle III / INV-5).
      _controller.pause();
    } else if (!_completed) {
      // On return, replay the current phrase from the start (FR-029).
      _controller.replayCurrent();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulse.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final item = _controller.phase == SessionPhase.idle
        ? widget.list.items.first
        : _controller.currentItem;
    final index = _controller.index;
    final total = widget.list.length;
    final emphasizeDone = _controller.safetyTimeoutElapsed && !_completed;

    return PopScope(
      // Guard an in-progress session: a stray back gesture shouldn't silently
      // drop progress. Once complete, allow the pop through untouched.
      canPop: _completed,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _confirmExit();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.list.title)),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
            child: Column(
              children: [
                // Top strip: counter + progress bar.
                Row(
                  children: [
                    Text(
                      '${toArabicDigits(index + 1)} / ${toArabicDigits(total)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: .5,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: total == 0 ? 0 : (index + 1) / total,
                          minHeight: 8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: RepeatCounter(repeat: item.repeat),
                ),
                const SizedBox(height: 8),
                Expanded(child: AzkarTextView(item: item)),
                const SizedBox(height: 12),
                _statusHint(emphasizeDone),
                const SizedBox(height: 12),
                _bottomBar(emphasizeDone),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmExit() async {
    // Pause TTS + mic while the user decides (Principle II/III: nothing runs
    // behind the dialog).
    _controller.pause();
    final exit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إنهاء الجلسة؟'),
        content: const Text('لم تكمل هذه القائمة بعد. هل تريد الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('متابعة'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('خروج'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (exit == true) {
      Navigator.of(context).pop();
    } else {
      // Stay: replay the current phrase from the start (same as resume, FR-029).
      _controller.replayCurrent();
    }
  }

  Widget _statusHint(bool emphasizeDone) {
    if (emphasizeDone) {
      return Text('▸ تابع',
          style: TextStyle(
              color: Theme.of(context).extension<HesnColors>()!.warning,
              fontWeight: FontWeight.w700));
    }
    final cs = Theme.of(context).colorScheme;
    final String? hint = _controller.ttsSpeaking
        ? 'يُتلى الآن…'
        : (_controller.isVoiceEnabled ? 'استمع… ثم اقرأ الذكر' : null);
    return SizedBox(
      height: 20,
      child: hint == null
          ? null
          : Text(hint, style: TextStyle(color: cs.onSurfaceVariant)),
    );
  }

  Widget _bottomBar(bool emphasizeDone) {
    final hesn = Theme.of(context).extension<HesnColors>()!;
    final done = AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final opacity = emphasizeDone ? (1.0 - 0.3 * _pulse.value) : 1.0;
        return Opacity(opacity: opacity, child: child);
      },
      child: Semantics(
        button: true,
        label: 'تم',
        child: FilledButton.icon(
          onPressed: _completed ? null : _controller.advance,
          style: emphasizeDone
              ? FilledButton.styleFrom(
                  backgroundColor: hesn.warning,
                  foregroundColor: const Color(0xFF2A1500),
                  minimumSize: const Size.fromHeight(88),
                )
              : null,
          icon: const Icon(Icons.check_rounded),
          label: const Text('تم'),
        ),
      ),
    );

    final bar = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: emphasizeDone ? 2 : 4,
          child: Semantics(
            button: true,
            label: 'تجاوز',
            child: OutlinedButton(
              onPressed: _completed ? null : _controller.skip,
              child: const Text('تجاوز'),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(flex: 6, child: done),
      ],
    );

    // Clamp text scaling so the button labels never overflow at large sizes.
    return MediaQuery.withClampedTextScaling(maxScaleFactor: 1.3, child: bar);
  }
}
