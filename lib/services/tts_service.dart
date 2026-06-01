import 'package:flutter_tts/flutter_tts.dart';

/// Reads a phrase aloud. [speak] MUST NOT complete until playback has finished
/// (or [stop] is called) — this is what lets the session engine guarantee
/// Constitution Principle II (mic never opens during playback).
abstract class TtsService {
  Future<void> init();
  Future<void> speak(String text);
  Future<void> stop();
  Future<void> dispose();
}

/// `flutter_tts`-backed implementation. Configured for Arabic and to await
/// speak completion.
class FlutterTtsService implements TtsService {
  FlutterTtsService([FlutterTts? tts]) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  bool _inited = false;

  @override
  Future<void> init() async {
    if (_inited) return;
    await _tts.setLanguage('ar');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    // Critical: speak() resolves only when the utterance has fully played.
    await _tts.awaitSpeakCompletion(true);
    _inited = true;
  }

  @override
  Future<void> speak(String text) async {
    await init();
    await _tts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
  }

  @override
  Future<void> dispose() async {
    await _tts.stop();
  }
}
