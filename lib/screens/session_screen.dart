import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../models/azkar.dart';
import '../models/daily_progress.dart';
import '../services/permission_service.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';
import '../services/vad_service.dart';
import '../session/session_controller.dart';
import '../session/session_phase.dart';
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
    this.stopGuard = const Duration(milliseconds: 250),
  });

  final AzkarList list;
  final AppSettings settings;
  final TtsService tts;
  final VadService vad;
  final PermissionService permissions;
  final StorageService storage;

  /// Delay between stopping playback and opening the mic; 0 in tests.
  final Duration stopGuard;

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen>
    with WidgetsBindingObserver {
  late SessionController _controller;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = SessionController(
      tts: widget.tts,
      vad: widget.vad,
      voiceEnabled: widget.settings.voiceDetectionEnabled,
      sensitivity: widget.settings.sensitivity,
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
    if (mounted) setState(() {});
  }

  Future<void> _onListComplete(String listId) async {
    _completed = true;
    final todayKey = DailyProgress.dateKeyFor(DateTime.now());
    await widget.storage.markListComplete(listId, todayKey);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Stop TTS + mic when leaving the foreground (Principle III / INV-5).
    if (state != AppLifecycleState.resumed) {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = _controller.phase == SessionPhase.idle
        ? widget.list.items.first
        : _controller.currentItem;
    final index = _controller.index;
    final total = widget.list.length;
    final emphasizeDone = _controller.safetyTimeoutElapsed;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.list.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: total == 0 ? 0 : (index + 1) / total,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text('${index + 1} / $total',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              RepeatCounter(repeat: item.repeat),
              const SizedBox(height: 16),
              Expanded(child: Center(child: AzkarTextView(item: item))),
              const SizedBox(height: 16),
              if (_controller.ttsSpeaking)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text('يُتلى الآن…'),
                )
              else if (_controller.isVoiceEnabled)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text('استمع… ثم اقرأ الذكر'),
                ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _completed ? null : _controller.skip,
                      icon: const Icon(Icons.skip_next),
                      label: const Text('تجاوز'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: emphasizeDone ? 2 : 1,
                    child: FilledButton.icon(
                      onPressed: _completed ? null : _controller.advance,
                      style: emphasizeDone
                          ? FilledButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 18),
                            )
                          : null,
                      icon: const Icon(Icons.check),
                      label: const Text('تم'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
